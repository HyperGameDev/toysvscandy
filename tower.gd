class_name Tower extends Node3D

@onready var shoot_point: Marker3D = %Shoot_Point
@onready var visible_radius: MeshInstance3D = %Visible_Radius
@onready var animation: AnimationTree = %AnimationTree

var one_shot: bool = false

const projectile: PackedScene = preload("res://projectile.tscn")

@export var tower_type: tower_types
enum tower_types {DART,TACK,FREEZE,BOMB,SUPER}

@export var aim_type: aim_types
enum aim_types {AIMING,AREA}

var detection_radius: float = 7.
var radius_1: float = 4.85
var radius_2: float = 5.5
var radius_3: float = 7.
var radius_4: float = 8.54
var radius_5: float = 9.9
var radius_6: float = 16.83

var attack_timer: float
@export var attack_timer_length: float = 1
var attack_timer_running: bool = false

var attack_speed_1: float = 1.
var attack_speed_2: float = .6667
var attack_speed_3: float = .3333
var attack_speed_4: float = .1

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
	
	set_tower_stats()
	
func _process(delta: float) -> void:
	if attack_timer_running:
		attack_timer = move_toward(attack_timer,0,delta)
	if attack_timer == 0:
		stop_attack_timer()
		update_targets_to_track()
		
	set_tower_aiming()
			
			
func set_tower_stats():
	match tower_type:
		tower_types.DART:
			attack_timer_length = attack_speed_3
			detection_radius = radius_3
		tower_types.TACK:
			attack_timer_length = attack_speed_2
			detection_radius = radius_1
		tower_types.FREEZE:
			attack_timer_length = attack_speed_1
			detection_radius = radius_1
		tower_types.BOMB:
			attack_timer_length = attack_speed_2
			detection_radius = radius_4
		tower_types.SUPER:
			attack_timer_length = attack_speed_4
			detection_radius = radius_5
		
func set_tower_aiming():
	match aim_type:
		aim_types.AIMING:
			if aiming:
				aim_at_target(target_to_attack)
				
				if attacking:
					emit_projectile(target_to_attack)
		aim_types.AREA:
			if attack_timer_running:
				if not one_shot:
					animation.set("parameters/attack/request", 1)
					one_shot = true
			else:
				match tower_type:
					tower_types.TACK:
						animation.set("parameters/attack/request", 3)
					tower_types.FREEZE:
						animation.set("parameters/attack/request", 2)
				one_shot = false
		
func emit_projectile(target_to_attack):
	var shot_bullet: MeshInstance3D = projectile.instantiate()
	
	Projectile_Collector.ref.add_child(shot_bullet)
	shot_bullet.global_position = target_to_attack.global_position
	
	animation.set("parameters/attack/request", 1)
	attacking = false

func _on_target_added_to_path() -> void:
	targets_on_path = Globals.targets_on_path

func start_attack_timer() -> void:
	attack_timer = attack_timer_length
	attack_timer_running = true
	target_hit_during_interval = false

func stop_attack_timer() -> void:
	aiming = false
	attack_timer_running = false
	
func tower_placed() -> void:
	tower_xy = Vector2(global_position.x,global_position.z)
		
func update_targets_to_track() -> void:
	for target in targets_on_path:
		var target_xy: Vector2 = Vector2(target.global_position.x,target.global_position.z)
		target_positions.append(target_xy)
		update_target_distances(target,target_xy)
		
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
		
		do_aiming(target_to_attack)
		
		if not target_to_attack.attack_target_detected.is_connected(_on_attack_target_detected):
			target_to_attack.attack_target_detected.connect(_on_attack_target_detected)
			target_to_attack.attack_target_detected.emit(target_to_attack)
			
func do_aiming(target_to_attack):
	match aim_type:
		aim_types.AIMING:
			aiming = true
			aiming_target_pos = target_to_attack.global_position
	
		
func _on_attack_target_detected(target_to_attack) -> void:
	attacking = true
	
func attack_target(target_to_attack) -> void:
	if not target_hit_during_interval:
		target_to_attack.target_level -= 1
		#target_to_attack.speed = 0 # Freeze
		#Messenger.frozen_target.emit(target_to_attack)
		target_hit_during_interval = true

func aim_at_target(target_to_attack):
	var target_direction = (target_to_attack.global_position - global_position).normalized()
	var target_angle = atan2(-target_direction.x, -target_direction.z)
	rotation.y = target_angle
	aiming = false
	
	
	#change to attack when projectile "reaches" target
	attack_target(target_to_attack)
	#var distance_to_target

func _upgrade_radius(radius: float) -> void:
	visible_radius.mesh.radius = radius
	
