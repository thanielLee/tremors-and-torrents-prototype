extends CanvasLayer
class_name DialogueUI

@export var xr_camera_path: NodePath
@export var dialogue_json_path: String = "res://dialogue_registry/dialogue_data.json"
@export var distance_from_camera: float = 2.5
@export var height_offset: float = 0.5
@export var fade_duration: float = 0.5
@export var text_speed: float = 0.03  # Seconds per character
@export var auto_advance: bool = false

@onready var control: Control = $Control
@onready var npc_name: RichTextLabel = $Control/NPC_Name
@onready var npc_dialogue: RichTextLabel = $Control/NPC_Dialogue
@onready var bar: TextureRect = $Control/Bar
@onready var button_prompt: Label = $Control/ButtonPrompt

var dialogue_data = []
var current_index = 0
var is_typing = false
var fade_tween: Tween
var xr_camera: Node3D

func _ready():
	control.visible = false
	button_prompt.visible = false
	if xr_camera_path != NodePath():
		xr_camera = get_node(xr_camera_path)
	_load_dialogue_data()

func _physics_process(delta: float) -> void:
	if xr_camera:
		#_update_position()
		pass

#func _update_position():
	#var forward = -xr_camera.global_transform.basis.z
	#var target_pos = xr_camera.global_position + forward * distance_from_camera
	#target_pos.y += height_offset
	#control.global_position = get_viewport().get_camera_2d().unproject_position(target_pos)

func _load_dialogue_data():
	if not FileAccess.file_exists(dialogue_json_path):
		push_error("Dialogue file not found: %s" % dialogue_json_path)
		return
	var file = FileAccess.open(dialogue_json_path, FileAccess.READ)
	dialogue_data = JSON.parse_string(file.get_as_text())
	file.close()

func start_dialogue():
	current_index = 0
	if dialogue_data.is_empty():
		push_error("No dialogue data loaded.")
		return
	_show_next_line()

func _show_next_line():
	if current_index >= dialogue_data.size():
		_fade_out()
		return

	var entry = dialogue_data[current_index]
	var name = entry.get("name", "Unknown")
	var line = entry.get("line", "")
	var wait = entry.get("wait", 2.0)
	var prompt = entry.get("prompt", false)

	_fade_in(name, line, prompt)
	await _type_text(line)

	if auto_advance:
		await get_tree().create_timer(wait).timeout
		current_index += 1
		_show_next_line()
	else:
		if prompt:
			button_prompt.visible = true

func _fade_in(name: String, text: String, show_prompt: bool):
	control.visible = true
	control.modulate.a = 0.0
	button_prompt.visible = false
	npc_name.text = "[b]" + name + "[/b]"
	npc_dialogue.text = ""
	fade_tween = create_tween()
	fade_tween.tween_property(control, "modulate:a", 1.0, fade_duration)

func _fade_out():
	fade_tween = create_tween()
	fade_tween.tween_property(control, "modulate:a", 0.0, fade_duration)
	await fade_tween.finished
	control.visible = false

func _type_text(text: String) -> void:
	is_typing = true
	npc_dialogue.text = ""
	for c in text:
		npc_dialogue.append_text(c)
		await get_tree().create_timer(text_speed).timeout
	is_typing = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# Skip typing animation
			is_typing = false
			npc_dialogue.text = dialogue_data[current_index]["line"]
			button_prompt.visible = true
		elif button_prompt.visible:
			button_prompt.visible = false
			current_index += 1
			_show_next_line()
