class_name Tower extends Node3D

@onready var shoot_point: Marker3D = %Shoot_Point
@onready var visible_radius: MeshInstance3D = %Visible_Radius

const projectile: PackedScene = preload("res://projectile.tscn")

var detection_radius: float = 8.

var attack_timer: float
@export var attack_timer_length: float = 1
var attack_timer_running: bool = false

var aiming: bool = false
var aiming_target_pos: Vector3

var targets_on_path: Variant = []
var target_positions: Array[Vector2] = []
var targets_pos_on_path: Vector2
var target_to_attack: PathFollow3D
var target_hit_during_interval: bool = false

var tower_xy: Vector2

var attacking: bool = false


func _ready() -> void:
	Messenger.target_added_to_path.connect(_on_target_added_to_path)
	_upgrade_radius(detection_radius)
	
	tower_placed()
	
func _process(delta: float) -> void:
	if attack_timer_running:
		attack_timer = move_toward(attack_timer,0,delta)
	if attack_timer == 0:
		stop_attack_timer()
		update_targets_to_track()
		
	if aiming:
		aim_at_target(target_to_attack,delta)
		
		if attacking:
			emit_projectile(target_to_attack)
		
		
func emit_projectile(target_to_attack):
	var shot_bullet: MeshInstance3D = projectile.instantiate()
	
	Projectile_Collector.ref.add_child(shot_bullet)
	shot_bullet.global_position = target_to_attack.global_position
	attacking = false

func _on_target_added_to_path() -> void:
	targets_on_path = Globals.targets_on_path

func start_attack_timer	() -> void:
	attack_timer = attack_timer_length
	attack_timer_running = true
	target_hit_during_interval = false
			
func stop_attack_timer() -> void:
	aiming = false
	tower_idle()
	pass
	
func tower_placed() -> void:
	tower_xy = Vector2(global_position.x,global_position.z)
		
func update_targets_to_track() -> void:
	for target in targets_on_path:
		var target_xy: Vector2 = Vector2(target.global_position.x,target.global_position.z)
		target_positions.append(target_xy)
		update_target_distances(target,target_xy)
	
func tower_idle():
	var target_direction = (aiming_target_pos - global_position).normalized()
	var target_angle = atan2(target_direction.x, target_direction.z)
	rotation.y = target_angle
	print("tower_idle-ing")
		
func update_target_distances(target,target_xy) -> void:		
	var distance: float = tower_xy.distance_to(target_xy)
	check_distance_from_target(target,distance)

func check_distance_from_target(target,distance) -> void:
	if distance <= detection_radius:
		var detected_targets: Array[PathFollow3D] = []
		detected_targets.append(target)
		var detected_targets_positions: Array[float]
		detected_targets_positions.append(distance)
		var detected_target_index: int = detected_targets_positions.find(detected_targets_positions.min())
		target_to_attack = detected_targets[detected_target_index]
		
		
		start_attack_timer()
		aiming = true
		aiming_target_pos = target_to_attack.global_position
		
		if not target_to_attack.attack_target_detected.is_connected(_on_attack_target_detected):
			target_to_attack.attack_target_detected.connect(_on_attack_target_detected)
			target_to_attack.attack_target_detected.emit(target_to_attack)
	#else:
		#tower_idle(aiming_target_pos)
		
		
func _on_attack_target_detected(target_to_attack) -> void:
	attacking = true


func attack_target(target_to_attack) -> void:
	if not target_hit_during_interval:
		target_to_attack.target_level -= 1
		target_hit_during_interval = true

func aim_at_target(target_to_attack,delta):
	print("aim_at_target-ing")
	#var target_look_at_pos: Vector3 = Vector3(target_to_attack.global_position.x,global_position.y,target_to_attack.global_position.z)
	
	var target_direction = (target_to_attack.global_position - global_position).normalized()
	var target_angle = atan2(target_direction.x, target_direction.z)
	rotation.y = target_angle
	aiming = false
	
	
	#change to attack when projectile "reaches" target
	attack_target(target_to_attack)
	#var distance_to_target

func _upgrade_radius(radius: float) -> void:
	visible_radius.mesh.radius = radius + 2
	
