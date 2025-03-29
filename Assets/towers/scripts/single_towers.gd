class_name Single_Towers extends Tower3

var is_attacking: bool = false
	
	
func _on_attack_moment() -> void:
	#print("+++++++++++++++++++++")
	#print("Attack Moment Received! ",Engine.get_physics_frames())
	
	var target_to_attack: PathFollow3D
	
	if not is_attacking:
		var highest_ratio: float = -INF
		
		for target in detected_targets:
			#print(target.get_parent().name," has ",target.name)
			if target.progress_ratio > highest_ratio:
				highest_ratio = target.progress_ratio
				target_to_attack = target
				#print("Marked targets' level: ",target_to_attack.target_level)
				if target_to_attack.target_level < 0:
					#print("SINGLE_TOWERS: dead target temporarily targeted")
					return
			
		if target_to_attack != null:
			is_attacking = true
			#print("Attacking ", target_to_attack," at ", target_to_attack.get_parent().name)
			prepare_attack(target_to_attack)
			
			is_attacking = false

func prepare_attack(target:PathFollow3D) -> void:
	aim_at_target(target)
	animation.set("parameters/attack/request", 1)
	
	do_attack(target)
	
func aim_at_target(target_to_attack : Node3D) -> void:
	var target_direction : Vector3 = (target_to_attack.global_position - global_position).normalized()
	var target_angle : float = atan2(-target_direction.x, -target_direction.z)
	rotation.y = target_angle
	
	
