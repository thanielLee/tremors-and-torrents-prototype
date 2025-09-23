extends Node3D

@export var animation_speed : float = 20.0
@onready var viewport_scene: XRToolsViewport2DIn3D = $Viewport2Din3D
@onready var text_box : RichTextLabel
@onready var xr_origin : XROrigin3D = $"../XROrigin3D"
@export var is_tooltip : bool = false
@export var tooltip_uv : Vector2 = Vector2(0.55, 0.45)
@export var dialogue_z : float = 0.85

var in_animation: bool = false
var current_characters: float = 0.0
var animation_rate: float = 0.0
var xr_cam : XRCamera3D
var plane : Plane = Plane(Vector3(0, 1, 0), 0.3)
var cooldown = 0.0

var tooltip_middle : Vector3
var tooltip_lookat : Vector3

func _ready() -> void:
	if viewport_scene == null:
		viewport_scene = $Viewport2Din3D
	
	if is_tooltip:
		_make_tooltip()
	else:
		_make_text_dialogue()
	
	if xr_origin == null:
		xr_origin = $"../XROrigin3D"
	
	var xr_origin = get_parent().get_node("XROrigin3D")
	xr_cam = get_viewport().get_camera_3d()
	
	_calculate_new_tooltip_middle(tooltip_uv)
	
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
	
func _plane_to_plane_intersection(a:Plane, b: Plane):
	if a.normal == b.normal:
		if a.d == b.d:
			return a
		else:
			return b
	
	var normal_direction = a.normal.cross(b.normal).normalized()
	var mat = Transform2D()
	mat.x = Vector2(a.normal.x, a.normal.y)
	mat.y = Vector2(b.normal.x, b.normal.y)
	var mat_inv = mat.affine_inverse()
	var dist_vec = Vector2(-a.d, -b.d)
	var ans = mat_inv.basis_xform(dist_vec)
	
	return [Vector3(ans.x, ans.y, 0), normal_direction]
	
func _process(delta: float) -> void:
	if in_animation:
		if current_characters + delta * animation_speed >= text_box.text.length():
			current_characters = text_box.text.length()
			in_animation = false
		else:
			current_characters += delta * animation_speed
		
		text_box.visible_characters = floor(current_characters)

	var forward_direction = -xr_cam.global_transform.basis.z.normalized()
	var right_eye_transform = XRServer.primary_interface.get_transform_for_view(1, xr_origin.global_transform)
	
	if not is_tooltip:
		print(forward_direction)
		var projected_vector = forward_direction * 3
		viewport_scene.global_position = plane.project(xr_cam.global_position + projected_vector)
		viewport_scene.look_at(xr_cam.global_position, Vector3.UP, true)
	else:
		cooldown += delta
		
		viewport_scene.global_position = right_eye_transform * tooltip_middle
		
		if cooldown >= 1.0:
			cooldown -= 1.0
			#print(xr_cam.project_position(tooltip_middle, 3)-xr_cam.global_position)
			#print(tooltip_middle)
			#print(xr_cam.unproject_position(projected_point))
			var test_plane_1 = Plane(Vector3(1, 0, 0))
			var test_plane_2 = Plane(Vector3(0, 1, 0))
			#print("HERE: " + str(near_plane))
			var temp = _plane_to_plane_intersection(test_plane_1, test_plane_2)
			
			#print(left_plane)
			#print(top_plane)
			#print(right_plane)
			#print(bot_plane)
			#print(near_plane)
			#print(intersect_1)
			#print(intersect_2)
			#print(intersect_3)
			#print(intersect_4)
			#print(test_line)
			#print(tooltip_middle)
			#print(_plane_to_plane_intersection(right_eye_projection.get_projection_plane(2), right_eye_projection.get_projection_plane(3)))
		#viewport_scene.global_position = xr_cam.global_position + Vector3(1.5, 1.5, -3)
			#print(viewport_scene.global_position)
		viewport_scene.look_at(right_eye_transform * tooltip_lookat, Vector3.UP, true)


func _calculate_new_tooltip_middle(uvs: Vector2):
	var viewport = xr_cam.get_viewport()
	var viewport_size = xr_cam.get_viewport().size
	
	var right_eye_transform = XRServer.primary_interface.get_transform_for_view(1, xr_origin.global_transform)
	var right_eye_projection = XRServer.primary_interface.get_projection_for_view(1, viewport_size.x/viewport_size.y, xr_cam.near, xr_cam.far)
	#print("TEST: " + str(right_eye_projection.get_viewport_half_extents()))
	var near_plane = right_eye_projection.get_projection_plane(0)
	var left_plane = right_eye_projection.get_projection_plane(2)
	var top_plane = right_eye_projection.get_projection_plane(3)
	var right_plane = right_eye_projection.get_projection_plane(4)
	var bot_plane = right_eye_projection.get_projection_plane(5)
	
	var intersect_1 = _plane_to_plane_intersection(top_plane, left_plane)
	var intersect_2 = _plane_to_plane_intersection(right_plane, top_plane)
	var intersect_3 = _plane_to_plane_intersection(bot_plane, right_plane)
	var intersect_4 = _plane_to_plane_intersection(left_plane, bot_plane)
	
	#print(near_plane)
	
	near_plane.d = dialogue_z
	
	var top_left = -near_plane.intersects_ray(intersect_1[0], intersect_1[1])
	var right_vec = -near_plane.intersects_ray(intersect_2[0], intersect_2[1])-top_left
	var bot_vec = -near_plane.intersects_ray(intersect_4[0], intersect_4[1])-top_left
	
	tooltip_middle = top_left + right_vec*uvs.x + bot_vec*uvs.y
	tooltip_lookat = tooltip_middle
	tooltip_middle.z -= 0.02
	
func _make_tooltip() -> void:
	viewport_scene.set_screen_size(Vector2(0.32, 0.18))
	viewport_scene.set_viewport_size(Vector2(320, 180))
	is_tooltip = true

func _make_text_dialogue() -> void:
	viewport_scene.set_screen_size(Vector2(1.6, 0.9))
	viewport_scene.set_viewport_size(Vector2(160, 90))
	is_tooltip = false
	
func _change_text_animated(new_text: String):
	in_animation = true
	animation_rate = animation_speed / new_text.length()
	text_box.visible_characters = 0
	text_box.text = new_text

func _appear_text(new_text: String):
	_change_text_animated(new_text)
	visible = true

func _ui_interaction(event):
	if event.event_type == XRToolsPointerEvent.Type.PRESSED:
		if in_animation:
			in_animation = false
			text_box.visible_characters = text_box.text.length()
		else:
			visible = false
			text_box.text = ""
	
	
