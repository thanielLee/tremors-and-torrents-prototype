extends Node

@onready var inventory_system = $".."


@onready var medkit_open_sound = $MedkitOpenSound
@onready var medkit_close_sound = $MedkitCloseSound
var toggle: bool

func _ready():
	toggle = inventory_system.visible

func _on_inventory_system_visibility_changed():
	if toggle:
		medkit_open_sound.play()
	else:
		medkit_close_sound.play()
