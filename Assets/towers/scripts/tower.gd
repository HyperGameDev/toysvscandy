class_name Tower extends Node3D

var detected_targets: Array[PathFollow3D] = []
var detected_targets_positions: Array[float]

#WARNING DON'T DO @ONREADYS
var cursor_target: Node3D
var shoot_point: Marker3D
var animation: AnimationTree
var visible_radius: MeshInstance3D
var tower_area: Area3D
var weapon_speed_timer: Timer
var animation_data: AnimationPlayer
	
var radius_color_state: radius_color_states
enum radius_color_states {VALID,INVALID}
var radius_color_valid: Color = Color(0.7666, 0.7666, 0.7666, 0.6745)
var radius_color_invalid: Color = Color(0.77, 0.0, 0.0, 0.675)

var is_held: bool = true
var is_placed: bool = false

var interact_state: interact_states
enum interact_states {NONE,HOVERED,SELECTED}

var is_attack_animating: bool = false

var one_shot: bool = false

const projectile: PackedScene = preload("res://projectile.tscn")

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

var attack_timer: float
@export var attack_timer_length: float = 1.
var attack_timer_running: bool = false

var attack_speed_1: float = 1.
var attack_speed_2: float = .7
var attack_speed_3: float = .5
#var attack_speed_4: float = .1

var aiming: bool = false
var aiming_target_pos: Vector3

var targets_on_path: Variant  = []
var targets_pos_on_path: Vector2
var target_to_attack: PathFollow3D
var target_hit_during_interval: bool = false

var tower_xy: Vector2

var attacking: bool = false


func _ready() -> void:
	animation = %AnimationTree
	
	if mesh_only:
		animation.active = false
		
	else: #is an actual tower
		Messenger.tower_spawned.emit(self)
		
		cursor_target = get_tree().get_current_scene().get_node("%Cursor_Target")
		shoot_point = %Shoot_Point
		visible_radius = %Visible_Radius
		tower_area = $Area3D
		weapon_speed_timer = %WeaponTimer
		weapon_speed_timer.one_shot = true
		animation_data = $AnimationPlayer
		
		Messenger.tower_placed.connect(_on_tower_placed)
		Messenger.tower_hovered.connect(_on_tower_hovered)
		Messenger.tower_selected.connect(_on_tower_selected)
		
		Messenger.target_added_to_path.connect(_on_target_added_to_path)
		Messenger.target_removed_from_path.connect(_on_target_removed_from_path)
		
		
		animation.animation_finished.connect(_on_animation_finished)
		animation.animation_started.connect(_on_animation_started)
		weapon_speed_timer.timeout.connect(_on_weapon_speed_timer_timeout)
		
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
				pass
		else: #is a placed tower
			if attack_timer_running:
				attack_timer = move_toward(attack_timer,0,delta)
				
			if attack_timer == 0:
				stop_attack_timer()
				
				if targets_on_path.size() > 0:
					update_targets_to_track()
					verify_targets_still_detected()

					
					if detected_targets.size() > 0:
						pass
						
			set_tower_aiming()
			
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
			
func set_tower_aiming():
	match aim_type:
		aim_types.AIMING:
			aim_tower_do_shoot()
					
		aim_types.AREA:
			area_tower_do_attack()
			
func aim_tower_do_shoot() -> void:
	if aiming:
		aim_at_target(target_to_attack)
		
		if attacking:
			emit_projectile(target_to_attack)
			
func animate_aiming_tower() -> void:
	animation.set("parameters/attack/request", 1)

func area_tower_do_attack() -> void:
	animate_area_tower()
	
func animate_area_tower() -> void:
	if attack_timer_running:
		if not one_shot and not is_attack_animating:
			animation.set("parameters/attack/request", 1)
			attack_target(target_to_attack)
			one_shot = true
	else:
		match tower_type:
			tower_types.TACK:
				animation.set("parameters/attack/request", 3)
			tower_types.FREEZE:
				animation.set("parameters/attack/request", 2)
				one_shot = false
			_:
				print("null case aim")
				return
			
func _on_animation_started(anim_name) -> void:
	if anim_name == "attack":
		is_attack_animating = true
			
func _on_animation_finished(anim_name) -> void:
	if anim_name == "attack":
		is_attack_animating = false
	
func emit_projectile(target_to_attack : Node3D):
	var shot_bullet: MeshInstance3D = projectile.instantiate()
	
	Projectile_Collector.ref.add_child(shot_bullet)
	shot_bullet.global_position = target_to_attack.global_position
	
	attacking = false

