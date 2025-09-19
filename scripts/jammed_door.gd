extends Node3D

signal door_cleared()

@onready var mesh: Node3D = $Mesh
@onready var break_door_sound: AudioStreamPlayer3D = $BreakDoorSound
@onready var break_sound: AudioStreamPlayer3D = $BreakSound
@onready var hit_points: Node3D = $HitPoints
@onready var hit_sound: AudioStreamPlayer3D = $HitSound

var hit_point_count : int


func _ready() -> void:
	hit_point_count = hit_points.get_child_count()
	
	for hit_point in hit_points.get_children():
		for child in hit_point.get_children():
			if child is OISStrikeReceiver:
				child.action_completed.connect(_on_hit_point_completed.bind(hit_point)) # for hit point desrtoyed
				child.action_started.connect(_on_hit_point_started)
		

func check_finished():
	if hit_point_count <= 0:
		print("Door cleared")
		emit_signal("door_cleared")
		mesh.visible = false
		# TODO: implement break door sound and particles

func _on_hit_point_started(requirement: Variant, total_progress: Variant) -> void:
	if hit_sound and not hit_sound.playing:
		hit_sound.play()
	## TODO: implement hit particles

func _on_hit_point_completed(requirement: Variant, total_progress: Variant, hit_point: Node) -> void:
	print("HitPoint cleared: ", hit_point.name)
	
	hit_point.queue_free()
	hit_point_count -= 1
	
	if break_sound:
		break_sound.play()
	
	check_finished()


func _on_break_door_sound_finished() -> void:
	queue_free()
