extends XRToolsPickable
class_name Stretcher


var total_hands: int = 0


func _ready() -> void:
	set_process(true)
	super()
	
func _process(delta: float) -> void:
	pass
	
func pick_up(by: Node3D) -> void:
	# Skip if not enabled
	if not enabled:
		return
		
	if _grab_points.size() != 2:
		return

	# Find the grabber information
	var grabber := Grabber.new(by)

	# Test if we're already picked up:
	if is_picked_up():
		# Ignore if we don't support second-hand grab
		if second_hand_grab == SecondHandGrab.IGNORE:
			print_verbose("%s> second-hand grab not enabled" % name)
			return

		# Ignore if either pickup isn't by a hand
		if not _grab_driver.primary.pickup or not grabber.pickup:
			return

		# Construct the second grab
		if second_hand_grab != SecondHandGrab.SWAP:
			# Grab the object
			var by_grab_point := _get_grab_point(by, _grab_driver.primary.point)
			var grab := Grab.new(grabber, self, by_grab_point, true)
			_grab_driver.add_grab(grab)

			# Report the secondary grab
			grabbed.emit(self, by)
			return

		# Swapping hands, let go with the primary grab
		print_verbose("%s> letting go to swap hands" % name)
		let_go(_grab_driver.primary.by, Vector3.ZERO, Vector3.ZERO)

	# Remember the mode before pickup
	match release_mode:
		ReleaseMode.UNFROZEN:
			restore_freeze = false

		ReleaseMode.FROZEN:
			restore_freeze = true

		_:
			restore_freeze = freeze

	# turn off physics on our pickable object
	freeze = true
	collision_layer = picked_up_layer
	collision_mask = 0

	# Find a suitable primary hand grab
	var by_grab_point := _get_grab_point(by, null)

	# Construct the grab driver
	if by.picked_up_ranged:
		if ranged_grab_method == RangedMethod.LERP:
			var grab := Grab.new(grabber, self, by_grab_point, false)
			_grab_driver = XRToolsGrabDriver.create_lerp(self, grab, ranged_grab_speed)
		else:
			var grab := Grab.new(grabber, self, by_grab_point, false)
			_grab_driver = XRToolsGrabDriver.create_snap(self, grab)
	else:
		var grab := Grab.new(grabber, self, by_grab_point, true)
		print('WHAT ' + str(by_grab_point))
		_grab_driver = XRToolsGrabDriver.create_snap(self, grab)

	# Report picked up and grabbed
	picked_up.emit(self)
	grabbed.emit(self, by)
