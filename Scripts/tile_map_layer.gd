extends TileMapLayer

const BUSH_TILE = Vector2i(0, 3)
const SINGLE_TREE_TILE = Vector2i(0, 4)
const TREES_TILE = Vector2i(0, 5)
const HOUSE1_TILE = Vector2i(0, 6)
const HOUSE2_TILE = Vector2i(0, 7)
const WATER_POUND_TILES = [Vector2i(4, 3), Vector2i(5, 3), Vector2i(4, 4), Vector2i(5, 4)]
const GRASS_TILE = Vector2i(2, 4)
const CHUNK_SIZE = 16  # Size of each chunk (in tiles)
const RENDER_DISTANCE = 10  # Number of chunks to load around the player (in chunks)

var cell_size = Vector2(16, 16)  # Size of each tile cell

var rng = RandomNumberGenerator.new()

var _noise = FastNoiseLite.new()
var _detail_noise = FastNoiseLite.new()
var loaded_chunks = []  # Array to track loaded chunks

# Define preset combinations of tiles
var presets = [
	# Dense Forest: Trees and bushes dominate
	[TREES_TILE, TREES_TILE, BUSH_TILE, GRASS_TILE],

	# Sparse Forest: Mix of grass and single trees
	[GRASS_TILE, SINGLE_TREE_TILE, BUSH_TILE, GRASS_TILE],

	# Small Village: Houses and a few decorative items
	[HOUSE1_TILE, HOUSE2_TILE, GRASS_TILE, BUSH_TILE],

	# Wild Grassland: Only grass
	[GRASS_TILE, GRASS_TILE, GRASS_TILE, GRASS_TILE],

	# Thick Forest: Mostly trees with minimal grass
	[TREES_TILE, TREES_TILE, SINGLE_TREE_TILE, BUSH_TILE]
]


func _ready():
	rng.randomize()
	_noise.seed = rng.randi_range(0, 999999)
	_noise.frequency = 0.05
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM

	_detail_noise.seed = rng.randi_range(0, 999999)
	_detail_noise.frequency = 0.1
	_detail_noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED

	# Start by loading chunks around the origin
	update_visible_chunks(Vector2.ZERO)

func update_visible_chunks(player_position: Vector2):
	# Convert player's position to chunk coordinates
	var player_chunk = to_chunk_coords(player_position)

	var visible_chunks = []
	var chunks_to_load = []
	var chunks_to_unload = []

	# Determine which chunks should be visible
	for x in range(player_chunk.x - RENDER_DISTANCE, player_chunk.x + RENDER_DISTANCE + 1):
		for y in range(player_chunk.y - RENDER_DISTANCE, player_chunk.y + RENDER_DISTANCE + 1):
			visible_chunks.append(Vector2(x, y))

	# Determine chunks to load
	for chunk_coords in visible_chunks:
		if not chunk_coords in loaded_chunks:
			chunks_to_load.append(chunk_coords)

	# Determine chunks to unload
	for chunk_coords in loaded_chunks:
		if not chunk_coords in visible_chunks:
			chunks_to_unload.append(chunk_coords)

	# Load new chunks
	for chunk_coords in chunks_to_load:
		load_chunk(chunk_coords)

	# Unload chunks no longer visible
	for chunk_coords in chunks_to_unload:
		unload_chunk(chunk_coords)

	# Update loaded chunks list
	loaded_chunks = visible_chunks

func to_chunk_coords(world_position: Vector2) -> Vector2:
	# Convert world position to chunk coordinates
	return Vector2i(floor(world_position.x / (CHUNK_SIZE * cell_size.x)), floor(world_position.y / (CHUNK_SIZE * cell_size.y)))

