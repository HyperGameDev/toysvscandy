extends Node
var debug: bool = true
var wave_number: int = 0
var health: int = 40
var points: int = 650
var points_debug: int = 24000

var wave_active: bool = false
var targets_left_in_wave: int

var targets_on_path: Variant = []:
	get: 
		return targets_on_path
	set(value):
		targets_on_path = value
		

var upgraded_explode_range: bool = false
var explode_range: float = .05
		 
		

var wave_data = {
	wave_0 = [0, 0, 0, 0, 0, 0],
	wave_1 = [12, 0, 0, 0, 0, 0],
	wave_2 = [25, 0, 0, 0, 0, 0],
	wave_3 = [24, 5, 0, 0, 0, 0],
	wave_4 = [10, 24, 0, 0, 0, 0],
	wave_5 = [30, 25, 0, 0, 0, 0],
	wave_6 = [0, 0, 15, 0, 0, 0],
	wave_7 = [0, 75, 0, 0, 0, 0],
	wave_8 = [70, 70, 0, 0, 0, 0],
	wave_9 = [0, 50, 15, 0, 0, 0],
	wave_10 = [0, 0, 35, 0, 0, 0],
	wave_11 = [0, 0, 0, 15, 0, 0],
	wave_12 = [0, 25, 25, 3, 0, 0],
	wave_13 = [40, 75, 28, 0, 0, 0],
	wave_14 = [0, 0, 0, 28, 0, 0],
	wave_15 = [0, 30, 60, 0, 0, 0],
	wave_16 = [0, 75, 75, 0, 0, 0],
	wave_17 = [0, 140, 45, 0, 0, 0],
	wave_18 = [0, 30, 25, 27, 0, 0],
	wave_19 = [0, 0, 90, 0, 0, 0],
	wave_20 = [0, 0, 24, 48, 0, 0],
	wave_21 = [0, 10, 85, 35, 0, 0],
	wave_22 = [0, 0, 0, 45, 0, 0],
	wave_23 = [0, 0, 35, 64, 0, 0],
	wave_24 = [0, 30, 50, 42, 0, 0],
	wave_25 = [0, 0, 70, 53, 0, 0],
	wave_26 = [0, 0, 0, 85, 0, 0],
	wave_27 = [0, 0, 0, 0, 20, 0],
	wave_28 = [0, 0, 45, 55, 0, 0],
	wave_29 = [0, 0, 0, 125, 19, 0],
	wave_30 = [0, 0, 250, 0, 0, 0],
	wave_31 = [0, 10, 55, 0, 27, 0],
	wave_32 = [0, 0, 25, 20, 23, 0],
	wave_33 = [0, 0, 0, 150, 0, 0],
	wave_34 = [0, 0, 35, 35, 25, 0],
	wave_35 = [0, 0, 85, 110, 0, 0],
	wave_36 = [0, 0, 0, 115, 35, 0],
	wave_37 = [0, 0, 0, 0, 59, 0],
	wave_38 = [0, 0, 0, 220, 0, 0],
	wave_39 = [50, 50, 50, 50, 40, 0],
	wave_40 = [0, 0, 0, 0, 80, 0],
	wave_41 = [0, 0, 0, 0, 20, 40],
	wave_42 = [0, 0, 0, 0, 30, 50],
	wave_43 = [0, 0, 0, 150, 60, 40],
	wave_44 = [0, 0, 0, 0, 120, 0],
	wave_45 = [0, 0, 0, 0, 0, 120],
	wave_46 = [0, 0, 0, 59, 60, 60],
	wave_47 = [0, 0, 0, 79, 70, 40],
	wave_48 = [0, 0, 0, 70, 80, 80],
	wave_49 = [0, 0, 0, 99, 80, 70],
	wave_50 = [0, 0, 0, 0, 99, 100],
}

