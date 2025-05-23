class_name Cursor_Target extends Node3D

static var ref

var cursor_state: cursor_states
enum cursor_states {SELECT,HOLD}

var can_place: bool = true
var tower_currently_held: Node3D

var tower_hovered: Node3D
var emit_hover: bool = false

@onready var ground: MeshInstance3D = %Ground
@onready var camera: Camera3D = %Camera3D

@onready var collision: ShapeCast3D = %ShapeCast3D

var cursor_available: bool = false

var planeToMoveOn : Plane

func _init() -> void:
	ref = self

func _ready() -> void:
	Messenger.tower_spawned.connect(_on_tower_spawned)
	Messenger.tower_placed.connect(_on_tower_placed)
	
	planeToMoveOn = Plane(Vector3(0,1,0), ground.global_position.y)

func _process(_delta: float) -> void:
	follow_cursor_pos()
	match cursor_state:
		cursor_states.SELECT:
			check_for_tower_collision()
		cursor_states.HOLD:
			check_for_path_collision()	
		_:
			print("cursor state null")
			
func check_for_tower_collision() -> void:
	if collision.is_colliding():
		tower_hovered = collision.get_collider(0).get_parent()
		
		Messenger.tower_hovered.emit(tower_hovered)
	else: #not colliding
		if tower_hovered != null:
			Messenger.tower_hovered.emit(null)
			tower_hovered = null
			
		if Input.is_action_just_pressed("Action"):
			Messenger.tower_selected.emit(null)

func check_for_path_collision() -> void:
	if collision.is_colliding():
		can_place = false
	else:
		can_place = true
		
func _on_tower_spawned(tower) -> void:
	tower_currently_held = tower
	cursor_state = cursor_states.HOLD
	collision.set_collision_mask_value(1,true)
	collision.set_collision_mask_value(2,false)
	collision.set_collision_mask_value(3,true)
	
func _on_tower_placed(_tower) -> void:
	cursor_state = cursor_states.SELECT
	collision.set_collision_mask_value(2,true)
	collision.set_collision_mask_value(1,false)
	collision.set_collision_mask_value(3,false)

func is_cursor_available(cursor_pos) -> bool:
	if cursor_pos == null:
		return false
	else:
		return true
	
func follow_cursor_pos() -> void:
	var cursorPosition : Vector2 = get_viewport().get_mouse_position()
	var rayStartPoint : Vector3 = camera.project_ray_origin(cursorPosition)
	var rayDirection : Vector3 = camera.project_ray_normal(cursorPosition)
	var goTo = planeToMoveOn.intersects_ray(rayStartPoint, rayDirection)
	
	cursor_available = is_cursor_available(goTo)
	
	if cursor_available:
		self.global_position = goTo
