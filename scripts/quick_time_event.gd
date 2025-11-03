extends ObjectiveBase
class_name QuickTimeEvent

signal qte_started
#signal qte_completed
#signal qte_failed

#@export var enabled: bool = true
@export var duration: float = 10.0 # optional timeout
@export var required_progress: float = 1.0
#@export var completed_points: float = 5.0

var current_progress: float = 0.0
#var active: bool = false
var timer: float = 0.0

func _ready():
	super._ready()
	set_process(false)

func _process(delta):
	if not active:
		return
	
	timer += delta
	if timer > duration:
		fail_objective()
		return
	
	#update_progress_display()

func start_objective():
	super.start_objective()
	timer = 0
	current_progress = 0
	set_process(true)
	emit_signal("qte_started")
	

func add_progress(amount: float):
	if not active:
		return
	
	current_progress = clamp(current_progress + amount, 0, required_progress)
	print("current_progress: ", current_progress)
	if current_progress >= required_progress:
		complete_objective()

func reset_progress():
	current_progress = 0

#func complete_qte():
	#if not enabled:
		#return
	#enabled = false
	#active = false
	#set_process(false)
	#emit_signal("qte_completed")
	#emit_signal("objective_completed")
func complete_objective():
	super.complete_objective()
	set_process(false)

func fail_objective():
	super.fail_objective()
	set_process(false)

#func fail_qte():
	#enabled = false
	#active = false
	#set_process(false)
	#emit_signal("qte_failed")
	#emit_signal("objective_failed")

#func update_progress_display():
	#if progress_bar:
		#progress_bar.scale.x = current_progress / required_progress
