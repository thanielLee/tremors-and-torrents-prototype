extends RigidBody3D

### CONFIGURABLES ###
@export var active: bool = false
@export var assist_required: bool = false
@export var assist_duration: float = 1.5  # seconds both hands must be held
@export var follow_strength: float = 5.0
@export var assist_grace_period: float = 5.0  # seconds before assist action fails
@export var snap_offset: Vector3 = Vector3(-0.7, 0.0, 0.0) 

### REFERENCES ###
@onready var mesh: Node3D = $Mesh
@onready var left_assist_area: Area3D = $AssistAreas/LeftAssistArea
@onready var right_assist_area: Area3D = $AssistAreas/RightAssistArea

### STATE ###
var following: bool = false
var target_node: Node3D = null
var left_hand_ready: bool = false
var right_hand_ready: bool = false
var assist_timer: float = 0.0
var grace_timer: float = 0.0
var assist_complete: bool = false
var grace_active: bool = false

### SIGNALS ###
signal victim_triggered_hazard
signal victim_safe
signal assist_started
signal assist_completed
signal assist_lost

### LIFECYCLE ###
func _ready() -> void:
	if left_assist_area:
		left_assist_area.body_entered.connect(_on_left_hand_entered)
		left_assist_area.body_exited.connect(_on_left_hand_exited)
	
	if right_assist_area:
		right_assist_area.body_entered.connect(_on_right_hand_entered)
		right_assist_area.body_exited.connect(_on_right_hand_exited)

func _physics_process(delta) -> void:
	if not active:
		return
	
	if assist_required and not assist_complete:
		_update_assist_progress(delta)
		return
	
	# handle grace timer if player loses contact
	if grace_active:
		_update_grace_timer(delta)
	
	# follow target if active
	if following and target_node:
		_follow_target(delta)

func _follow_target(delta):
	var target_position = target_node.global_transform.origin + target_node.global_transform.basis * snap_offset
	var direction = target_position - global_transform.origin
	var distance = direction.length()
	
	# move if not too close to player
	if distance > 0.5:
		var force = direction.normalized() * follow_strength
		apply_central_force(force)
	
	# slowly align rotation with player forward dir
	var target_rot = target_node.global_transform.basis.get_euler().y
	var current_rot = rotation.y
	rotation.y = lerp_angle(current_rot, target_rot, delta * 2.0)

func _update_assist_progress(delta):
	if left_hand_ready and right_hand_ready:
		assist_timer += delta
		if assist_timer >= assist_duration and not assist_complete:
			assist_complete = true
			grace_active = false
			emit_signal("assist_completed")
			print("assist complete, can move")
			
			_snap_to_player()
	else:
		if assist_timer > 0.0:
			_start_grace_period()
		assist_timer = 0.0

func _start_grace_period():
	grace_active = true
	grace_timer = assist_grace_period
	print("assist lost, grace period started")

func _update_grace_timer(delta):
	grace_timer -= delta
	if grace_timer <= 0.0:
		grace_active = false
		assist_complete = false
		following = false
		emit_signal("assist_lost")
		print("grace period expired, stop move")

func _snap_to_player():
	if not target_node:
		return
	var target_transform = target_node.global_transform
	var snap_position = target_transform.origin + target_transform.basis * snap_offset
	global_transform.origin = snap_position
	rotation.y = target_transform.basis.get_euler().y
	following = true
	
### DETECTION EVENTS ###
func _on_detection_area_area_entered(area: Area3D) -> void:
	print(area)
	if area.get_parent().get_script() == Hazard:
		emit_signal("victim_triggered_hazard")
	else:
		emit_signal("victim_safe")
		following = false

func _on_detection_area_body_entered(body: Node3D) -> void:
	if not active:
		return
	if assist_complete:
		target_node = body
		print("following player")

### HAND EVENTS ###
func _on_left_hand_entered(body: Node3D):
	if body is not XRController3D:
		return
	print("left body entered")
	if body.get_tracker_hand() == XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT:
		left_hand_ready = true
		#emit_signal("assist_started")
		print("left hand entered")
		
func _on_left_hand_exited(body: Node3D):
	if body is not XRController3D:
		return
	if body.get_tracker_hand() == XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT:
		left_hand_ready = false
		print("left hand exited")
		
func _on_right_hand_entered(body: Node3D):
	if body is not XRController3D:
		return
	print("right body entered")
	if body.get_tracker_hand() == XRPositionalTracker.TrackerHand.TRACKER_HAND_RIGHT:
		right_hand_ready = true
		#emit_signal("assist_started")
		print("right hand entered")

func _on_right_hand_exited(body: Node3D):
	if body is not XRController3D:
		return
	if body.get_tracker_hand() == XRPositionalTracker.TrackerHand.TRACKER_HAND_RIGHT:
		right_hand_ready = false
		print("right hand exited")
