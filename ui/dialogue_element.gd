extends Node3D

@export var animation_speed : float = 20.0
@onready var viewport_scene: XRToolsViewport2DIn3D = $Viewport2Din3D
@onready var text_box : RichTextLabel

var in_animation: bool = false
var current_characters: float = 0.0
var animation_rate: float = 0.0

func _ready() -> void:
	if viewport_scene == null:
		viewport_scene = $Viewport2Din3D
	
	var canvas_scene = viewport_scene.scene_node
	var margin_child
	var vbox_child
	for canvas_child in canvas_scene.get_children():
		if canvas_child is MarginContainer:
			margin_child = canvas_child
	
	for margin_children in margin_child.get_children():
		if margin_children is VBoxContainer:
			vbox_child = margin_children
	
	for vbox_children in vbox_child.get_children():
		if vbox_children is RichTextLabel:
			text_box = vbox_children
	
	viewport_scene.pointer_event.connect(_ui_interaction)
	
	_change_text_animated("What do you want?\nWhat do you want?\nWhat do you want?\nWhat do you want?\nWhat do you want?\n")

func _process(delta: float) -> void:
	
	if in_animation:
		if current_characters + delta * animation_speed >= text_box.text.length():
			current_characters = text_box.text.length()
			in_animation = false
		else:
			current_characters += delta * animation_speed
		
		text_box.visible_characters = floor(current_characters)

	var xr_origin = get_parent().get_node("XROrigin3D")
	var xr_cam = xr_origin.get_node("XRCamera3D")
	var forward_direction = -xr_cam.global_transform.basis.z.normalized()

	var plane = Plane(Vector3(0, 1, 0))
	
	var projected_vector = plane.project(forward_direction).normalized() * 3
	viewport_scene.global_position = xr_cam.global_position + projected_vector
	viewport_scene.look_at(xr_cam.global_position, Vector3.UP, true)
	
	
func _change_text_animated(new_text: String):
	in_animation = true
	animation_rate = animation_speed / new_text.length()
	text_box.visible_characters = 0
	text_box.text = new_text


func _ui_interaction(event):
	if event.event_type == XRToolsPointerEvent.Type.PRESSED:
		if in_animation:
			in_animation = false
			text_box.visible_characters = text_box.text.length()
		else:
			visible = false
	
	
