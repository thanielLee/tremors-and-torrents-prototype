extends Node3D
class_name InteractableNPC

@export var dialogue_states: Array[String] = []

var dialogue_sys
var cur_state: String
var state_index: int = 0

func _ready() -> void:
	if dialogue_states.size() > 0:
		cur_state = dialogue_states[state_index]

func next_state_dialogue():
	state_index += 1
	
	if dialogue_states.size() > state_index:
		cur_state = dialogue_states[state_index]

func _on_xr_tools_interactable_area_pointer_event(event: Variant) -> void:
	if !dialogue_sys:
		dialogue_sys = get_tree().get_first_node_in_group("dialogue_system")
	
	if !dialogue_sys.dialogue_active():
		if (event.event_type == XRToolsPointerEvent.Type.PRESSED):
			dialogue_sys.start_dialogue(name, cur_state)
