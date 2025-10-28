extends Node3D

signal start_assist(npc)

var is_carrying = false

func prepare_for_carry():
	is_carrying = true
	emit_signal("start_assist", self)
	# TODO: play animation
