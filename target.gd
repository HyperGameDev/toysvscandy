class_name Target extends PathFollow3D

var performance: bool = false

const sprite_array: Array[CompressedTexture2D] = [
	preload("res://Assets/targets/temp/temp_target_1_brownie.png"),
	preload("res://Assets/targets/temp/temp_target_2.png"),
	preload("res://Assets/targets/temp/temp_target_3.png"),
	preload("res://Assets/targets/temp/temp_target_4.png"),
	preload("res://Assets/targets/temp/temp_target_5.png"),
	preload("res://Assets/targets/temp/temp_target_6_cake.png")
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


@onready var sprite: Sprite3D = %Sprite3D
@export_range(0,5,1) var target_level: int:
	set(new_level):
		target_level = new_level
		sprite.texture = sprite_array[target_level]
		speed = speed_array[target_level]
		
var dont_skip_frame: int #bool 0=false, 1=true
		
func _ready() -> void:
	dont_skip_frame = randi_range(0,1)

#func _process(delta: float) -> void:
	#if (Engine.get_process_frames() % 2) == dont_skip_frame:
		#progress += speed * 2 * delta
		#if progress_ratio >= 1.0:
			#reparent(Target_Collector.ref)
			#process_mode = PROCESS_MODE_DISABLED

func _physics_process(delta: float) -> void:
		progress += speed * delta
		if progress_ratio >= 1.0:
			reparent(Target_Collector.ref)
			process_mode = PROCESS_MODE_DISABLED
