class_name NPCComponent
extends Node

@export var npc_id: String
@export var can_interact: bool = true
@export var interaction_radius: float = 2.0
@export var available_dialogues: Array[String] = ["default"]

signal interaction_available(npc: NPCComponent)
signal interaction_unavailable(npc: NPCComponent)

var player_in_range: bool = false
var interaction_area: Area3D

func _ready():
	setup_interaction_area()
	
func setup_interaction_area():
	interaction_area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	
	sphere_shape.radius = interaction_radius
	collision_shape.shape = sphere_shape
	
	interaction_area.add_child(collision_shape)
	add_child(interaction_area)
	
	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)

func _on_player_entered(body):
	if body.is_in_group("player") and can_interact:
		player_in_range = true
		interaction_available.emit(self)

func _on_player_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		interaction_unavailable.emit(self)

func interact():
	if can_interact and player_in_range:
		var dialogue_id = get_current_dialogue_id()
		DialogueManager.start_dialogue(npc_id, dialogue_id)

func get_current_dialogue_id() -> String:
	# Logic to determine which dialogue to show based on quest states
	# This is where you can implement conditional dialogues
	return "default"
