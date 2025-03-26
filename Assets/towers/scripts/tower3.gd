class_name Tower3 extends Node3D

signal attack_moment

var detected_targets: Array[PathFollow3D] = []



#WARNING DON'T DO @ONREADYS
var cursor_target: Node3D
var animation: AnimationTree
var visible_radius: MeshInstance3D
var tower_area: Area3D
var animation_data: AnimationPlayer
	
var radius_color_state: radius_color_states
enum radius_color_states {VALID,INVALID}
var radius_color_valid: Color = Color(0.7666, 0.7666, 0.7666, 0.6745)
var radius_color_invalid: Color = Color(0.77, 0.0, 0.0, 0.675)

var is_held: bool = true
var is_placed: bool = false

var interact_state: interact_states
enum interact_states {NONE,HOVERED,SELECTED}

@export var mesh_only: bool = false

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

@export var attack_animation_speed: float = 1.
var attack_animation_speed_2: float = 1.5
var attack_animation_speed_3: float = 2.75

var attack_interval: float
@export var attack_timer_length: float = 1.
var attack_timer_running: bool = false

var attack_speed_1: float = 1.
var attack_speed_2: float = .7
var attack_speed_3: float = .5
#var attack_speed_4: float = .1

var targets_on_path: Variant  = []

var tower_xy: Vector2

func _ready() -> void:
	animation = %AnimationTree
	
	if mesh_only:
		animation.active = false
		
	else: #is an actual tower
		Messenger.tower_spawned.emit(self)
		
		cursor_target = get_tree().get_current_scene().get_node("%Cursor_Target")
		visible_radius = %Visible_Radius
		tower_area = $Area3D
		animation_data = $AnimationPlayer
		
		Messenger.tower_placed.connect(_on_tower_placed)
		Messenger.tower_hovered.connect(_on_tower_hovered)
		Messenger.tower_selected.connect(_on_tower_selected)
		
		Messenger.target_added_to_path.connect(_on_target_added_to_path)
		Messenger.target_removed_from_path.connect(_on_target_removed_from_path)
		
		Messenger.target_destroyed.connect(_on_target_destroyed)

		
		set_tower_stats()
		_upgrade_radius(detection_radius)
		
func _input(event: InputEvent) -> void:
	match interact_state:
		interact_states.HOVERED:
			if Input.is_action_just_pressed("Action"):
				Messenger.tower_selected.emit(self)
		interact_states.SELECTED:
			pass
		interact_states.NONE:
			pass
	
func _process(delta: float) -> void:
	if not mesh_only:
		if is_held:
			follow_cursor_pos()
			
			#print("Cursor target says placment is ",Cursor_Target.ref.can_place)
			if i_am_placeable():
				radius_color_red(false)
				check_for_placement()
			else: #Can't place the tower
				radius_color_red(true)
				
		else: #is a placed tower
			if attack_timer_running:
				attack_interval = move_toward(attack_interval,0,delta)
				
				if attack_interval == 0:
					stop_attack_timer()
				
			find_nearby_targets()				

#region Placing
func i_am_placeable() -> bool:
	var cursor_tower_currently_held: Node3D = Cursor_Target.ref.tower_currently_held
	var cursor_can_place: bool = Cursor_Target.ref.can_place
	
	if cursor_can_place:
		return cursor_tower_currently_held == self
	else:
		return false

func follow_cursor_pos() -> void:
	global_position = cursor_target.global_position
	
func check_for_placement() -> void:
	if Input.is_action_just_released("Action"):
		is_held = false
		Messenger.tower_placed.emit(self)
	
func radius_color_red(make_red) -> void:
	if make_red:
		if radius_color_state == radius_color_states.VALID:
			radius_color_state = radius_color_states.INVALID
			visible_radius.mesh.material.albedo_color = radius_color_invalid
	else:
		radius_color_state = radius_color_states.VALID
		visible_radius.mesh.material.albedo_color = radius_color_valid

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
			detection_radius = radius_5
			attack_animation_speed = attack_animation_speed_3
			attack_timer_length = animation_data.get_animation("attack").length / attack_animation_speed
		_:
			print("null case tower type")
			return
	
	animation.set("parameters/TimeScale/scale", attack_animation_speed)
	
func _on_tower_placed(tower) -> void:
	if tower == self:
		fetch_targets_on_path()
		tower_area.set_collision_layer_value(3,true)
		visible_radius.visible = false
		is_placed = true
		tower_xy = Vector2(global_position.x,global_position.z)
	
func side_ui_hover() -> bool:
	return HUD.ref.side_ui_hovered

func _on_tower_hovered(tower) -> void:
	if not interact_state == interact_states.SELECTED and side_ui_hover() == false:
		if tower == self:
			interact_state = interact_states.HOVERED
			visible_radius.visible = true
		else:
			interact_state = interact_states.NONE
			visible_radius.visible = false	
		
func _on_tower_selected(tower) -> void:
	if side_ui_hover() == false:
		if tower == self:
			interact_state = interact_states.SELECTED
			visible_radius.visible = true
		else:
			interact_state = interact_states.NONE
			visible_radius.visible = false
	
func _upgrade_radius(radius: float) -> void:
	visible_radius.mesh.radius = radius
#endregion

func fetch_targets_on_path() -> void:
	targets_on_path = Globals.targets_on_path
	
func _on_target_added_to_path() -> void:
	fetch_targets_on_path()
	
func _on_target_removed_from_path(target) -> void:
	detected_targets.erase(target)
	fetch_targets_on_path()

func start_attack_timer() -> void:
	#print("attack timer started")
	attack_interval = attack_timer_length
	attack_timer_running = true

func stop_attack_timer() -> void:
	attack_timer_running = false

	attack_moment.emit()
	
func find_nearby_targets() -> void:
	if targets_on_path.size() > 0:
		for target in targets_on_path:
			var distance: float = calculate_distance_to_target(target)
			if distance <= detection_radius:
				if not detected_targets.has(target):
					detected_targets.append(target)
				
				if not attack_timer_running:
					start_attack_timer()
			else:
				detected_targets.erase(target)

func _on_target_destroyed(target) -> void:
	#print(target," removed from array!")
	detected_targets.erase(target)
		
func calculate_distance_to_target(target: Node3D) -> float:
	var target_xy: Vector2 = Vector2(target.global_position.x,target.global_position.z)
	var distance: float = tower_xy.distance_to(target_xy)
	return distance
