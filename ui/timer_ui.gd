extends DialogueElement
class_name TimerTooltip

var timer_over : bool = false
var level_node : Node3D
var canvas_node : CanvasLayer


func _ready():
	level_node = get_parent().get_parent()
	#super()
	viewport_scene.set_screen_size(Vector2(0.16, 0.09))
	viewport_scene.set_viewport_size(Vector2(160, 90))
	
	canvas_node = viewport_scene.scene_node
	var rect : ColorRect = canvas_node.get_child(0)
	rect.color.a = 0
	
func _process(delta : float):
	var new_text : String = str(level_node.level_timer).pad_decimals(2)
	_change_text_custom(new_text, 24, false, new_text.length())
	super(delta)
