class_name Tower_Tack extends Area_Towers

@onready var spin_sparks: MeshInstance3D = %Spin_Sparks
@onready var animation_sparks: AnimationPlayer = %AnimationPlayer_Sparks

var one_shot: bool = false

func _upgrade_radius(radius:float) -> void:
	super._upgrade_radius(radius)
	spin_sparks.mesh.size = Vector2(radius*2,radius*2)

func _on_attack_moment() -> void:
	do_attack(null)
	
func do_attack(_target) -> void:
	for target in detected_targets:
		if target.target_level < 0:
			#print("TACK_TOWER: dead target temporarily targeted")
			continue
		
		target.take_single_damage()
		if not mesh_only:
			animate_attack()
	
func animate_attack() -> void:
	animation.set("parameters/attack/request", 1)
	animation_sparks.play("show_sparks")

func unanimate_attack() -> void:
	animation.set("parameters/attack/request", 3)
	
