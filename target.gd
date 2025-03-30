class_name Target extends PathFollow3D

@onready var timer_frozen: Timer = %Timer_Frozen
@onready var timer_freeze_history: Timer = %Timer_Freeze_History

var freeze_tower_history: Array[Node3D] = []

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

	timer_frozen.timeout.connect(_on_timer_frozen_timeout)
	timer_freeze_history.timeout.connect(_on_timer_freeze_history_timeout)

	
func _process(_delta: float) -> void:
	if progress_ratio >= .99:
		Messenger.target_missed.emit(target_level)
		reparent_to_collector()

func _physics_process(delta: float) -> void:
	progress += speed * delta
	
func _on_target_added_to_path(target):
	if target == self:
		update_target(false,false)

	
func take_single_damage(target) -> void:
	if target == self:
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
		Messenger.target_attacked.emit()
		show_attacked_fx()
		
		if target_level < -1:
			print("INVALID TARGET LEVEL ATTACKED!")
			#breakpoint
			#reparent(Debug_Collector.ref)
		
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
	
func neighbors_to_explode() -> Array[PathFollow3D]:
	var neighbors_array: Array[PathFollow3D] = []
	for neighbor in Globals.targets_on_path:
		if calculate_neighbor_distance(neighbor.progress_ratio) < Globals.explode_range:
			if not neighbors_array.has(neighbor):
				neighbors_array.append(neighbor)
	return neighbors_array
			
func calculate_neighbor_distance(neighbor_ratio) -> float:
	return abs(progress_ratio - neighbor_ratio)
	

func _on_target_frozen(target,tower) -> void:
	if target == self and not target_level == 5:
		if not freeze_tower_history.has(tower):
			tower.animate_attack()
			speed = 0
			frozen = true
			timer_frozen.start(Globals.frozen_time_length)
			#print("frozened with ",timer_frozen.wait_time)
			timer_freeze_history.start(6.)
			freeze_tower_history.append(tower)
		
func _on_timer_frozen_timeout() -> void:
	frozen = false
	speed = speed_array[target_level]
	#print("unfrozen at ",Engine.get_physics_frames())

func _on_timer_freeze_history_timeout() -> void:
	freeze_tower_history.clear()
	
#func mark_me(distance: float) -> void:
	#marked = true
	#%Label3D.text = str(distance)
	#%Label3D.visible = true
	#
#func unmark_me() -> void:
	#%Label3D.visible = false
	#marked = false
