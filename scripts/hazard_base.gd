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

var triggered: bool = false

func _ready() -> void:
	pass # Replace with function body.

func _on_detection_area_body_entered(body: Node3D) -> void:
	hazard_triggered.emit()
	audio_player.play()
