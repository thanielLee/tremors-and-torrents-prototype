extends ObjectiveBase
class_name QuickTimeEvent

signal qte_started

@export var duration: float = 10.0 # optional timeout
@export var required_progress: float = 1.0
@export var one_shot: bool = false

var current_progress: float = 0.0
var timer: float = 0.0
var done: int = 0

func _ready():
	super._ready()
	set_process(false)

func _process(delta):
	if not active:
		return
	
	timer += delta
	if timer > duration:
		if current_progress >= required_progress:
			complete_objective()
		else:
			fail_objective()

func start_objective():
	if one_shot and done > 0:
		return
	super.start_objective()
	timer = 0
	current_progress = 0
	set_process(true)
	emit_signal("qte_started")
	

func add_progress(amount: float):
	if not active:
		return
	
	current_progress = clamp(current_progress + amount, 0, required_progress)
	#print("current_progress: ", current_progress)
	# if current_progress >= required_progress:
	# 	complete_objective()

func reset_progress():
	current_progress = 0

func complete_objective():
	super.complete_objective()
	done += 1
	set_process(false)

func fail_objective():
	super.fail_objective()
	done += 1
	set_process(false)
