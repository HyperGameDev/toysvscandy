class_name Tower2 extends Node3D

@export var radius: float
@export var interval_speed: float

var tower_xy: Vector2

@export var mesh_only: bool = false

@export var tower_type: tower_types
enum tower_types {DART,TACK,FREEZE,BOMB,SUPER}

var targets_on_path: Variant  = []
var target_to_attack: PathFollow3D

var detected_targets: Array[PathFollow3D] = []


var visible_radius: MeshInstance3D
var tower_area: Area3D
var cursor_target: Node3D
var animation_player: AnimationPlayer
var animation_tree: AnimationTree

var radius_color_state: radius_color_states
enum radius_color_states {VALID,INVALID}
var radius_color_valid: Color = Color(0.7666, 0.7666, 0.7666, 0.6745)
var radius_color_invalid: Color = Color(0.77, 0.0, 0.0, 0.675)

var is_held: bool = true
var is_placed: bool = false

var interact_state: interact_states
enum interact_states {NONE,HOVERED,SELECTED}

func _ready() -> void:
	ready_assigns_nodes()
	ready_connect_signals()

func ready_assigns_nodes() -> void:
	animation_tree = %AnimationTree
	
	if mesh_only:
		animation_tree.active = false
		
	cursor_target = get_tree().get_current_scene().get_node("%Cursor_Target")
	visible_radius = %Visible_Radius
	animation_player = $AnimationPlayer
	
func ready_connect_signals() -> void:
	Messenger.tower_placed.connect(_on_tower_placed)
	Messenger.tower_hovered.connect(_on_tower_hovered)
	Messenger.tower_selected.connect(_on_tower_selected)
	
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
			pass
			
func i_am_placeable() -> bool:
	var cursor_tower_currently_held: Node3D = Cursor_Target.ref.tower_currently_held
	var cursor_can_place: bool = Cursor_Target.ref.can_place
	
	if cursor_can_place:
		return cursor_tower_currently_held == self
	else:
		return false
		
func radius_color_red(make_red) -> void:
	if make_red:
		if radius_color_state == radius_color_states.VALID:
			radius_color_state = radius_color_states.INVALID
			visible_radius.mesh.material.albedo_color = radius_color_invalid
	else:
		radius_color_state = radius_color_states.VALID
		visible_radius.mesh.material.albedo_color = radius_color_valid
		
func check_for_placement() -> void:
	if Input.is_action_just_released("Action"):
		is_held = false
		Messenger.tower_placed.emit(self)

func follow_cursor_pos() -> void:
	global_position = cursor_target.global_position

func _on_tower_placed(tower) -> void:
	if tower == self:
		fetch_targets_on_path()
		tower_area.set_collision_layer_value(3,true)
		visible_radius.visible = false
		is_placed = true
		tower_xy = Vector2(global_position.x,global_position.z)

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
			
func fetch_targets_on_path() -> void:
	targets_on_path = Globals.targets_on_path
	
func side_ui_hover() -> bool:
	return HUD.ref.side_ui_hovered
