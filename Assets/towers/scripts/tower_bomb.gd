class_name Tower_Bomb extends Single_Towers

var upgraded_size: bool = false

func _on_tower_placed(tower) -> void:
	lockdown_launchpad()
		
func lockdown_launchpad() -> void:
	%Pad.top_level = true
	%Wing_L.top_level = true
	%Wing_R.top_level = true

func do_attack(target:PathFollow3D) -> void:
	target.take_single_damage()
	
	var neighboring_targets: Array[PathFollow3D] = sort_targets_as_neighbors(detected_targets)
	
	
	var central_index: int = neighboring_targets.find(target)
	
	var left_target: PathFollow3D
	var lefter_target: PathFollow3D
	var left_index: int = central_index -1
	var lefter_index: int
	if index_exists(left_index):
		left_target = neighboring_targets[left_index]
		left_target.take_single_damage()
	
	var right_target: PathFollow3D
	var righter_target: PathFollow3D
	var right_index: int = central_index +1
	var righter_index: int
	if index_exists(right_index):
		right_target = neighboring_targets[right_index]
		right_target.take_single_damage()
	
	if upgraded_size:
		lefter_index = left_index -1
		lefter_target = neighboring_targets[lefter_index]
		if index_exists(lefter_index):
			lefter_target = neighboring_targets[lefter_index]
			lefter_target.take_single_damage()
		
		righter_index = right_index +1	
		righter_target = neighboring_targets[righter_index]
		if index_exists(righter_index) == null:
			righter_target = neighboring_targets[righter_index]
			righter_target.take_single_damage()
	
	#print("Attack Done! ",Engine.get_physics_frames())
	#print("------------------")
	
func sort_targets_as_neighbors(targets_array:Array[PathFollow3D]) -> Array[PathFollow3D]:
	var sorted_target_array: Array[PathFollow3D] = []
	var sorted_ratio_array: Array[float] = []
	
	
	for target in detected_targets:
		var target_ratio: float = target.progress_ratio
		sorted_ratio_array.append(target_ratio)
		
	sorted_ratio_array.sort()
	
	for ratio in sorted_ratio_array:
		for target in targets_array:
			if target.progress_ratio == ratio:
				sorted_target_array.append(target)
				
				# Remove the matched target to avoid duplicates
				targets_array.erase(target)
				break
	
	return sorted_target_array

	
func index_exists(index:int) -> bool:
	return index >= 0 and index < detected_targets.size()
	

	
	
		
	
	
	
	
	
	
	
	
