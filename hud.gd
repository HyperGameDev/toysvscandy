extends CanvasLayer

@onready var tower_collector: Node3D = %Tower_Collector
@onready var hold_target: Node3D = %Hold_Target

@onready var animation_bottom_ui: AnimationPlayer = %Animation_Bottom_UI

@onready var button_start_wave: Button = %"Button_Start-Wave"
@onready var label_wave: Label = %Label_Wave

@onready var button_tower_1: Button = %Button_Tower_1
@onready var tower_1_scene: PackedScene = preload("res://Assets/towers/tower_1_toysoldier.tscn")

@onready var button_tower_2: Button = %Button_Tower_2
@onready var tower_2_scene: PackedScene = preload("res://Assets/towers/tower_2_spinningtop.tscn")

@onready var button_tower_3: Button = %Button_Tower_3
@onready var tower_3_scene: PackedScene = preload("res://Assets/towers/tower_3_snowglobe.tscn")


func _ready() -> void:
	Messenger.tower_spawned.connect(_on_tower_spawned)
	Messenger.tower_placed.connect(_on_tower_placed)
	
	button_start_wave.pressed.connect(_on_button_start_wave_pressed)
	
	button_tower_1.pressed.connect(_on_tower_1_pressed)
	button_tower_2.pressed.connect(_on_tower_2_pressed)
	button_tower_3.pressed.connect(_on_tower_3_pressed)
	
func _on_tower_spawned():
	animation_bottom_ui.play("hide_bottom_ui")
	
func _on_tower_placed(_tower):
	animation_bottom_ui.play("show_bottom_ui")

func _on_button_start_wave_pressed():
	Messenger.start_next_wave.emit()
	label_wave.text = str(Globals.wave_number)

func _on_tower_1_pressed():
	if hold_target.cursor_available:
		var tower_1_spawn: Node3D = tower_1_scene.instantiate()
		tower_collector.add_child(tower_1_spawn)
	
func _on_tower_2_pressed():
	if hold_target.cursor_available:
		var tower_2_spawn: Node3D = tower_2_scene.instantiate()
		tower_collector.add_child(tower_2_spawn)
	
func _on_tower_3_pressed():
	if hold_target.cursor_available:
		var tower_3_spawn: Node3D = tower_3_scene.instantiate()
		tower_collector.add_child(tower_3_spawn)
	
