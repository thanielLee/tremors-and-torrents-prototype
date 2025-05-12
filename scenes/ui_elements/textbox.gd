extends CanvasLayer

const CHAR_READ_RATE = 0.05

@onready var textbox_container = $TextboxContainer
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Text
var tween

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	
	hide_textbox()
	add_text("New text is being added!")
	pass # Replace with function body.
	
	

func _process(delta):
	pass
	match current_state:
		State.READY:
			print("Ready state!")
		State.READING:
			print("Reading state!")
		State.FINISHED:
			print("Finished state!")
	

func hide_textbox():
	label.text = ""
	textbox_container.hide()
	label.set("visible_characters", 0)

func show_textbox():
	textbox_container.show()

func add_text(next_text):
	label.text = next_text
	show_textbox()
	tween.tween_property(label, "visible_characters", len(next_text), 1)
#	len(next_text) * CHAR_READ_RATE
	label.set("visible_characters", tween.interpolate_value(0.0, len(next_text), 0.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT))
	
	
func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Ready state!")
		State.READING:
			print("Reading state!")
		State.FINISHED:
			print("Finished state!")
