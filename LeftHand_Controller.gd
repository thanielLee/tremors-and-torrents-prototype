extends XRController3D
var activePointedObject = null
func _ready() -> void:
	connect("button_pressed", btn_PressedOn_LeftCntrler)
	connect("button_pressed", btn_ReleasedOn_LeftCntrler)
	
func _physics_process(delta: float) -> void:
	if $RayCast3D.is_colliding():
		print("is colliding")
		var c = $RayCast3D.get_collider()
		activePointedObject = c
	else:
		activePointedObject = null
		
func btn_PressedOn_LeftCntrler(name:String) -> void:
	print(name)
	if name == "trigger_click":
		if activePointedObject:
			activePointedObject.queue_free()

func btn_ReleasedOn_LeftCntrler(name:String) -> void:
	if name == "trigger_click":
		pass
