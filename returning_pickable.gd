extends XRToolsPickable
class_name ReturningPickable


var starting_position: Vector3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = global_position
	released.connect(set_original_position)
	pass # Replace with function body.

func set_original_position():
	print("POSITION RESET!")
	global_position = starting_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
