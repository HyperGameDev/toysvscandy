class_name Single_Towers extends Tower3


@export var upgraded_shot_amount: bool = false 
	
var is_attacking: bool = false
	
	
func _on_attack_moment() -> void:
	var target_to_attack: PathFollow3D
	
	if not is_attacking:
		var highest_ratio: float = -INF
		
		for target in detected_targets:
			if target.target_level < 0:
				#print("SINGLE_TOWERS: dead target temporarily targeted")
				continue
			if target.progress_ratio > highest_ratio:
				highest_ratio = target.progress_ratio
				target_to_attack = target
			
		if target_to_attack != null:
			is_attacking = true
			#print("Attacking ", target_to_attack," at ", target_to_attack.get_parent().name)
			prepare_attack(target_to_attack)
			
			is_attacking = false

func _on_tower_upgraded(tower:Node3D,upgrade:String):
	super._on_tower_upgraded(tower,upgrade)
	
	if tower == self:
		if upgrade == "DOUBLE":
			upgraded_shot_amount = true

func prepare_attack(target:PathFollow3D) -> void:
	aim_at_target(target)
	animation.set("parameters/attack/request", 1)
	
	do_attack(target)
	
func aim_at_target(target_to_attack : Node3D) -> void:
	var target_direction : Vector3 = (target_to_attack.global_position - global_position).normalized()
	var target_angle : float = atan2(-target_direction.x, -target_direction.z)
	rotation.y = target_angle
	

func do_attack(target:PathFollow3D) -> void:
	if upgraded_shot_amount:
		var targets_hit: Array[PathFollow3D]
		if targets_hit.size() < 2:
			for double_target in detected_targets:
				if double_target.target_level < 0:
					#print("DART_TOWER: dead target temporarily targeted")
					continue
				if targets_hit.has(double_target):
					print("would have hit same one twice!")
					continue
			
				double_target.take_single_damage(double_target)
				targets_hit.append(double_target)
				
				if targets_hit.size() >= 2:
					break
		
		
	else:
		target.take_single_damage(target)
