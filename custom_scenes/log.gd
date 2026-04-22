extends CanvasLayer
class_name ResultLog

@onready var score_label: Label = $Control/BgPanel/HBox/LeftCol/LeftPad/LeftInner/ScoreValue
@onready var score_micro: Label = $Control/BgPanel/HBox/LeftCol/LeftPad/LeftInner/ScoreMicro
@onready var outcome_label: Label = $Control/BgPanel/HBox/LeftCol/LeftPad/LeftInner/OutcomeLabel
@onready var time_value: Label = $Control/BgPanel/HBox/LeftCol/LeftPad/LeftInner/MetaGrid/TimeValue
@onready var hazard_value: Label = $Control/BgPanel/HBox/LeftCol/LeftPad/LeftInner/MetaGrid/HazardValue
@onready var obj_list: VBoxContainer = $Control/BgPanel/HBox/RightCol/RightPad/RightInner/ObjList
@onready var exit_label: Label = $Control/ExitHint

# Pre-built objective row template labels — populated dynamically
var obj_font: FontFile
var obj_font_mono: FontFile

func _ready():
	pass

func log_results(data: Dictionary):
	var s_score: int = data.get("score", 0)
	var level_timer: float = data.get("level_timer", 0.0)
	var hazards: int = data.get("hazards_triggered", 0)
	var hazard_limit: int = data.get("hazard_limit", 2)
	var objectives: Array = data.get("objectives", [])
	var success: bool = data.get("success", false)

	# Score
	score_label.text = str(s_score)
	score_label.add_theme_color_override("font_color",
		Color(0.31, 0.78, 0.49) if s_score >= 100 else Color(0.86, 0.35, 0.35))

	# Outcome
	if success:
		outcome_label.text = "MISSION COMPLETE"
		outcome_label.add_theme_color_override("font_color", Color(0.31, 0.78, 0.49))
	else:
		outcome_label.text = "MISSION FAILED"
		outcome_label.add_theme_color_override("font_color", Color(0.86, 0.35, 0.35))

	# Time
	var minutes := int(level_timer / 60)
	var seconds := int(level_timer) % 60
	time_value.text = "%02d:%02d" % [minutes, seconds]

	# Hazards
	var hazard_str := ""
	for i in hazard_limit:
		hazard_str += ("■ " if i < hazards else "□ ")
	hazard_value.text = hazard_str
	hazard_value.add_theme_color_override("font_color",
		Color(0.86, 0.35, 0.35) if hazards > 0 else Color(0.55, 0.65, 0.80))

	# Clear old objective rows
	for child in obj_list.get_children():
		child.queue_free()

	# Build objective rows
	for obj in objectives:
		var status: String = obj.get("status", "missed")
		var name: String = obj.get("name", "Unknown")
		var required: bool = obj.get("required", false)
		var comp_time: float = obj.get("completion_time", 0.0)
		var pts: int = obj.get("points_earned", 0)

		var row := _make_obj_row(name, required, status, comp_time, pts)
		obj_list.add_child(row)

func _make_obj_row(
	name: String,
	required: bool,
	status: String,
	comp_time: float,
	pts: int
) -> HBoxContainer:

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)

	# Status dot
	var dot := Label.new()
	dot.text = "●"
	dot.custom_minimum_size = Vector2(24, 0)
	match status:
		"complete": dot.add_theme_color_override("font_color", Color(0.31, 0.78, 0.49))
		"failed":   dot.add_theme_color_override("font_color", Color(0.86, 0.35, 0.35))
		_:          dot.add_theme_color_override("font_color", Color(1, 1, 1, 0.18))
	dot.add_theme_font_size_override("font_size", 22)
	dot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(dot)

	# Objective name
	var name_label := Label.new()
	name_label.text = name
	name_label.add_theme_font_size_override("font_size", 26)
	name_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.90))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(name_label)

	# Tag (REQUIRED / OPTIONAL)
	var tag := Label.new()
	tag.text = "REQ" if required else "OPT"
	tag.add_theme_font_size_override("font_size", 16)
	tag.add_theme_color_override("font_color",
		Color(0.47, 0.60, 0.90) if required else Color(0.85, 0.72, 0.31))
	tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tag.custom_minimum_size = Vector2(52, 0)
	row.add_child(tag)

	# Time
	var time_label := Label.new()
	if status == "complete" or status == "failed":
		var m := int(comp_time / 60)
		var s := int(comp_time) % 60
		time_label.text = "%02d:%02d" % [m, s]
	else:
		time_label.text = "—"
	time_label.add_theme_font_size_override("font_size", 22)
	time_label.add_theme_color_override("font_color", Color(0.55, 0.62, 0.73))
	time_label.custom_minimum_size = Vector2(90, 0)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(time_label)

	# Points
	var pts_label := Label.new()
	if pts > 0:
		pts_label.text = "+%d" % pts
		pts_label.add_theme_color_override("font_color", Color(0.31, 0.78, 0.49))
	elif pts < 0:
		pts_label.text = "%d" % pts
		pts_label.add_theme_color_override("font_color", Color(0.86, 0.35, 0.35))
	else:
		pts_label.text = "—"
		pts_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.18))
	pts_label.add_theme_font_size_override("font_size", 22)
	pts_label.custom_minimum_size = Vector2(72, 0)
	pts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pts_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(pts_label)

	return row
