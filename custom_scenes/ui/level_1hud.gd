extends CanvasLayer
class_name Level1HUD

@export var prompt_duration := 3.0
@onready var prompt_label: Label = $Control/PromptLabel
@onready var reason_label: Label = $Control/ReasonLabel
@onready var timer_label: Label = $Control/TimerLabel
@onready var objective_container: VBoxContainer = $Control/ObjectiveContainer
@onready var objective_name_label: Label = $Control/ObjectiveContainer/ObjectiveNameLabel
@onready var objective_status_label: Label = $Control/ObjectiveContainer/ObjectiveStatusLabel
@onready var objective_feedback_label: Label = $Control/ObjectiveContainer/ObjectiveFeedbackLabel

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
	
	objective_container.visible = false
	prompt_label.visible = false
	timer_label.text = "Time: 00:00"

# -----------------------
# LEVEL TIMER
# -----------------------
func set_timer(time: float):
	print("in level1hud set timer")
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func reset_timer():
	timer_label.text = "Time: 00:00"

func hide_timer():
	timer_label.hide()

func show_timer():
	timer_label.visible = true
# -----------------------
# PROMPTS
# -----------------------
func show_prompt(text: String, duration: float = prompt_duration):
	prompt_label.text = text
	prompt_label.visible = true
	prompt_timer.start(duration)

func _on_prompt_timeout():
	prompt_label.visible = false

# -----------------------
# Objective
# -----------------------
func on_obj_started(obj: ObjectiveBase):
	objective_container.visible = true
	objective_name_label.text = obj.objective_name
	objective_feedback_label.text = ""
	objective_status_label.text = ""
	show_prompt(obj.objective_name + " Started!", 2.0)

func on_obj_completed(obj: ObjectiveBase):
	objective_feedback_label.text = obj.objective_name + " Completed!"
	objective_feedback_label.add_theme_color_override("font_color", Color.GREEN)
	show_prompt("Success!", 2.0)
	await get_tree().create_timer(2.0).timeout
	objective_container.visible = false

func on_obj_failed(obj: ObjectiveBase):
	objective_feedback_label.text = obj.objective_name + " Failed!"
	objective_feedback_label.add_theme_color_override("font_color", Color.RED)
	show_prompt("Success!", 2.0)
	await get_tree().create_timer(2.0).timeout
	objective_container.visible = false
