extends Node3D

signal injured_cleared
@onready var mesh: Node3D = $Mesh
@onready var bandage_stages := [
	$BandageStage0,
	$BandageStage1,
	$BandageStage2
]
var current_stage : int

func _ready() -> void:
	for stage in bandage_stages:
		stage.visible = false
	current_stage = -1
	
func _on_ois_twist_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	print("twist started")
	#var progress_ratio = clamp(total_progress / float(requirement), 0.0, 1.0)
	#
	##bandage.scale = Vector3(1, lerp(0.01, 1.0, progress_ratio), 1)
	#_on_ois_twist_receiver_action_in_progress(requirement, total_progress)


func _on_ois_twist_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	#print("twist in progress")
	var progress_ratio = clamp(total_progress / float(requirement), 0.0, 1.0)
	
	var new_stage := -1
	if progress_ratio >= 1.0:
		new_stage = 2
	elif progress_ratio >= 0.5:
		new_stage = 1
	elif progress_ratio >= 0.1:
		new_stage = 0
	
	if new_stage != current_stage:
		bandage_stages[current_stage].visible = false
		bandage_stages[new_stage].visible = true
		current_stage = new_stage

func _on_ois_twist_receiver_action_ended(requirement: Variant, total_progress: Variant) -> void:
	print("twist stopped")

func _on_ois_twist_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void:
	emit_signal("injured_cleared")
	print("bandage complete")
