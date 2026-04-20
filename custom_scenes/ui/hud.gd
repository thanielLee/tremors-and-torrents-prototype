extends CanvasLayer
class_name HUD

@export var prompt_duration := 3.0

@onready var timer_label = $Control/TimerPanel/VBox/TimerLabel
@onready var score_label = $Control/ScorePanel/VBox/ScoreLabel
@onready var prompt_label = $Control/PromptPanel/PromptLabel
@onready var level_panel = $Control/LevelPanel
@onready var level_label = $Control/LevelPanel/VBox/LevelLabel
@onready var reason_label = $Control/LevelPanel/VBox/ReasonLabel
@onready var obj_panel = $Control/ObjPanel
@onready var obj_name_label = $Control/ObjPanel/VBox/ObjNameLabel
@onready var obj_status_label = $Control/ObjPanel/VBox/StatusRow/ObjStatusLabel
@onready var obj_feedback_label = $Control/ObjPanel/VBox/ObjFeedbackLabel
@onready var status_dot = $Control/ObjPanel/VBox/StatusRow/StatusDot
@onready var prompt_panel = $Control/PromptPanel
@onready var prompt_timer = Timer.new()

var elapsed_time: float = 0.0

func _ready():
	add_child(prompt_timer)
	prompt_timer.one_shot = true
	prompt_timer.timeout.connect(_on_prompt_timeout)
	prompt_panel.modulate.a = 0.0
	prompt_panel.visible = false
	level_panel.modulate.a = 0.0
	level_panel.visible = false
	obj_panel.modulate.a = 0.0
	obj_panel.visible = false
	timer_label.text = "00:00"
	score_label.text = "0"

# -----------------------
# FADE HELPERS
# -----------------------
func _fade_in(node: Control, duration: float = 0.2):
	node.modulate.a = 0.0
	node.visible = true
	var tw = create_tween()
	tw.tween_property(node, "modulate:a", 1.0, duration).set_ease(Tween.EASE_OUT)

func _fade_out(node: Control, duration: float = 0.15) -> void:
	var tw = create_tween()
	tw.tween_property(node, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	await tw.finished
	node.visible = false

# -----------------------
# TIMER
# -----------------------
func set_timer(time: float):
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func reset_timer():
	timer_label.text = "00:00"

func hide_timer():
	$Control/TimerPanel.hide()

func show_timer():
	$Control/TimerPanel.show()

# -----------------------
# SCORE
# -----------------------
func update_score(new_score: int):
	score_label.text = "%d" % new_score

# -----------------------
# PROMPTS
# -----------------------
func show_prompt(text: String, duration: float = prompt_duration):
	prompt_label.text = text
	prompt_timer.stop()
	_fade_in(prompt_panel, 0.15)
	prompt_timer.start(duration)

func _on_prompt_timeout():
	_fade_out(prompt_panel, 0.2)

# -----------------------
# OBJECTIVE / QTE SHARED
# -----------------------
func _open_obj_panel(obj: ObjectiveBase):
	obj_name_label.text = obj.objective_name
	obj_feedback_label.text = ""
	obj_status_label.text = ""
	status_dot.color = Color(0.39, 0.63, 1.0, 0.0) # hidden initially
	_fade_in(obj_panel, 0.25)
	show_prompt(obj.objective_name + " started!", 2.0)

func _close_obj_panel():
	await get_tree().create_timer(2.0).timeout
	_fade_out(obj_panel, 0.25)

# -----------------------
# QTE
# -----------------------
func on_qte_started(obj: ObjectiveBase):
	_open_obj_panel(obj)

func on_qte_completed(obj: ObjectiveBase):
	obj_feedback_label.text = obj.completed_message
	obj_feedback_label.add_theme_color_override("font_color", Color(0.47, 0.87, 0.67))
	show_prompt("Success!", 2.0)
	await _close_obj_panel()

func on_qte_failed(obj: ObjectiveBase):
	obj_feedback_label.text = obj.fail_message
	obj_feedback_label.add_theme_color_override("font_color", Color(0.90, 0.40, 0.40))
	show_prompt("Failed!", 2.0)
	await _close_obj_panel()

func update_qte_status_label(status: bool):
	if status:
		obj_status_label.text = "Hold that position!"
		obj_status_label.add_theme_color_override("font_color", Color(0.47, 0.87, 0.67))
		status_dot.color = Color(0.47, 0.87, 0.67, 1.0)
	else:
		obj_status_label.text = "Get back into position!"
		obj_status_label.add_theme_color_override("font_color", Color(0.90, 0.40, 0.40))
		status_dot.color = Color(0.90, 0.40, 0.40, 1.0)

# -----------------------
# OBJECTIVE
# -----------------------
func on_obj_started(obj: ObjectiveBase):
	_open_obj_panel(obj)

func on_obj_completed(obj: ObjectiveBase):
	obj_feedback_label.text = obj.completed_message
	obj_feedback_label.add_theme_color_override("font_color", Color(0.47, 0.87, 0.67))
	show_prompt("Success!", 2.0)
	await _close_obj_panel()

func on_obj_failed(obj: ObjectiveBase):
	obj_feedback_label.text = obj.fail_message
	obj_feedback_label.add_theme_color_override("font_color", Color(0.90, 0.40, 0.40))
	show_prompt("Failed!", 2.0)
	await _close_obj_panel()

func update_obj_status_label(time: float):
	obj_feedback_label.text = "%.2f" % time

func hide_obj_container():
	if obj_panel.visible:
		_fade_out(obj_panel, 0.15)

# -----------------------
# LEVEL RESULT
# -----------------------
func _set_level_panel_style(success: bool):
	var sb: StyleBoxFlat = level_panel.get_theme_stylebox("panel").duplicate()
	if success:
		sb.bg_color = Color(0.03, 0.12, 0.08, 0.82)
		sb.border_color = Color(0.30, 0.75, 0.50, 0.70)
	else:
		sb.bg_color = Color(0.12, 0.03, 0.03, 0.82)
		sb.border_color = Color(0.85, 0.30, 0.30, 0.70)
	level_panel.add_theme_stylebox_override("panel", sb)

func on_level_succeeded(score: float):
	_set_level_panel_style(true)
	level_label.text = "Level Completed!"
	level_label.add_theme_color_override("font_color", Color(0.47, 0.87, 0.67))
	reason_label.text = "Final Score: %s" % score
	reason_label.add_theme_color_override("font_color", Color(0.70, 0.95, 0.80))
	reason_label.visible = true
	_fade_in(level_panel, 0.4)
	await get_tree().create_timer(5.0).timeout
	_fade_out(level_panel, 0.3)

func on_level_failed(message: String):
	_set_level_panel_style(false)
	level_label.text = "Level Failed"
	level_label.add_theme_color_override("font_color", Color(0.90, 0.40, 0.40))
	reason_label.text = message
	reason_label.add_theme_color_override("font_color", Color(0.95, 0.65, 0.65))
	reason_label.visible = true
	_fade_in(level_panel, 0.4)
	await get_tree().create_timer(5.0).timeout
	_fade_out(level_panel, 0.3)

func prompt_reason_label(message: String):
	reason_label.text = message
	reason_label.add_theme_color_override("font_color", Color(0.90, 0.40, 0.40))

func end_level_prompt(success: bool, score: int, message: String = ""):
	if success:
		await on_level_succeeded(score)
	else:
		await on_level_failed(message)
