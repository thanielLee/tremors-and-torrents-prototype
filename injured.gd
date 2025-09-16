extends Node3D

signal injured_cleared()
@onready var mesh: Node3D = $Mesh


func _ready() -> void:
	#if EventManager.completed_events.has("ActionRemoveJammedDoor_Done"):
		#queue_free()
	pass

func _on_ois_twist_receiver_action_started(requirement: Variant, total_progress: Variant) -> void:
	print("twist started")


func _on_ois_twist_receiver_action_in_progress(requirement: Variant, total_progress: Variant) -> void:
	print("twist in progress")

func _on_ois_twist_receiver_action_ended(requirement: Variant, total_progress: Variant) -> void:
	print("twist stopped")

func _on_ois_twist_receiver_action_completed(requirement: Variant, total_progress: Variant) -> void:
	emit_signal("injured_cleared")
	bandage_complete()
	#mesh.visible = false
	#queue_free()

func bandage_complete():
	var armMesh : MeshInstance3D = $Mesh/ArmMesh
	var material := armMesh.get_surface_override_material(0)
	
	# If mesh has no material
	if material == null:
		material = StandardMaterial3D.new()
		armMesh.set_surface_override_material(0, material)
	
	material.albedo_color = Color.YELLOW
