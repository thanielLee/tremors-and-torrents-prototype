extends Node3D

@onready var flood_node : FloodPlane = $FloodPlane


func _ready():
	flood_node.start_flooding(1.0)
