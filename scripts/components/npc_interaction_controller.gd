extends Node

var current_interactable_npc: NPCComponent = null

func _ready():
	# Connect to all NPC interaction signals
	var npcs = get_tree().get_nodes_in_group("npcs")
	for npc in npcs:
		if npc.has_method("interaction_available"):
			npc.interaction_available.connect(_on_npc_interaction_available)
			npc.interaction_unavailable.connect(_on_npc_interaction_unavailable)

func _on_npc_interaction_available(npc: NPCComponent):
	current_interactable_npc = npc
	# Show VR interaction prompt (hand gesture, controller button, etc.)

func _on_npc_interaction_unavailable(npc: NPCComponent):
	if current_interactable_npc == npc:
		current_interactable_npc = null
		# Hide VR interaction prompt

func _input(event):
	# Handle VR controller input for interaction
	if event.is_action_pressed("vr_interact") and current_interactable_npc:
		current_interactable_npc.interact()
