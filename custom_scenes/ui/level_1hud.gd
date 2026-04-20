extends CanvasLayer
class_name Level1HUD

@export var prompt_duration := 3.0

@onready var timer_label: Label = $Control/TimerPanel/VBox/TimerLabel
@onready var prompt_panel: PanelContainer = $Control/PromptPanel
@onready var prompt_label: Label = $Control/PromptPanel/PromptLabel
@onready var obj_panel: PanelContainer = $Control/ObjPanel
@onready var obj_name_label: Label = $Control/ObjPanel/VBox/ObjNameLabel
@onready var obj_status_label: Label = $Control/ObjPanel/VBox/StatusRow/ObjStatusLabel
@onready var obj_feedback_label: Label = $Control/ObjPanel/VBox/ObjFeedbackLabel
@onready var status_dot: ColorRect = $Control/ObjPanel/VBox/StatusRow/StatusDot
@onready var prompt_timer = Timer.new()

func _ready():
	add_child(prompt_timer)
	prompt_timer.one_shot = true
	prompt_timer.timeout.connect(_on_prompt_timeout)
	prompt_panel.modulate.a = 0.0
	prompt_panel.visible = false
	obj_panel.modulate.a = 0.0
	obj_panel.visible = false
	$Control/TimerPanel.visible = false
	timer_label.text = "00:00"

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
	$Control/TimerPanel.visible = false

func show_timer():
	$Control/TimerPanel.visible = true

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
# OBJECTIVE
# -----------------------
func on_obj_started(obj: ObjectiveBase):
	obj_name_label.text = obj.objective_name
	obj_feedback_label.text = ""
	obj_status_label.text = ""
	status_dot.color = Color(0.39, 0.63, 1.0, 0.0)
	_fade_in(obj_panel, 0.25)
	show_prompt(obj.objective_name + " Started!", 2.0)

func on_obj_completed(obj: ObjectiveBase):
	obj_feedback_label.text = obj.objective_name + " Completed!"
	obj_feedback_label.add_theme_color_override("font_color", Color(0.47, 0.87, 0.67))
	obj_status_label.text = ""
	show_prompt("Success!", 2.0)
	await get_tree().create_timer(2.0).timeout
	await _fade_out(obj_panel, 0.25)
	hide_timer()

func on_obj_failed(obj: ObjectiveBase):
	obj_feedback_label.text = obj.objective_name + " Failed!"
	obj_feedback_label.add_theme_color_override("font_color", Color(0.90, 0.40, 0.40))
	obj_status_label.text = ""
	show_prompt("Failed!", 2.0)
	hide_timer()
	await get_tree().create_timer(2.0).timeout
	await _fade_out(obj_panel, 0.25)

func update_obj_status_label(time: float):
	timer_label.text = "%.2f" % time

func hide_obj_container():
	if obj_panel.visible:
		_fade_out(obj_panel, 0.15)

func update_qte_status_label(status: bool):
	if status:
		obj_status_label.text = "Hold that position!"
		obj_status_label.add_theme_color_override("font_color", Color(0.47, 0.87, 0.67))
		status_dot.color = Color(0.47, 0.87, 0.67, 1.0)
	else:
		obj_status_label.text = "Get back into position!"
		obj_status_label.add_theme_color_override("font_color", Color(0.90, 0.40, 0.40))
		status_dot.color = Color(0.90, 0.40, 0.40, 1.0)
