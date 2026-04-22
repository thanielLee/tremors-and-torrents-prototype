extends Area3D

@export var hint_message: String = "Safe zone — bring victims here!"
@export var hint_duration: float = 4.0
var hud_manager: HUDManager
var shown: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	hud_manager = get_tree().get_first_node_in_group("hud_manager")

func _on_body_entered(body: Node3D) -> void:
	if shown or not body.is_in_group("player_body"):
		return
	shown = true
	if hud_manager:
		hud_manager.show_prompt(hint_message, hint_duration)
