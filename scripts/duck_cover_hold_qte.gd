extends QuickTimeEvent

@export var head_threshold_y := 1.2
@export var hand_distance_threshold := 0.4
@export var hold_duration := 5.0

@onready var xr_origin = get_node("XROrigin3D")
@onready var camera = xr_origin.get_node("XRCamera3D")
@onready var left_hand = xr_origin.get_node("LeftHand")
@onready var right_hand = xr_origin.get_node("RightHand")
@onready var hold_timer = $Timer

var is_holding_pose := false

func _ready():
	super._ready()
	hold_timer.wait_time = hold_duration
	hold_timer.one_shot = true
	hold_timer.timeout.connect(_on_hold_success)
	set_process(false)

func start_qte():
	super.start_qte()
	set_process(true)
	print("Duck and hold QTE started")

func _process(delta):
	if not active:
		return
	
	var head_y = camera.global_position.y
	var hand_distance = left_hand.global_position.distance_to(right_hand.global_position)
	
	var is_ducked = head_y < head_threshold_y
	var is_holding = hand_distance < hand_distance_threshold
	
	print("is_ducked:", is_ducked)
	print("is_holding:", is_holding)
	
	if is_ducked and is_holding:
		if not is_holding_pose:
			is_holding_pose = true
			hold_timer.start()
			print("Holding posture detected")
	else:
		if is_holding_pose:
			is_holding_pose = false
			hold_timer.stop()
			print("Lost holding posture")
	
	super._process(delta)

func _on_hold_success():
	if not active:
		return
	print("Duck and hold QTE completed")
	complete_qte()
