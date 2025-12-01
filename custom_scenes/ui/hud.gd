extends CanvasLayer
class_name HUD

@export var prompt_duration := 3.0
@onready var timer_label = $Control/TimerLabel
@onready var prompt_label = $Control/PromptLabel
@onready var level_label = $Control/LevelLabel
@onready var score_label = $Control/ScoreLabel
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
	level_label.visible = false
	qte_container.visible = false
	timer_label.text = "Time: 00:00"

# -----------------------
# LEVEL TIMER
# -----------------------
func set_timer(time: float):
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func reset_timer():
	timer_label.text = "Time: 00:00"

func hide_timer():
	timer_label.hide()

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
# QTE
# -----------------------
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

func update_qte_feedback_label():
	# TODO: implement
	pass

# -----------------------
# LEVEL PROMPTS
# -----------------------
func end_level_prompt(success: bool, score):
	if success:
		level_label.text = "Level Completed! Score: %s" % score 
		level_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		level_label.text = "Level Failed!"
		level_label.add_theme_color_override("font_color", Color.RED)
	level_label.visible = true
	score_label.visible = false
	await get_tree().create_timer(5.0).timeout
	level_label.visible = false

func update_score(new_score: int):
	score_label.text = "Score: %s" % new_score 
