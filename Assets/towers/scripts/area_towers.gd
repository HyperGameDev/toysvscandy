class_name Area_Towers extends Tower3

func _physics_process(_delta: float) -> void:
	if not is_held and not mesh_only:
		if detected_targets.size() <= 0:
			unanimate_attack()
	
func unanimate_attack() -> void:
	pass
