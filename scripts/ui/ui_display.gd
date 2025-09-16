extends Control

@onready var dialogue_text: RichTextLabel = $DialogueText
@onready var choices_container: VBoxContainer = $ChoicesContainer
@onready var speaker_name: Label = $SpeakerName

func _ready():
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(npc_id: String):
	show()
	var dialogue_node = DialogueManager.current_dialogue.get_current_node()
	display_dialogue_node(dialogue_node)

func _on_dialogue_ended():
	hide()
	clear_choices()

func display_dialogue_node(node: Dictionary):
	speaker_name.text = node.get("speaker", "")
	dialogue_text.text = node.get("text", "")
	
	clear_choices()
	if "choices" in node:
		for choice in node.choices:
			create_choice_button(choice)

func clear_choices():
	for child in choices_container.get_children():
		child.queue_free()

func create_choice_button(choice: Dictionary):
	var button = Button.new()
	button.text = choice.get("text", "")
	button.pressed.connect(func(): _on_choice_selected(choice.get("id")))
	choices_container.add_child(button)

func _on_choice_selected(choice_id: String):
	var next_node = DialogueManager.make_choice(choice_id)
	if next_node:
		display_dialogue_node(next_node)
