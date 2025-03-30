class_name Tower_Freeze extends Area_Towers

@export var upgraded_time_factor: float = 1.7

func _on_tower_upgraded(tower:Node3D,upgrade:String):
	super._on_tower_upgraded(tower,upgrade)
	
	if tower == self:
		if upgrade == "+ TIME":
			Globals.frozen_time_length = Globals.frozen_time_length * upgraded_time_factor

func _on_attack_moment() -> void:
	do_attack(null)
	
func do_attack(_target) -> void:
	for target in detected_targets:
		if not target.frozen:
			target._on_target_frozen(target,self)
			
			
func animate_attack() -> void:
	animation.set("parameters/attack/request", 1)

func unanimate_attack() -> void:
	animation.set("parameters/attack/request", 2)
