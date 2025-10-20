extends Node3D
class_name QuickTimeEvent

signal qte_started
signal qte_completed
signal qte_failed

@export var duration: float = 5.0 # optional timeout
@export var required_progress: float = 1.0

var current_progress: float = 0.0
var active: bool = false
var timer: float = 0.0

#@onready var area: Area3D = $Area3D
#@onready var progress_bar: Node3D = $ProgressBar3D

func _ready():
	#area.body_entered.connect(_on_body_entered)
	#area.body_exited.connect(_on_body_exited)
	set_process(false)

func _process(delta):
	if not active:
		return
	
	timer += delta
	if timer > duration:
		fail_qte()
		return
	
	#update_progress_display()

func _on_body_entered(body):
	if not active and _is_player(body):
		start_qte()

func _on_body_exited(body):
	if active and _is_player(body):
		cancel_qte()

func _is_player(body) -> bool:
	return body.name == "Player" # adjust based on your player node name

func start_qte():
	active = true
	timer = 0
	current_progress = 0
	set_process(true)
	emit_signal("qte_started")

func add_progress(amount: float):
	if not active:
		return
	
	current_progress = clamp(current_progress + amount, 0, required_progress)
	if current_progress >= required_progress:
		complete_qte()

func complete_qte():
	active = false
	set_process(false)
	emit_signal("qte_completed")

func fail_qte():
	active = false
	set_process(false)
	emit_signal("qte_failed")

func cancel_qte():
	active = false
	set_process(false)

#func update_progress_display():
	#if progress_bar:
		#progress_bar.scale.x = current_progress / required_progress
