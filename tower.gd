class_name Tower extends Node3D

var detection_radius: float = 8.

var targets_on_path: Variant = []
var target_positions: Array[Vector2] = []
var targets_pos_on_path: Vector2

var tower_xy: Vector2

var target_hit_for_interval: bool = false


var attack_timer: float
@export var attack_timer_length: float = 1.2
var attack_timer_running: bool = false


@onready var visible_radius: MeshInstance3D = %Visible_Radius

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

func start_attack_timer	() -> void:
	attack_timer = attack_timer_length
	attack_timer_running = true
	target_hit_for_interval = false
			
func stop_attack_timer() -> void:
	pass
	
func tower_placed() -> void:
	tower_xy = Vector2(global_position.x,global_position.z)
	
func _on_target_added_to_path() -> void:
	targets_on_path = Path.ref.get_children() as Array[PathFollow3D]
		
func update_targets_to_track() -> void:
	for target in targets_on_path:
		var target_xy: Vector2 = Vector2(target.global_position.x,target.global_position.z)
		target_positions.append(target_xy)
		update_target_distances(target,target_xy)
		
	start_attack_timer()
		
func update_target_distances(_target,target_xy) -> void:		
	var distance: float = tower_xy.distance_to(target_xy)
	check_distance_from_target(_target,distance)

func check_distance_from_target(target,distance) -> void:
	if distance <= detection_radius:
		var detected_targets: Array[PathFollow3D] = []
		detected_targets.append(target)
		var target_to_attack: PathFollow3D = detected_targets.min()
		if not target_hit_for_interval:
			target_to_attack.target_level -= 1
			target_hit_for_interval = true
			print("Just hit ", target_to_attack)

func _upgrade_radius(radius: float) -> void:
	visible_radius.mesh.radius = radius
	
