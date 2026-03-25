extends MeshInstance3D
class_name FloodPlane

var material: ShaderMaterial
var noise: Image

var noise_scale: float
var wave_speed: float
var height_scale: float

var time: float

var flood_speed : float = 0.2
var is_currently_flooding : bool = false
var start_y : float
var end_y : float

func _ready():
	material = get_surface_override_material(0)
	noise = material.get_shader_parameter("wave").noise.get_seamless_image(512, 512)
	noise_scale = material.get_shader_parameter("noise_scale")
	wave_speed = material.get_shader_parameter("time_scale")
	height_scale = material.get_shader_parameter("height_scale")
	
	start_y = position.y

func _process(delta):
	time += delta
	material.set_shader_parameter("wave_time", time)
	
	if is_currently_flooding:
		if position.y + flood_speed * delta >= end_y:
			position.y = end_y
			is_currently_flooding = false
		else:
			position.y += flood_speed * delta

func start_flooding(flood_height : float):
	is_currently_flooding = true
	end_y = start_y + flood_height
	
func get_height(world_position: Vector3) -> float:
	var uv_x = wrapf(world_position.x / noise_scale + time * wave_speed, 0, 1)
	var uv_y = wrapf(world_position.z / noise_scale + time * wave_speed, 0, 1)
	
	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	return global_position.y + noise.get_pixelv(pixel_pos).r * height_scale	
