extends Node3D
class_name DialogueElement

@export var animation_speed : float = 20.0
@onready var viewport_scene: XRToolsViewport2DIn3D = $Viewport2Din3D
@onready var text_box : RichTextLabel
@onready var xr_origin : XROrigin3D = $"../../XROrigin3D"
@onready var player_body : XRToolsPlayerBody = $"../../XROrigin3D/PlayerBody"
@export var is_tooltip : bool = false
@export var tooltip_uv : Vector2 = Vector2(0.55, 0.50)
@export var dialogue_z : float = 0.9


var in_animation: bool = false
var current_characters: float = 0.0
var xr_cam : XRCamera3D
var plane : Plane = Plane(Vector3(0, 1, 0), 0.65)
var cooldown = 0.0
var collision_shape : CollisionShape3D
var tooltip_middle : Vector3
var tooltip_lookat : Vector3


func _ready() -> void:
	if viewport_scene == null:
		viewport_scene = $Viewport2Din3D
	
	collision_shape = get_child(0).get_child(2).get_child(0)
	
	visible = false
	collision_shape.disabled = true
	
	var screen_mesh : MeshInstance3D  = viewport_scene.get_child(1)

	
	if xr_origin == null:
		xr_origin = $"../../XROrigin3D"
	
	var xr_origin = get_parent().get_parent().get_node("XROrigin3D")
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
	#text_box.texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	
	_appear_text("What do you want?\nWhat do you want?\nWhat do you want?\nWhat do you want?\nWhat do you want?\n", is_tooltip)
	
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

	var forward_direction = -xr_cam.get_frustum()[0].normal
	var right_eye_transform = XRServer.primary_interface.get_transform_for_view(1, xr_origin.global_transform)
	var test_frustum = xr_cam.get_frustum()
	
	if not is_tooltip:
		viewport_scene.global_position = plane.project(xr_origin.transform * (plane.project(forward_direction).normalized() * 2.5))
		#print(str(xz_offset) + " " + str(xr_cam.global_position) + " " + str($"../../XROrigin3D/PlayerBody".global_position))
		viewport_scene.look_at(xr_origin.transform * xr_cam.global_position, Vector3.UP, true)
	else:
		cooldown += delta
		viewport_scene.global_position = right_eye_transform * tooltip_middle
		#print(viewport_scene.global_position)
		if cooldown >= 1.0:
			cooldown -= 1.0
			#print(xr_cam.project_position(tooltip_middle, 3)-xr_cam.global_position)
			#print(tooltip_middle)
			#print(xr_cam.unproject_position(projected_point))
			var test_plane_1 = Plane(Vector3(1, 0, 0))
			var test_plane_2 = Plane(Vector3(0, 1, 0))
			#print("HERE: " + str(near_plane))
			var temp = _plane_to_plane_intersection(test_plane_1, test_plane_2)
			#print(forward_direction)
			
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
	_modify_sizes(Vector2(0.32, 0.18), Vector2(320, 180))
	is_tooltip = true

func _modify_sizes(screen_size : Vector2, viewport_size : Vector2):
	viewport_scene.set_screen_size(screen_size)
	viewport_scene.set_viewport_size(viewport_size)

func _make_text_dialogue() -> void:
	_modify_sizes(Vector2(1.6, 0.9), Vector2(640, 360))
	is_tooltip = false
	
func _set_text(new_text : String, size : int):
	text_box.text = "[font_size=" + str(size) + "][b]" + new_text + "[/b][/font_size]"
	
func _change_text_animated(new_text: String):
	in_animation = true
	text_box.visible_characters = 0
	_set_text(new_text, 32)
	
func _change_text_non_animated(new_text: String):
	in_animation = false
	text_box.visible_characters = new_text.length()
	_set_text(new_text, 16)

func _change_text_custom(new_text : String, size : int, is_animation : bool, visible_chars : int):
	in_animation = is_animation
	text_box.visible_characters = visible_chars
	_set_text(new_text, size)
	
func _appear_text(new_text: String, will_be_tooltip: bool):
	collision_shape.disabled = false
	visible = true
	
	if will_be_tooltip:
		_make_tooltip()
		_change_text_non_animated(new_text)
	else:
		_make_text_dialogue()
		_change_text_animated(new_text)

# Function to remove tooltip
func _remove_dialogue():
	visible = false
	collision_shape.disabled = true

# Removes dialogue when pointer detects
func _ui_interaction(event : XRToolsPointerEvent):
	
	if event.event_type == XRToolsPointerEvent.Type.ENTERED and not is_tooltip:
		var pointer_test : XRToolsFunctionPointer = event.pointer
		pointer_test.show_laser = XRToolsFunctionPointer.LaserShow.SHOW
	
	if event.event_type == XRToolsPointerEvent.Type.EXITED and not is_tooltip:
		var pointer_test : XRToolsFunctionPointer = event.pointer
		pointer_test.show_laser = XRToolsFunctionPointer.LaserShow.HIDE
	
	
	if event.event_type == XRToolsPointerEvent.Type.PRESSED and not is_tooltip:
		if in_animation:
			in_animation = false
			text_box.visible_characters = text_box.text.length()
		else:
			visible = false
			_remove_dialogue()
