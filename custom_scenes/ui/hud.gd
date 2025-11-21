extends CanvasLayer
class_name HUD

@export var prompt_duration := 3.0
@onready var timer_label = $Control/TimerLabel
@onready var prompt_label = $Control/PromptLabel
@onready var qte_container = $Control/QTEContainer
@onready var qte_name_label = $Control/QTEContainer/QTENameLabel
@onready var qte_progress = $Control/QTEContainer/QTEProgress
@onready var qte_feedback_label = $Control/QTEContainer/QTEFeedbackLabel
@onready var prompt_timer = Timer.new()

# Timer
var time_remaining: float = 0.0
var timer_active: bool = false

# QTE
var active_qte: Node = null

func _ready():
	add_child(prompt_timer)
	prompt_timer.one_shot = true
	prompt_timer.timeout.connect(_on_prompt_timeout)

	prompt_label.visible = false
	qte_container.visible = false
	timer_label.text = "Time: 00:00"

# -----------------------
# LEVEL TIMER
# -----------------------
func set_timer(time: float):
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

#func update_timer(delta: float):
	#if not timer_active:
		#return
	#time_remaining = max(0.0, time_remaining - delta)
	#_update_timer_label()
	#if time_remaining <= 0.0:
		#timer_active = false
		#emit_signal("timer_finished")
#
#func _update_timer_label():
	#var minutes = int(time_remaining / 60)
	#var seconds = int(time_remaining) % 60
	#timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

# -----------------------
# PROMPTS
# -----------------------
func show_prompt(text: String, duration: float = prompt_duration):
	prompt_label.text = text
	prompt_label.visible = true
	prompt_timer.start(duration)

func _on_prompt_timeout():
	prompt_label.visible = false


# Called when QTE begins
func on_qte_started(obj: Node):
	var name = obj.name
	qte_container.visible = true
	qte_progress.value = 0
	qte_feedback_label.text = ""
	qte_name_label.text = name
	show_prompt("QTE Started!", 2.0)

func on_qte_completed():
	qte_feedback_label.text = "QTE Completed!"
	qte_feedback_label.add_theme_color_override("font_color", Color.GREEN)
	show_prompt("Success!", 2.0)
	await get_tree().create_timer(2.0).timeout
	qte_container.visible = false

func on_qte_failed():
	qte_feedback_label.text = "QTE Failed!"
	qte_feedback_label.add_theme_color_override("font_color", Color.RED)
	show_prompt("Failed!", 2.0)
	await get_tree().create_timer(2.0).timeout
	qte_container.visible = false
