extends Hazard


func _on_detection_area_body_entered(body: Node3D) -> void:
	hazard_triggered.emit(hazard_name)
	
