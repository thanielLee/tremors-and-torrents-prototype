extends Node3D
class_name FireVFX

var particle_array: Array[GPUParticles3D]

func _ready() -> void:
	for child in get_children():
		if child is GPUParticles3D:
			particle_array.push_back(child)

func stop_emitting() -> void:
	for particle in particle_array:
		particle.emitting = false
