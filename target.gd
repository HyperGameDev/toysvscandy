class_name Target extends PathFollow3D

const sprite_array: Array[CompressedTexture2D] = [
	preload("res://Assets/targets/target_1_brownie.png"),
	preload("res://Assets/targets/target_2_donut.png"),
	preload("res://Assets/targets/target_3_cupcake.png"),
	preload("res://Assets/targets/target_4_cookie.png"),
	preload("res://Assets/targets/target_5_cake.png"),
	preload("res://Assets/targets/target_6_icecream.png")
]

const blastfx_array: Array[CompressedTexture2D] = [
	preload("res://Targets/target_blast_1.png"),
	preload("res://Targets/target_blast_2.png"),
	preload("res://Targets/target_blast_3.png")
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
@onready var sprite_blastfx: Sprite3D = %Sprite3D_blast

@onready var timer_blastfx: Timer = %"Timer_Blast-fx"


@export_range(0,5,1) var target_level: int

func _ready() -> void:
	Messenger.target_added_to_path.connect(_on_target_added_to_path)
	
	timer_blastfx.timeout.connect(_on_timer_blastfx_timeout)

func _physics_process(delta: float) -> void:
	progress += speed * delta
	
func _on_target_added_to_path():
	update_target(false)

func update_target(attacked:bool) -> void:
	if attacked:
		show_attacked_fx()
		
		if target_level < 0:
			print("INVALID TARGET LEVEL ATTACKED!")
			breakpoint
			reparent(Debug_Collector.ref)

			
	
	sprite.texture = sprite_array[target_level]
	speed = speed_array[target_level]

func reparent_to_collector() -> void:
	reparent(Target_Collector.ref)
	position = Vector3.ZERO
	progress = 0.
	Messenger.target_removed_from_path.emit(self)

	process_mode = PROCESS_MODE_DISABLED
	
func show_attacked_fx() -> void:
	var randfx: int = randi_range(0,2)
	sprite_blastfx.texture = blastfx_array[randfx]
	sprite_blastfx.visible = true
	timer_blastfx.start(.1)
	
	
func _on_timer_blastfx_timeout() -> void:
	sprite_blastfx.visible = false
	
	if target_level == -1:
		reparent_to_collector()
		
