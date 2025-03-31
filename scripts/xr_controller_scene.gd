extends XROrigin3D

# Handling hands and ghost hands
@onready var left_hand : XRToolsHand = $LeftHand/XRToolsCollisionHand/LeftHand
@onready var left_ghost_hand : XRToolsHand = $LeftHand/GhostHand
@onready var right_hand : XRToolsHand = $RightHand/XRToolsCollisionHand/RightHand
@onready var right_ghost_hand : XRToolsHand = $RightHand/GhostHand

# For handling weight of carried objects
@onready var left_collision_hand: XRToolsCollisionHand = $LeftHand/XRToolsCollisionHand
@onready var right_collision_hand: XRToolsCollisionHand = $RightHand/XRToolsCollisionHand
@onready var movement_direct: XRToolsMovementDirect = $LeftHand/XRToolsCollisionHand/MovementDirect
@onready var original_max_speed: float = movement_direct.max_speed

@export var max_carry_weight : float = 50.0


func _process(_delta):
	# Show our ghost hands when when our visible hands aren't where our hands are...
	if left_hand and left_ghost_hand:
		var offset = left_hand.global_position - left_ghost_hand.global_position
		left_ghost_hand.visible = offset.length() > 0.01

	if right_hand and right_ghost_hand:
		var offset = right_hand.global_position - right_ghost_hand.global_position
		right_ghost_hand.visible = offset.length() > 0.01
	
	_handle_carried_weight_movement()

# Sets speed based on the weight of the carried object
func _handle_carried_weight_movement():
	var speed_offset = clamp((max_carry_weight - (left_collision_hand._held_weight + right_collision_hand._held_weight)) / max_carry_weight, 
						0.0, 
						1.0)
	movement_direct.max_speed = original_max_speed * speed_offset
