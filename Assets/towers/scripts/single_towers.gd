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
	
func do_attack() -> void:
	print("attack done")
	
	var distance: float = calculate_distance_to_target(target_to_attack)
	target_to_attack.mark_me(distance)
	
	
