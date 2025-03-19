extends Node3D


@onready var ground: MeshInstance3D = %Ground
@onready var camera: Camera3D = %Camera3D

@onready var collision: ShapeCast3D = %ShapeCast3D

var cursor_available: bool = false

var planeToMoveOn : Plane

func _ready() -> void:
	planeToMoveOn = Plane(Vector3(0,1,0), ground.global_position.y)

func _process(delta: float) -> void:
	follow_cursor_pos()
	check_for_collision()	

func check_for_collision() -> void:
	if collision.is_colliding():
		pass

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
