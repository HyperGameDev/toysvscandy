extends Node3D

var detection_radius: float = 8.
var detected_targets: Array[PathFollow3D] = []

var targets_on_path: Variant = []
var target_positions: Array[Vector2] = []
var targets_pos_on_path: Vector2

@onready var visible_radius: MeshInstance3D = %Visible_Radius

func _ready() -> void:
	Messenger.target_added_to_path.connect(_on_target_added_to_path)
	_upgrade_radius(detection_radius)
	
func _on_target_added_to_path():
	targets_on_path = Path.ref.get_children() as Array[PathFollow3D]
	
func _physics_process(delta: float) -> void:
	for target in targets_on_path:
		var target_xy: Vector2 = Vector2(target.global_position.x,target.global_position.z)
		target_positions.append(target_xy)

func _upgrade_radius(radius: float) -> void:
	visible_radius.mesh.radius = radius
	
