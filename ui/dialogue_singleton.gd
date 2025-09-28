extends Node

var show_dialogue : bool = false
var dialogue_timer : float = 0.0
var text_to_show : String = ""

 
func _ready():
	get_tree().connect("tree_changed", Callable(self, "_on_tree_enter"))

func _on_tree_enter():
	if show_dialogue:
		var proto = get_tree().root.get_node("PrototypeStaging")
		if proto == null:
			return
			
		var scene = proto.get_node("Scene")
		
		if scene == null:
			return
		var main_menu = scene.get_node("MainMenuLevel")
		if main_menu == null:
			return
			
		var UI_node = main_menu.get_node("UI")
		var dialogue_element : DialogueElement = UI_node.get_node("DialogueElement")
		dialogue_element._ready()
		dialogue_element.enabled = true
		dialogue_element._change_text_timelimited(text_to_show, 24, false, text_to_show.length(), dialogue_timer)
		

func _show_text(text : String, timer_length : float):
	show_dialogue = true
	dialogue_timer = timer_length
	text_to_show = text
