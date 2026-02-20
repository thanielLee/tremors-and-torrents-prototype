extends Node3D
class_name LevelButton

@onready var interactable_area: XRToolsInteractableAreaButton = $XRToolsInteractableAreaButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area.connect("button_pressed", _print_check) 
	pass # Replace with function body.

func _print_check(button) -> void:
	print("Button Pressed!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(interactable_area.get_overlapping_areas())
	print(interactable_area.get_overlapping_bodies())
