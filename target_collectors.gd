class_name Target_Collector extends Node3D

static var ref

@onready var path_3d: Path3D = %Path3D

const target: PackedScene = preload("res://Targets/target.tscn")

var max_total_targets: int = 250
var max_targets_in_current_wave: int
var targets_in_current_wave: int

var reparent_timer: float
var reparent_timer_running: bool = false

var reparent_timer_length: float
@export var density: float = 1.
@export var density_scalar: float = .95

var current_wave_array: Array[int] = []

@export var reparent_timer_length_min: float = 0.1
@export var reparent_timer_length_max: float = 2.

func _init() -> void:
	ref = self

func _ready() -> void:
	Messenger.start_next_wave.connect(_on_start_next_wave)
	for index: int in range(max_total_targets): 
		spawn_targets()
	
func start_reparent_timer() -> void:
	reparent_timer_running = true
	reparent_timer = random_timer_length()
	
func stop_reparent_timer() -> void:
	reparent_timer_running = false
	
func random_timer_length() -> float:
	reparent_timer_length = density * randf_range(reparent_timer_length_min,reparent_timer_length_max)
	return reparent_timer_length

func _process(delta: float) -> void:
	if reparent_timer_running:
		reparent_timer = move_toward(reparent_timer,0,delta)
	if reparent_timer == 0:
		stop_reparent_timer()
		if targets_in_current_wave < max_targets_in_current_wave:
			targets_in_current_wave += 1
			reparent_target_to_path()
			start_reparent_timer()
			Messenger.target_added_to_path.emit()
	
func spawn_targets() -> void:
	var target_to_spawn: PathFollow3D = target.instantiate()
	add_child(target_to_spawn)
	
func _on_start_next_wave() -> void:
	#density *= density_scalar
	targets_in_current_wave = 0
	assign_target_counts()
	
func assign_target_counts() -> void:
	var wave_key = "wave_" + str(Globals.wave_number)

	var level_0_count: int = Globals.wave_data[wave_key][0]
	var level_1_count: int = Globals.wave_data[wave_key][1]
	var level_2_count: int = Globals.wave_data[wave_key][2]
	var level_3_count: int = Globals.wave_data[wave_key][3]
	var level_4_count: int = Globals.wave_data[wave_key][4]
	var level_5_count: int = Globals.wave_data[wave_key][5]
	
	
	update_wave_array(level_0_count,0)
	update_wave_array(level_1_count,1)
	update_wave_array(level_2_count,2)
	update_wave_array(level_3_count,3)
	update_wave_array(level_4_count,4)
	update_wave_array(level_5_count,5)
	
	#print(current_wave_array)
	current_wave_array.shuffle()
	
	
	max_targets_in_current_wave = number_of_targets_to_move(level_0_count,level_1_count,level_2_count,level_3_count,level_4_count,level_5_count)
	
	
	start_reparent_timer()
	
	
func update_wave_array(count,level) -> void:
	for i: int in range(count):
		current_wave_array.append(level)
	
func number_of_targets_to_move(level_0_count,level_1_count,level_2_count,level_3_count,level_4_count,level_5_count) -> int:
	var number_to_move: int = level_0_count + level_1_count + level_2_count + level_3_count + level_4_count + level_5_count
		
	return number_to_move
	
func reparent_target_to_path() -> void:
	var available_targets: Array = get_children()
	
	var target_to_reparent: PathFollow3D = available_targets.pop_front()
	var level_to_assign: int
	
	if current_wave_array.size() > 0:
		level_to_assign = current_wave_array.pop_front()
		
	target_to_reparent.process_mode = PROCESS_MODE_INHERIT
	target_to_reparent.target_level = level_to_assign
	
	var sprite_priority: int = (targets_in_current_wave - 1) % 126 + 1
	
	target_to_reparent.sprite.render_priority = sprite_priority
	target_to_reparent.sprite_blastfx.render_priority = sprite_priority + 1
	
	#opposite numbering
	#target_to_reparent.sprite.render_priority = 126 - ((targets_in_current_wave - 1) % 126)
	
	#print("Target's level: ",target_to_reparent.target_level)
	
	target_to_reparent.reparent(path_3d)
	
func reparent_extra_target_to_path(level:int,progress_ratio:float,offset:float):
	var available_targets: Array = get_children()
	
	var target_to_reparent: PathFollow3D = available_targets.pop_front()
	var level_to_assign: int = level
	
	target_to_reparent.target_level = level_to_assign
	
	target_to_reparent.process_mode = PROCESS_MODE_INHERIT
	target_to_reparent.target_level = level_to_assign
	
	var sprite_priority: int = 126
	target_to_reparent.sprite.render_priority = sprite_priority
	target_to_reparent.sprite_blastfx.render_priority = sprite_priority + 1
	
	target_to_reparent.reparent(path_3d)
	target_to_reparent.progress_ratio = progress_ratio + offset
	
	Messenger.target_added_to_path.emit()
	
