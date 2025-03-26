class_name Single_Towers extends Tower3

var target_to_attack: PathFollow3D

func _ready() -> void:
	super._ready()
	
	Messenger.attack_moment.connect(_on_attack_moment)
	
func _on_attack_moment(detected_targets) -> void:
	var highest_ratio: float = -INF
	
	for target in detected_targets:
		if target.progress_ratio > highest_ratio:
			highest_ratio = target.progress_ratio
			target_to_attack = target
		
	if target_to_attack != null:
		do_attack()
		#confirm_target_for_attack()
		#
#
#func confirm_target_for_attack() -> void:
	#var distance: float = calculate_distance_to_target(target_to_attack)
	#if distance <= detection_radius:
		#
	
func do_attack() -> void:
	
	aim_at_target(target_to_attack)
	
func aim_at_target(target_to_attack : Node3D) -> void:
	var target_direction : Vector3 = (target_to_attack.global_position - global_position).normalized()
	var target_angle : float = atan2(-target_direction.x, -target_direction.z)
	rotation.y = target_angle
	
	
