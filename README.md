# Prototype Game

This project is a 2D game prototype developed using the Godot Engine. The game features a player character, enemies, pickups, and a user interface. The game includes mechanics for spawning enemies, increasing difficulty over time, and handling player interactions such as health changes and game over scenarios.

![Gameplay](https://github.com/AlrIsmail/Godot_2D_Flight_Survival/blob/main/Assets/Gameplay.gif)
## Project Structure

The project is organized into several directories and files:
- Assets: Contains various assets used in the game, such as images and textures.
- Scenes: Contains the scene files for different parts of the game.
- Scripts: Contains the GDScript files that define the game logic.

## Key Files

- project.godot: The main project file for the Godot Engine.
- export_presets.cfg: Configuration for exporting the game to different platforms.
- game.tscn: The main game scene.
- game.gd: The main script file that contains the game logic.

## Game Mechanics

### Map

The map is procedurally generated using a combination of noise functions and predefined tile presets. The map consists of various biomes such as dense forests, sparse forests, small villages, wild grasslands, and thick forests. The map is divided into chunks, and each chunk is loaded or unloaded based on the player's position to optimize performance.

Key features of the map generation:
- **Tile Presets**: Predefined combinations of tiles for different biomes.
- **Noise Functions**: Used to generate terrain features and smooth transitions between biomes.
- **Water Ponds**: Special features like water ponds are placed based on noise values.
- **Chunk Management**: Chunks are loaded and unloaded dynamically based on the player's position.

The map generation logic is handled in the `tile_map_layer.gd` script.

### Player

The player character is represented by a `Character2D` node and is managed in the game.gd script. The player can interact with enemies and pickups, and their health is tracked and updated.

### Enemies

Enemies are spawned at regular intervals and their difficulty increases over time. The spawning logic is handled in the game.gd script using timers. Enemies are instantiated from the `EnemyScene` and added to the scene tree.

### User Interface

The user interface includes health, timer, and score labels. It also includes a menu for pausing, continuing, restarting, and quitting the game. The UI is managed in the game.gd script and instantiated from the `UIScene` and `MenuScene`.

### Game Flow

The game flow is managed through various functions in the game.gd script:

- `_ready()`: Initializes the game, spawns initial enemies, and sets up the UI.
- `restart_game()`: Restarts the game by reloading the current scene.
- `quit_game()`: Quits the game.
- `pause_game()`: Pauses the game and shows the menu.
- `continue_game()`: Resumes the game from a paused state.
- `update_health()`: Updates the player's health in the UI.
- `game_over()`: Handles the game over scenario.
- `spawn_enemies()`: Sets up a timer to spawn enemies at regular intervals.
- `increase_difficulty()`: Sets up a timer to increase the game's difficulty at regular intervals.
- `_on_spawn_enemy_timeout()`: Spawns an enemy when the spawn timer times out.
- `_on_increase_difficulty_timeout()`: Increases the game's difficulty when the difficulty timer times out.
- `spawn_enemy()`: Spawns an enemy at a random position around the player.
- `_on_enemy_destroyed()`: Handles the destruction of an enemy and updates the score.
- `_physics_process(delta)`: Updates the game state every physics frame.
- `_input(event)`: Handles input events, such as pausing the game.
- `update_timer(delta)`: Updates the game timer.

## How to Run

1. Open the project in the Godot Engine.
2. Run the project by pressing the play button in the Godot editor.

## Exporting

The project can be exported to different platforms using the configurations in the export_presets.cfg file. The available presets include Windows, macOS, and iOS.

## License

This project uses assets from various sources. Please refer to the individual asset licenses for more information.

## Acknowledgements

- [Godot Engine](https://godotengine.org/)
- [Kenney.nl](https://kenney.nl/assets), [Itch.io](https://itch.io/game-assets) and their respective creators for providing free game assets.

For more information, please refer to the individual script and scene files in the project.
