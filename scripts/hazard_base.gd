class_name Hazard
extends Node3D

## Hazard Base Script
## 
## This is our base scene for all our hazards (still WIP)
## It will contain all of the needed things for hazards in levels
## 
## This script is meant to be extneded to create custom scripts for
## each type of hazard

signal hazard_triggered

@export var hazard_name: String
@export var penalty_points: int = 0
@export var resolved_points: int = 0
@export var damage_points: int = 0

@onready var audio_player : AudioStreamPlayer3D = $OnTriggerAudio
var scene_base: Level2

var triggered: bool = false
var is_active: bool = true

func _ready() -> void:
	#var cur_node = get_parent_node_3d()
	#
	#while cur_node is not Level2:
		#cur_node = cur_node.get_parent_node_3d()
	#
	#scene_base = cur_node
	pass

func _on_detection_area_body_entered(body: Node3D) -> void:
	if !is_active:
		return
	print(body)
	hazard_triggered.emit()
	audio_player.play()

func _process(delta):
	if !is_active:
		$AmbientFireNoise.playing = false
		$AmbientFireNoise.autoplay = false
