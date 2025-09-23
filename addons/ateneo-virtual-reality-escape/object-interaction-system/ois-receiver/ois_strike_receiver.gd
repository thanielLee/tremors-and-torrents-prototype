@tool
class_name OISStrikeReceiver
extends OISReceiverComponent

@export var strike_range : float = 1
var interacting_initial_pos : Vector3
var actor_receiver_starting_dist : float
var hit_already : bool = false
var time_start : float

signal rumble_hand(controller)

func initialize_action_vars():
	interacting_initial_pos = interacting_object.position
	actor_receiver_starting_dist = position.distance_to(interacting_initial_pos)
	hit_already = false
	time_start = Time.get_ticks_usec()


func action_ongoing(delta: float) -> void:
	var interacting_current_pos = interacting_object.position
	var actor_receiver_dist = position.distance_to(interacting_current_pos)
	var actor_start_end_dist = interacting_initial_pos.distance_to(interacting_current_pos)
	
	if (not hit_already and actor_receiver_dist < strike_range) and (actor_receiver_dist < actor_receiver_starting_dist):
		var time_end = Time.get_ticks_usec()
		var time_total = (time_end - time_start) / 1000
		var current_progress = actor_start_end_dist / time_total
		
		total_progress += current_progress * rate
		hit_already = true
		
		## RUMBLE
		var pickable := interacting_object as XRToolsPickable
		if pickable:
			var controller := pickable.get_picked_up_by_controller()
			if controller:
				emit_signal("rumble_hand", controller)
				#XRToolsRumbleManager.start_rumble(controller, {
					#"amplitude": 0.7, # from 0.0 to 1.0
					#"duration": 0.2 # seconds
				#})
		
		print("=======================")
		print("Strike Speed: " + str(current_progress) + "m/s") # test value, delete in future
		print("Total progress: " + str(total_progress))
		print("=======================\n")
		
		super(delta)
