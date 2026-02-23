extends Node3D

@onready var strike_receiver: OISStrikeReceiver = $OISStrikeReceiver
@onready var particle_emit_node = $VfxHammerImpact
var cooldown: float = 0.0
var is_emitting: bool = false

func _ready():
	strike_receiver.connect("action_started", hit_process)

func set_emit_children(emit_value: bool):
	for child in particle_emit_node.get_children():
		child.emitting = emit_value
	
func _process(delta):
	if is_emitting:
		cooldown += delta
		if cooldown >= 0.5:
			is_emitting = false
			set_emit_children(false)
			cooldown = 0.0

func hit_process(requirement, total_progress):
	is_emitting = true
	set_emit_children(true)
	
