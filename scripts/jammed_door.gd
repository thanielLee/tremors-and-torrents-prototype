extends Node3D

signal door_cleared()
@onready var mesh: Node3D = $Mesh
@onready var break_sound: AudioStreamPlayer3D = $BreakSound


func _ready() -> void:
	#if EventManager.completed_events.has("ActionRemoveJammedDoor_Done"):
		#queue_free()
	pass

func _on_ois_strike_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void:
	emit_signal("door_cleared")
	mesh.visible = false
	

func _on_ois_strike_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	print("started")


func _on_break_sound_finished() -> void:
	queue_free()
