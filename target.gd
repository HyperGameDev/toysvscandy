class_name Target extends PathFollow3D

const sprite_array: Array[CompressedTexture2D] = [
	preload("res://Assets/targets/target_1_brownie.png"),
	preload("res://Assets/targets/target_2_donut.png"),
	preload("res://Assets/targets/target_3_cupcake.png"),
	preload("res://Assets/targets/target_4_cookie.png"),
	preload("res://Assets/targets/target_5_cake.png"),
	preload("res://Assets/targets/target_6_icecream.png")
]

const speed_array: Array[float] = [
	8.,
	11.2,
	14.4,
	25.6,
	14.4,
	20.
]

@export var speed: float = 8.
var frozen: bool = false
var marked: bool = false

@onready var sprite: Sprite3D = %Sprite3D

@export_range(0,5,1) var target_level: int

func _ready() -> void:
	Messenger.target_added_to_path.connect(_on_target_added_to_path)

func _physics_process(delta: float) -> void:
	progress += speed * delta
	
func _on_target_added_to_path():
	update_target()

func update_target() -> void:
	if target_level < 0:
		#print("Target ",self.name," has level ",target_level,"!")
		reparent(Debug_Collector.ref)
	else:
		sprite.texture = sprite_array[target_level]
		speed = speed_array[target_level]

func reparent_to_collector():
	reparent(Target_Collector.ref)
	position = Vector3.ZERO
	progress = 0.
	Messenger.target_removed_from_path.emit()

	process_mode = PROCESS_MODE_DISABLED