const tower_data = {
	DART = {
		toy_name = "Toy Soldier",
		icon = "%SubViewport_Tower_1",
		upgrade_has2 = true,
		upgrade1_name = "DOUBLE",
		upgrade1_cost = 210,
		upgrade2_name = "RANGE",
		upgrade2_cost = 100
		
	},
	TACK = {
		toy_name = "Spinning Top",
		icon = "%SubViewport_Tower_2",
		upgrade_has2 = true,
		upgrade1_name = "FASTER",
		upgrade1_cost = 250,
		upgrade2_name = "RANGE",
		upgrade2_cost = 150
	},
	FREEZE = {
		toy_name = "Snowglobe",
		icon = "%SubViewport_Tower_3",
		upgrade_has2 = true,
		upgrade1_name = "+ TIME",
		upgrade1_cost = 450,
		upgrade2_name = "RANGE",
		upgrade2_cost = 300
	},
	BOMB = {
		toy_name = "Rocket",
		icon = "%SubViewport_Tower_4",
		upgrade_has2 = true,
		upgrade1_name = "BIGGER",
		upgrade1_cost = 650,
		upgrade2_name = "RANGE",
		upgrade2_cost = 250
	},
	SUPER = {
		toy_name = "Super Soldier",
		icon = "%SubViewport_Tower_5",
		upgrade_has2 = false,
		upgrade1_name = "RANGE",
		upgrade1_cost = 210,
		upgrade2_name = "",
		upgrade2_cost = 2400
	}
}
func _ready() -> void:
	#TODO:remove
	print("Change wave_data to a constant and remove debug stuff!")
	Messenger.start_next_wave.connect(_on_start_next_wave)
	Messenger.target_added_to_path.connect(_on_target_added_to_path)
	Messenger.target_removed_from_path.connect(_on_target_removed_from_path)
	
	Messenger.wave_ended.connect(_on_wave_ended)
	
	Messenger.target_missed.connect(_on_target_missed)
	Messenger.target_attacked.connect(_on_target_attacked)
	
	if debug:
		add_debug_wave_data()
		points = points_debug
		
func _physics_process(_delta: float) -> void:
	targets_left_in_wave = Target_Collector.ref.current_wave_array.size() + targets_on_path.size()
	if wave_active and targets_left_in_wave <= 0:
		Messenger.wave_ended.emit()
	
func _on_start_next_wave():
	wave_active = true
	wave_number += 1
	
func _on_target_added_to_path() -> void:
	#print("targets added")
	update_path_targets_array()
	
func _on_target_removed_from_path(_target) -> void:
	#print("targets removed")
	update_path_targets_array()
	
func update_path_targets_array() -> void:
	targets_on_path = Path.ref.get_children()

func _on_target_missed(level) -> void:
	var health_lost: int = converted_target_value(level)
	health -= health_lost
	Messenger.updated_health.emit()
	
func _on_target_attacked() -> void:
	points += 1
	Messenger.updated_points.emit()
	
func _on_wave_ended() -> void:
	wave_active = false
	var wave_factor = wave_number - 1
	points += 100 - wave_factor
	Messenger.updated_points.emit()
	
func converted_target_value(level) -> int:
	if level > 3:
		return 9
	else:
		return level + 1
	

func add_debug_wave_data():
	wave_data = {
		wave_0 = [0, 0, 0, 0, 0, 0],
		wave_1 = [1, 1, 1, 0, 0, 0],
		wave_2 = [1, 1, 1, 0, 0, 0],
		wave_3 = [5, 20, 5, 5, 5, 5],
		wave_4 = [5, 20, 5, 5, 5, 5],
		wave_5 = [0, 0, 0, 0, 1, 0],
		wave_6 = [0, 0, 0, 0, 0, 1],
		wave_7 = [0, 0, 0, 0, 1, 0],
		wave_8 = [0, 0, 0, 0, 0, 1],
		wave_9 = [0, 0, 0, 0, 1, 0],
		wave_10 = [0, 0, 0, 0, 0, 1],
		wave_11 = [0, 0, 0, 0, 1, 0],
		wave_12 = [0, 0, 0, 0, 0, 1],
		wave_13 = [0, 0, 0, 0, 1, 0],
		wave_14 = [0, 0, 0, 0, 0, 1],
		wave_15 = [0, 0, 0, 0, 1, 0],
		wave_16 = [0, 0, 0, 0, 0, 1],
		wave_17 = [0, 0, 0, 0, 1, 0],
		wave_18 = [0, 0, 0, 0, 0, 1]

	}
