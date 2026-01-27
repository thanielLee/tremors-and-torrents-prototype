extends ObjectiveBase

@onready var mesh: Node3D = $Mesh
@onready var bandage_stages := [
	$BandageStage0,
	$BandageStage1,
	$BandageStage2
]
var current_stage : int
@onready var bandage_sound_1: AudioStreamPlayer3D = $BandageSound1
@onready var bandage_sound_2: AudioStreamPlayer3D = $BandageSound2
var sounds


func _ready() -> void:
	for stage in bandage_stages:
		stage.visible = false
	current_stage = -1
	
	sounds = [bandage_sound_1, bandage_sound_2]
	
func _on_ois_twist_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	if enabled and not (completed or failed):
		start_objective()
		play_bandage_sound()

func _on_ois_twist_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	#print("twist in progress")
	if not active:
		return
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
	if not active:
		return

func _on_ois_twist_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void:
	if not active:
		return
	complete_objective()

func play_bandage_sound():
	var sound = sounds[randi() % sounds.size()]
	
	sound.pitch_scale = randf_range(0.9, 1.1)
	sound.volume_db = randf_range(-2.0, 0.0)
	
	if not sound.playing:
		sound.play()

func turn_off():
	$Mesh.visible = false
	bandage_stages[2].visible = false
