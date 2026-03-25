extends CanvasLayer

@onready var description: RichTextLabel = $Control/Description
@onready var color_rect: ColorRect = $Control/ColorRect

func log_results(message: String):
	print("logging reults in log script")
	description.text = message
