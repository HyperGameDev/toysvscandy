class_name Target extends PathFollow3D

@onready var timer_frozen: Timer = %Timer_Frozen

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

	Messenger.target_frozen.connect(_on_target_frozen)
	
	timer_frozen.timeout.connect(_on_timer_frozen_timeout)

	
func _process(_delta: float) -> void:
	if progress_ratio >= .99:
		reparent_to_collector()

func _physics_process(delta: float) -> void:
	progress += speed * delta
	
func _on_target_added_to_path():
	update_target(false,false)

	
func take_single_damage() -> void:
	if target_level > 3:
		update_target(true,true)
		
	else:
		target_level -= 1
		#print(target_level," got damaged!")
		
		if target_level > -1: # Target survived damaged
			#print(target_level," survived damage")
			update_target(true,false)
		elif target_level == -1: # Target died due to damage
			update_target(true,false)
			#print(target_level," would be unvisibled")
			sprite.visible = false
		else:
			print("INVALID TARGET LEVEL")
			breakpoint

func update_target(attacked:bool, above_3:bool) -> void:
	if attacked:
		#print(target_level," blastfx begun")
		show_attacked_fx()
		
		if target_level < -1:
			print("INVALID TARGET LEVEL ATTACKED!")
			breakpoint
			reparent(Debug_Collector.ref)
		
		if above_3:
			target_level = 3
			update_target(false,false)
			
			Target_Collector.ref.reparent_extra_target_to_path(3,progress_ratio,-.01)
				
	if not above_3:
		sprite.texture = sprite_array[target_level]
		speed = speed_array[target_level]

func show_attacked_fx() -> void:
	var randfx: int = randi_range(0,2)
	sprite_blastfx.texture = blastfx_array[randfx]
	sprite_blastfx.visible = true
	timer_blastfx.start(.1)
	
func _on_timer_blastfx_timeout() -> void:
	sprite_blastfx.visible = false
	
	#print(target_level," blast fx'ed")
	
	if target_level == -1:
		#print(target_level," reparent initiated by blastfx timeout")
		reparent_to_collector()

func reparent_to_collector() -> void:
	#print(target_level," reparenting function run")
	reparent(Target_Collector.ref)
	position = Vector3.ZERO
	progress = 0.
	Messenger.target_removed_from_path.emit(self)

	process_mode = PROCESS_MODE_DISABLED	

func _on_target_frozen(target) -> void:
	if target == self:
		timer_frozen.start(3.)
		
func _on_timer_frozen_timeout() -> void:
	frozen = false
	speed = speed_array[target_level]



#func mark_me(distance: float) -> void:
	#marked = true
	#%Label3D.text = str(distance)
	#%Label3D.visible = true
	#
#func unmark_me() -> void:
	#%Label3D.visible = false
	#marked = false
