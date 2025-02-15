extends MarginContainer

var StartButton: Button = null
var ExitButton: Button = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Find the start and exit buttons
	StartButton = get_node("VBoxContainer/StartButton") # Change to your start button path
	ExitButton = get_node("VBoxContainer/ExitButton") # Change to your exit button path

# Start button press handler
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn") # Change to your game scene path

# Exit button press handler
func _on_exit_button_pressed():
	get_tree().quit() # Exit the game

# Start button hover enter handler
func _on_start_button_mouse_entered():
	StartButton.add_theme_color_override("font_color", Color(1, 0, 0)) # Change to red

# Start button hover exit handler
func _on_start_button_mouse_exited():
	StartButton.add_theme_color_override("font_color", Color(1, 1, 1)) # Change to white

# Exit button hover enter handler
func _on_exit_button_mouse_entered():
	ExitButton.add_theme_color_override("font_color", Color(1, 0, 0)) # Change to red

# Exit button hover exit handler
func _on_exit_button_mouse_exited():
	ExitButton.add_theme_color_override("font_color", Color(1, 1, 1)) # Change to white
