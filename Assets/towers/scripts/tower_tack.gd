class_name Tower_Tack extends Area_Towers

func _on_attack_moment() -> void:
	do_attack(null)
	
func do_attack(_target) -> void:
	for target in detected_targets:
		target.take_single_damage()
	
