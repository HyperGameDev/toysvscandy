class_name Tower_Tack extends Area_Towers

var one_shot: bool = false

func _on_attack_moment() -> void:
	do_attack(null)
	animate_attack()
	
func do_attack(_target) -> void:
	for target in detected_targets:
		if target.target_level < 0:
			#print("TACK_TOWER: dead target temporarily targeted")
			return
		else:
			target.take_single_damage()
	
func animate_attack() -> void:
	if not one_shot:
		animation.set("parameters/attack/request", 1)
		one_shot = true
		#else:
			#match tower_type:
				#tower_types.TACK:
					#animation.set("parameters/attack/request", 3)
				#tower_types.FREEZE:
					#animation.set("parameters/attack/request", 2)
					#one_shot = false
