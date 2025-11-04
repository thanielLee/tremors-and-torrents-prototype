extends Node3D

@export var target : Node3D

func ready():
	target.start_assist.connect(_on_start_assist)

func _on_start_assist(target):
	pass
