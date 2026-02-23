extends XRToolsFunctionPickup
class_name AlwaysUpPickup



func _process(delta: float) -> void:
	global_rotation.x = 0
	global_rotation.z = 0
	super(delta)
