class_name Single_Towers extends Tower3

var is_attacking: bool = false

func _ready() -> void:
	super._ready()
	
	attack_moment.connect(_on_attack_moment)
	
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
					print("dead target targeted")
					return
			
		if target_to_attack != null:
			is_attacking = true
			#print("Attacking ",target_to_attack.get_parent().name)
			do_attack(target_to_attack)
	
func do_attack(target) -> void:
	aim_at_target(target)
	target.take_single_damage()
	#print("Attack Done! ",Engine.get_physics_frames())
	#print("------------------")
	is_attacking = false
	
func aim_at_target(target_to_attack : Node3D) -> void:
	var target_direction : Vector3 = (target_to_attack.global_position - global_position).normalized()
	var target_angle : float = atan2(-target_direction.x, -target_direction.z)
	rotation.y = target_angle
	
	
