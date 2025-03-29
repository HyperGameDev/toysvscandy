class_name Tower_Tack extends Area_Towers

var one_shot: bool = false

func _on_attack_moment() -> void:
	do_attack(null)
	
func do_attack(_target) -> void:
	for target in detected_targets:
		if target.target_level < 0:
			#print("TACK_TOWER: dead target temporarily targeted")
			return
		else:
			target.take_single_damage()
			animate_attack()
	
func animate_attack() -> void:
	animation.set("parameters/attack/request", 1)

func unanimate_attack() -> void:
	animation.set("parameters/attack/request", 3)
