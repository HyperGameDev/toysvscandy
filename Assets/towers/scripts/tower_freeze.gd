class_name Tower_Freeze extends Area_Towers

var one_shot: bool = false
var no_more_targets: bool = false

func _on_attack_moment() -> void:
	do_attack(null)
	animate_attack()
	
func do_attack(_target) -> void:
	for target in detected_targets:
		if not target.frozen:
			target._on_target_frozen(target,self)
			
func animate_attack() -> void:
	#if not one_shot:
	animation.set("parameters/attack/request", 1)
		#one_shot = true

func unanimate_attack() -> void:
	animation.set("parameters/attack/request", 2)
