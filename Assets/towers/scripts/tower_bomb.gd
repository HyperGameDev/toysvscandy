class_name Tower_Bomb extends Single_Towers

@export var upgraded_blast_factor: float = 1.7

func _on_tower_placed(tower) -> void:
	super._on_tower_placed(tower)
	lockdown_launchpad()
	
func lockdown_launchpad() -> void:
	%Pad.top_level = true
	%Wing_L.top_level = true
	%Wing_R.top_level = true
	

func _on_tower_upgraded(tower:Node3D,upgrade:String):
	super._on_tower_upgraded(tower,upgrade)
	
	if tower == self:
		if upgrade == "BIGGER":
			Globals.explode_range = Globals.explode_range * upgraded_blast_factor 

func do_attack(target:PathFollow3D) -> void:
	for neighbor in target.neighbors_to_explode():
		neighbor.take_single_damage(target)
	
	
	#print("Attack Done! ",Engine.get_physics_frames())
	#print("------------------")
	
	
		
	
	
	
	
	
	
	
	
