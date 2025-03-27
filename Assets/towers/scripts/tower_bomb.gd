class_name Tower_Bomb extends Single_Towers

var upgraded_size: bool = false

func _on_tower_placed(tower) -> void:
	lockdown_launchpad()
		
func lockdown_launchpad() -> void:
	%Pad.top_level = true
	%Wing_L.top_level = true
	%Wing_R.top_level = true

func do_attack(target:PathFollow3D) -> void:
	for neighbor in target.neighbors_to_explode():
		neighbor.take_single_damage()
	
	
	#print("Attack Done! ",Engine.get_physics_frames())
	#print("------------------")
	
	
func index_exists(index:int) -> bool:
	return index >= 0 and index < detected_targets.size()
	

	
	
		
	
	
	
	
	
	
	
	
