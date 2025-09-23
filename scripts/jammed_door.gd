extends Node3D

signal door_cleared()

@onready var mesh: Node3D = $Mesh
@onready var break_door_sound: AudioStreamPlayer3D = $BreakDoorSound
@onready var break_sound: AudioStreamPlayer3D = $BreakSound
@onready var hit_points: Node3D = $HitPoints
@onready var hit_sound: AudioStreamPlayer3D = $HitSound
@onready var break_particles: GPUParticles3D = $BreakParticles
var hit_point_count : int


# For rumble
@export var strike_rumble_event: XRToolsRumbleEvent
@export var break_rumble_event: XRToolsRumbleEvent
var last_controller: XRController3D = null


func _ready() -> void:
	hit_point_count = hit_points.get_child_count()
	
	for hit_point in hit_points.get_children():
		for child in hit_point.get_children():
			if child is OISStrikeReceiver:
				child.action_completed.connect(_on_hit_point_completed.bind(hit_point)) # for hit point desrtoyed
				child.action_started.connect(_on_hit_point_started)
				child.rumble_hand.connect(_on_rumble_hand)
		

func check_finished():
	if hit_point_count <= 0:
		print("Door cleared")
		emit_signal("door_cleared")
		mesh.visible = false
		break_door_sound.play()
		# TODO: implement break door sound and particles

func _on_hit_point_started(requirement: Variant, total_progress: Variant) -> void:
	if hit_sound and not hit_sound.playing:
		hit_sound.play()
	## TODO: implement hit particles

func _on_hit_point_completed(requirement: Variant, total_progress: Variant, hit_point: Node) -> void:
	print("HitPoint cleared: ", hit_point.name)
	
	break_particles.position = hit_point.position
	break_particles.emitting = true
	
	hit_point.queue_free()
	hit_point_count -= 1
	
	if break_sound:
		break_sound.play()
	
	if last_controller:
		XRToolsRumbleManager.add("door_break", break_rumble_event, [last_controller])
	
	check_finished()

## gets reference to controller first
func _on_rumble_hand(controller: XRController3D):
	last_controller = controller
	if strike_rumble_event:
		XRToolsRumbleManager.add("door_strike", strike_rumble_event, [last_controller])

func _on_break_door_sound_finished() -> void:
	queue_free()
