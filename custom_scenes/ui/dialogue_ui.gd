extends CanvasLayer
class_name DialogueUI

@export var json_path: String = "res://dialogue_registry/dialogue_data.json"
var dialogue_data = {}

@onready var npc_name_label: Label = $Control/VBoxContainer/NPCNameLabel
@onready var dialogue_text_label: RichTextLabel = $Control/VBoxContainer/DialogueTextLabel
@onready var button_prompt_label: Label = $Control/VBoxContainer/ButtonPromptLabel
@onready var proceed_timer: Timer = $Control/ProceedTimer

var current_npc := ""
var current_state := ""
var dialogue_lines: Array
var index = 0
var show_button_prompt: bool = false
var active = false

signal dialogue_finished(npc_name)

func _ready():
	hide()
	_load_json()

func _load_json():
	var file = FileAccess.open(json_path, FileAccess.READ)
	
	if file == null:
		push_error("Could not open dialogue registry: " + json_path)
		return
	
	var raw_text := file.get_as_text()
	var json = JSON.parse_string(raw_text)
	
	if json == null:
		push_error("Dialogue JSON parse error in: " + json_path)
		return
	
	if typeof(json) != TYPE_DICTIONARY:
		push_error("Dialogue registry JSON must be a dictionary at top level.")
		return
	
	dialogue_data = json

func start_dialogue(npc_name: String, npc_state: String, display_name: String):
	if npc_name not in dialogue_data:
		push_error("Dialogue: NPC not found in registry: " + npc_name)
		return
	if npc_state not in dialogue_data[npc_name]:
		push_error("Dialogue: State not found in registry: " + npc_state)
		return
	
	current_npc = npc_name
	current_state = npc_state
	dialogue_lines = dialogue_data[npc_name][npc_state]
	index = 0
	active = true
	
	npc_name_label.text = display_name.capitalize()
	show()
	_show_line()

func _show_line():
	if index >= dialogue_lines.size():
		_end_dialogue()
		return
	
	var line_data = dialogue_lines[index]
	
	if typeof(line_data) == TYPE_DICTIONARY:
		dialogue_text_label.text = line_data.get("text", "")
		var duration = line_data.get("duration", 3.0)
		proceed_timer.start(duration)
	else:
		dialogue_text_label.text = str(line_data)
		proceed_timer.start() # auto advance
	
	button_prompt_label.modulate.a = 0
	_fade_in_prompt_later()

func _fade_in_prompt_later():
	await get_tree().create_timer(1.2).timeout
	button_prompt_label.modulate = Color(1,1,1,1)

func _advance():
	index += 1
	_show_line()

func _on_proceed_timer_timeout() -> void:
	if active:
		_advance()

func force_advance():
	if active:
		proceed_timer.stop()
		_advance()

func _end_dialogue():
	active = false
	hide()
	emit_signal("dialogue_finished", current_npc)