func load_chunk(chunk_coords: Vector2):
	if chunk_coords in loaded_chunks:
		return

	var chunk_origin = chunk_coords * CHUNK_SIZE
	var used_positions = []  # Track positions already set by water ponds or special features

	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_coords = chunk_origin + Vector2(x, y)

			# Skip positions already used
			if world_coords in used_positions:
				continue

			var noise_value = _noise.get_noise_2d(world_coords.x, world_coords.y)
			var detail_noise_value = _detail_noise.get_noise_2d(world_coords.x, world_coords.y)

			# Water ponds placement
			if noise_value < -0.55 and x + 1 < CHUNK_SIZE and y + 1 < CHUNK_SIZE:
				var start_coords = chunk_origin + Vector2(x, y)
				if not (start_coords in used_positions or start_coords + Vector2(1, 0) in used_positions or start_coords + Vector2(0, 1) in used_positions or start_coords + Vector2(1, 1) in used_positions):
					place_water_pound(start_coords, used_positions)
					continue

			# Adjust biome selection based on surrounding tiles (smooth transitions)
			var preset = []
			if noise_value < -0.4:
				preset = presets[0]  # Dense forest
			elif noise_value < -0.35:
				preset = presets[1]  # Sparse forest
			elif noise_value < -0.3:
				preset = presets[2]  # Small village
			elif noise_value < 0.95:
				preset = presets[3]  # Wild grassland
			else:
				preset = presets[4]  # Thick forest

			var tile = Vector2i(-1, -1)
			# Use detail noise to influence small-scale placement
			if detail_noise_value > 0.8:
				tile = SINGLE_TREE_TILE
			elif detail_noise_value > 0.6:
				tile = BUSH_TILE
			else:
				tile = preset[rng.randi_range(0, preset.size() - 1)]

			set_cell(world_coords, 0, tile)

			# Mark used position if placing larger structures (like houses)
			if tile in [HOUSE1_TILE, HOUSE2_TILE]:
				used_positions.append(world_coords)

func set_cell_with_variation(pos: Vector2, layer: int, tile: Vector2i):
	set_cell(pos, layer, tile)
	# Add variation to the tile
	set_cell(pos, layer + 1, tile + Vector2i(1, 0))


func blend_noise(x: float, y: float) -> float:
	# Blend current noise with adjacent tiles for smoother transitions
	return (_noise.get_noise_2d(x, y) + _noise.get_noise_2d(x - 1, y) + _noise.get_noise_2d(x + 1, y) + _noise.get_noise_2d(x, y - 1) + _noise.get_noise_2d(x, y + 1)) / 5.0


func place_water_pound(start_coords: Vector2, used_positions: Array):
	# Place a 2x2 water pond and mark positions as used
	var water_tiles = WATER_POUND_TILES
	set_cell(start_coords, 0, water_tiles[0])  # Top-left
	set_cell(start_coords + Vector2(1, 0), 0, water_tiles[1])  # Top-right
	set_cell(start_coords + Vector2(0, 1), 0, water_tiles[2])  # Bottom-left
	set_cell(start_coords + Vector2(1, 1), 0, water_tiles[3])  # Bottom-right

	# Mark these positions as used
	used_positions.append(start_coords)
	used_positions.append(start_coords + Vector2(1, 0))
	used_positions.append(start_coords + Vector2(0, 1))
	used_positions.append(start_coords + Vector2(1, 1))

func place_grass_with_decor(world_coords: Vector2):
	# Randomly add decor like bushes or small rocks
	if rng.randf() < 0.3:
		set_cell(world_coords, 0, BUSH_TILE)
	else:
		set_cell(world_coords, 0, GRASS_TILE)


func unload_chunk(chunk_coords: Vector2):
	# Avoid duplicate unloading
	if not chunk_coords in loaded_chunks:
		return

	var chunk_origin = chunk_coords * CHUNK_SIZE
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_coords = chunk_origin + Vector2(x, y)
			# Clear the cell by setting it to an invalid value
			set_cell(world_coords, 0, Vector2i(-1, -1))

func _process(_delta):
	# Get player position (replace with your actual player node)
	var player = get_parent().get_node("Player")
	if not player:
		return
	var player_position = player.global_position
	# Update visible chunks based on player position
	update_visible_chunks(player_position)
