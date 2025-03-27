class_name Tower_Freeze extends Area_Towers

func _on_attack_moment() -> void:
	do_attack(null)
	
func do_attack(_target) -> void:
	for target in detected_targets:
		if not target.frozen:
			target.speed = 0
			target.frozen = true
			target._on_target_frozen(target)
