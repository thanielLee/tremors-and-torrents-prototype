extends Area3D

@export var trauma_reduction_rate = 1.0
@export var noise: FastNoiseLite
@export var noise_speed = 50.0

@export var max_x = 10.0
@export var max_y = 10.0
@export var max_z = 5.0

var trauma = 0.0

var time = 0.0

@onready var camera = $".."

var initial_rotation: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_rotation = camera.rotation_degrees as Vector3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	trauma = max(trauma-delta*trauma_reduction_rate, 0.0)
	time += delta
	
	camera.rotation_degrees.x += max_x * get_shake_intensity() * get_noise_from_seed(0)
	camera.rotation_degrees.y += max_y * get_shake_intensity() * get_noise_from_seed(1)
	camera.rotation_degrees.z += max_z * get_shake_intensity() * get_noise_from_seed(2)
	
	print(camera.rotation_degrees.x, camera.rotation_degrees.y, camera.rotation_degrees.z)
	

func add_trauma(trauma_amount: float):
	trauma = clamp(trauma+trauma_amount, 0.0, 1.0)
	print("TRAUMA IS HAPPENING")
	
func get_shake_intensity():
	return trauma*trauma

func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