func _on_target_added_to_path() -> void:
	fetch_targets_on_path()
	
func _on_target_removed_from_path(_target) -> void:
	fetch_targets_on_path()
	
	
	
func fetch_targets_on_path() -> void:
	targets_on_path = Globals.targets_on_path

func start_attack_timer() -> void:
	#print("attack timer started")
	attack_timer = attack_timer_length
	attack_timer_running = true
	target_hit_during_interval = false

func stop_attack_timer() -> void:
	aiming = false
	attack_timer_running = false
	
func _on_tower_placed(tower) -> void:
	if tower == self:
		fetch_targets_on_path()
		tower_area.set_collision_layer_value(3,true)
		visible_radius.visible = false
		is_placed = true
		tower_xy = Vector2(global_position.x,global_position.z)
			
		if tower_type == tower_types.BOMB:
			lockdown_launchpad()
		
func lockdown_launchpad() -> void:
	%Pad.top_level = true
	%Wing_L.top_level = true
	%Wing_R.top_level = true
	
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
		
func verify_targets_still_detected() -> void:
	if target_to_attack != null:
		var marked_target_distance: float = calculate_distance_to_target(target_to_attack)
		if marked_target_distance > detection_radius:
			target_to_attack.unmark_me()
			target_to_attack = null
		else:
			target_to_attack.mark_me(marked_target_distance)
		
	for target in detected_targets:
		var distance: float = calculate_distance_to_target(target)
		if distance > detection_radius:
			detected_targets.erase(target)
			target.unmark_me()
	
func calculate_distance_to_target(target: Node3D) -> float:
	var target_xy: Vector2 = Vector2(target.global_position.x,target.global_position.z)
	var distance: float = tower_xy.distance_to(target_xy)
	return distance
	
func update_targets_to_track() -> void:
	for target: Node3D in targets_on_path:
		mark_nearby_target_for_attack(target)

func mark_nearby_target_for_attack(target: Node3D) -> void:	
	if not detected_targets.has(target):
		var distance: float = calculate_distance_to_target(target)
		
		if distance <= detection_radius:
			detected_targets.append(target)
			target_to_attack = target
			
			start_attack_timer()
			do_aiming(target_to_attack)
			
			if not target_to_attack.attack_target_detected.is_connected(_on_attack_target_detected):
				target_to_attack.attack_target_detected.connect(_on_attack_target_detected)
				target_to_attack.attack_target_detected.emit(target_to_attack)
				
		else:
			if detected_targets.size() <= 0:
				no_enemies_detected()
		

func no_enemies_detected() -> void:
	#print("No enemies detected! Weapon speed timer stopped")
	weapon_speed_timer.stop()
			
func do_aiming(target_to_attack : Node3D) -> void:
	match aim_type:
		aim_types.AIMING:
			aiming = true
			aiming_target_pos = target_to_attack.global_position
		aim_types.AREA:
			pass
		_:
			print("null case aiming ")
			return
	
		
func _on_attack_target_detected(target_to_attack : Node3D) -> void:
	attacking = true
	
func attack_target(target_to_attack : Node3D) -> void:
	if detected_targets.has(target_to_attack):
		if target_to_attack.marked:
			print(target_to_attack," is being attacked")
			weapon_speed_timer.start(attack_timer_length)
		
func _on_weapon_speed_timer_timeout() -> void:
	print("weapon timer timedout")
	match tower_type:
		tower_types.DART:
			damage_single()
		tower_types.TACK:
			damage_single()
		tower_types.FREEZE:
			damage_freeze()
		tower_types.BOMB:
			damage_single()
		tower_types.SUPER:
			damage_single()
			
	target_hit_during_interval = true

func damage_single() -> void:
	target_to_attack.target_level -= 1

func damage_freeze() -> void:
	if target_to_attack != null:
		if not target_to_attack.frozen:
			target_to_attack.speed = 0
			target_to_attack.frozen = true
			Messenger.target_frozen.emit(target_to_attack)

func aim_at_target(target_to_attack : Node3D) -> void:
	var target_direction : Vector3 = (target_to_attack.global_position - global_position).normalized()
	var target_angle : float = atan2(-target_direction.x, -target_direction.z)
	rotation.y = target_angle
	aiming = false
	
	
	#change to attack when projectile "reaches" target
	if not target_hit_during_interval:
		animate_aiming_tower()
		attack_target(target_to_attack)

func _upgrade_radius(radius: float) -> void:
	visible_radius.mesh.radius = radius
	
