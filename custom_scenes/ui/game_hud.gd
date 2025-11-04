extends Node3D
class_name GameHub

@export_category("XR Anchors")
@export var xr_origin: Node3D
@export var xr_camera: Node3D

@export_category("UI Scenes")
@export var dialogue_ui_scene: PackedScene
@export var hud_scene: PackedScene

@export_category("UI Settings")
@export var ui_distance: float = 3
@export var ui_height: float = 1.3 
@export var ui_scale: float = 1

# references to active UIs
var dialogue_ui_instance: Node3D
var hud_instance: Node3D

# HUD timer
var level_timer: float = 0.0
var timer_running: bool = false

func _ready():
	_initialize_ui()

func _process(delta):
	if timer_running:
		level_timer += delta
		if is_instance_valid(hud_instance):
			var hud_control = hud_instance.get_node("Viewport/CanvasLayer/Control")
			hud_control.update_timer(level_timer)
	
	_update_ui_follow()

# ----------------------------------------------------------------------
# 🧭 UI Initialization
# ----------------------------------------------------------------------
func _initialize_ui():
	if not xr_camera:
		push_error("XR Camera not assigned!")
		return

	# -- Dialogue UI
	#dialogue_ui_instance = _create_viewport_ui(dialogue_ui_scene, "DialogueUI", Vector3(0, ui_height, -ui_distance))
	dialogue_ui_instance = _instantiate_ui(dialogue_ui_scene, "DialogueUI", Vector3(0, ui_height, -ui_distance))
	dialogue_ui_instance.scale = Vector3(ui_scale, ui_scale, ui_scale)
	add_child(dialogue_ui_instance)

	# -- HUD UI
	#hud_instance = _create_viewport_ui(hud_scene, "HUD", Vector3(0.4, ui_height + 0.2, -ui_distance))
	hud_instance = _instantiate_ui(hud_scene, "HUD", Vector3(0.4, ui_height + 0.2, -ui_distance))
	hud_instance.scale = Vector3(ui_scale, ui_scale, ui_scale)
	add_child(hud_instance)

#func _create_viewport_ui(scene: PackedScene, name: String, local_offset: Vector3) -> Node3D:
	#var viewport_in_3d = preload("res://addons/godot-xr-tools/objects/viewport_2d_in_3d.tscn").instantiate()
	#viewport_in_3d.name = name
	#viewport_in_3d.scale = Vector3(ui_scale, ui_scale, ui_scale)
	#viewport_in_3d.set_screen_size(Vector2(1000, 250))
	#viewport_in_3d.set_viewport_size(Vector2(1000, 250))
	#viewport_in_3d.set_unshaded(true)
	#add_child(viewport_in_3d)
	#
	#var ui_instance = scene.instantiate()
	#viewport_in_3d.set_scene(ui_instance)
	#viewport_in_3d.position = xr_camera.global_transform.origin + xr_camera.global_transform.basis.z * -ui_distance + Vector3(0, ui_height, 0)
	#viewport_in_3d.look_at(xr_camera.global_position, Vector3.UP)
	#return viewport_in_3d

func _instantiate_ui(scene: PackedScene, name: String, local_offset: Vector3) -> Node3D:
	var ui_instance = scene.instantiate()
	ui_instance.position = xr_camera.global_transform.origin + xr_camera.global_transform.basis.z * -ui_distance + Vector3(0, ui_height, 0)
	ui_instance.look_at(xr_camera.global_position, Vector3.UP)
	return ui_instance

func _update_ui_follow():
	if not xr_camera:
		return
	
	if is_instance_valid(dialogue_ui_instance):
		print(dialogue_ui_instance.global_position)
		var target_pos = xr_camera.global_transform.origin 
		- xr_camera.global_transform.basis.z * ui_distance
		+ Vector3(0, ui_height, 0)
		print(target_pos)
		dialogue_ui_instance.global_position = target_pos
		
		var dir = xr_camera.global_position - dialogue_ui_instance.global_position
		if dir.length() > 0.001:
			dialogue_ui_instance.look_at(xr_camera.global_position, Vector3.UP)
		

# ----------------------------------------------------------------------
# 💬 Dialogue Interface
# ----------------------------------------------------------------------
func show_dialogue(npc_name: String, text: String, duration: float = 4.0):
	if not is_instance_valid(dialogue_ui_instance):
		return
	var control = dialogue_ui_instance.get_node("Viewport/CanvasLayer/Control")
	control.show_dialogue(npc_name, text, duration)

# ----------------------------------------------------------------------
# ⚠️ HUD Interface
# ----------------------------------------------------------------------
func show_prompt(text: String, duration: float = 3.0):
	if not is_instance_valid(hud_instance):
		return
	var control = hud_instance.get_node("Viewport/CanvasLayer/Control")
	control.show_prompt(text, duration)

func start_timer():
	level_timer = 0
	timer_running = true

func stop_timer():
	timer_running = false

# ----------------------------------------------------------------------
# 🎮 QTE Interface
# ----------------------------------------------------------------------
func start_qte(name: String, duration: float):
	if not is_instance_valid(hud_instance):
		return
	var control = hud_instance.get_node("Viewport/CanvasLayer/Control")
	control.start_qte(name, duration)

func update_qte_progress(progress: float):
	if not is_instance_valid(hud_instance):
		return
	var control = hud_instance.get_node("Viewport/CanvasLayer/Control")
	control.update_qte_progress(progress)

func show_qte_feedback(text: String):
	if not is_instance_valid(hud_instance):
		return
	var control = hud_instance.get_node("Viewport/CanvasLayer/Control")
	control.show_qte_feedback(text)

func end_qte(success: bool):
	if not is_instance_valid(hud_instance):
		return
	var control = hud_instance.get_node("Viewport/CanvasLayer/Control")
	control.end_qte(success)
