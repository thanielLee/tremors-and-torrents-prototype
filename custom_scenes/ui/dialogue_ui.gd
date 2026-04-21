extends CanvasLayer
class_name DialogueUI

@export var json_path: String = "res://dialogue_registry/dialogue_data.json"

var dialogue_data = {}

@onready var npc_name_label: Label = $Control/DialoguePanel/VBox/SpeakerTab/NPCNameLabel
@onready var dialogue_text_label: RichTextLabel = $Control/DialoguePanel/VBox/DialogueInner/DialogueTextLabel
@onready var button_prompt_label: Label = $Control/DialoguePanel/VBox/DialogueInner/ButtonPromptLabel
@onready var proceed_timer: Timer = $Control/ProceedTimer
@onready var dialogue_panel: PanelContainer = $Control/DialoguePanel

var current_npc := ""
var current_state := ""
var dialogue_lines: Array
var index = 0
var active = false

signal dialogue_finished(npc_name)

func _ready():
	dialogue_panel.modulate.a = 0.0
	dialogue_panel.visible = false
	button_prompt_label.modulate.a = 0.0
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

# -----------------------
# FADE HELPERS
# -----------------------
func _fade_in(node: Control, duration: float = 0.2):
	node.modulate.a = 0.0
	node.visible = true
	var tw = create_tween()
	tw.tween_property(node, "modulate:a", 1.0, duration).set_ease(Tween.EASE_OUT)

func _fade_out(node: Control, duration: float = 0.15) -> void:
	var tw = create_tween()
	tw.tween_property(node, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	await tw.finished
	node.visible = false

# -----------------------
# DIALOGUE CONTROL
# -----------------------
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
	_fade_in(dialogue_panel, 0.3)
	_show_line()

func _show_line():
	if index >= dialogue_lines.size():
		_end_dialogue()
		return

	var line_data = dialogue_lines[index]
	button_prompt_label.modulate.a = 0.0

	if typeof(line_data) == TYPE_DICTIONARY:
		dialogue_text_label.text = line_data.get("text", "")
		# var duration = line_data.get("duration", 3.0)
		# proceed_timer.start(duration)
	else:
		dialogue_text_label.text = str(line_data)
		# proceed_timer.start()

	_fade_in_prompt_later()

func _fade_in_prompt_later():
	await get_tree().create_timer(2.0).timeout
	if active:
		_fade_in(button_prompt_label, 0.4)

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
	await _fade_out(dialogue_panel, 0.25)
	emit_signal("dialogue_finished", current_npc)
