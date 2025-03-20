extends CanvasLayer
@onready var label_menu_states: Label = %"Label_Menu-States"

@onready var tower_collector: Node3D = %Tower_Collector
@onready var cursor_target: Node3D = %Cursor_Target

var menu_state: menu_states
enum menu_states {DEFAULT,HOLDING,SELECTED}

@onready var animation_bottom_ui: AnimationPlayer = %Animation_Bottom_UI
@onready var animation_side_ui: AnimationPlayer = %Animation_Side_UI
var side_ui_visible: bool = false

@onready var button_start_wave: Button = %"Button_Start-Wave"
@onready var label_wave: Label = %Label_Wave

@onready var button_tower_1: Button = %Button_Tower_1
@onready var tower_1_scene: PackedScene = preload("res://Assets/towers/tower_1_toysoldier.tscn")

@onready var button_tower_2: Button = %Button_Tower_2
@onready var tower_2_scene: PackedScene = preload("res://Assets/towers/tower_2_spinningtop.tscn")

@onready var button_tower_3: Button = %Button_Tower_3
@onready var tower_3_scene: PackedScene = preload("res://Assets/towers/tower_3_snowglobe.tscn")


func _ready() -> void:
	update_menu_state(menu_states.DEFAULT)
	Messenger.tower_spawned.connect(_on_tower_spawned)
	Messenger.tower_placed.connect(_on_tower_placed)
	Messenger.tower_selected.connect(_on_tower_selected)
	
	button_start_wave.pressed.connect(_on_button_start_wave_pressed)
	
	button_tower_1.pressed.connect(_on_tower_1_pressed)
	button_tower_2.pressed.connect(_on_tower_2_pressed)
	button_tower_3.pressed.connect(_on_tower_3_pressed)
	
func update_menu_state(state):
	menu_state = state
	#%"Animation_Menu-States".play("menu_state_change")
	#label_menu_states.text = "Menu State: " + str(menu_states.keys()[menu_state])
	
func _on_tower_spawned(_tower):	
	if menu_state != menu_states.HOLDING:
		animation_bottom_ui.play("hide_bottom_ui")
		if menu_state != menu_states.DEFAULT:
			animation_side_ui.play("hide_side_ui")
		update_menu_state(menu_states.HOLDING)
	
func _on_tower_placed(_tower):
	if menu_state != menu_states.DEFAULT:
		animation_bottom_ui.play("show_bottom_ui")
		update_menu_state(menu_states.DEFAULT)
	
func _on_tower_selected(tower):
	if tower == null:
		if menu_state != menu_states.DEFAULT:
			animation_side_ui.play("hide_side_ui")
			update_menu_state(menu_states.DEFAULT)
			
	else: #am actual tower is selected
		if menu_state != menu_states.SELECTED:
			animation_side_ui.play("show_side_ui")
			update_menu_state(menu_states.SELECTED)	

func _on_button_start_wave_pressed():
	Messenger.start_next_wave.emit()
	label_wave.text = str(Globals.wave_number)

func _on_tower_1_pressed():
	if cursor_target.cursor_available:
		var tower_1_spawn: Node3D = tower_1_scene.instantiate()
		tower_collector.add_child(tower_1_spawn)
	
func _on_tower_2_pressed():
	if cursor_target.cursor_available:
		var tower_2_spawn: Node3D = tower_2_scene.instantiate()
		tower_collector.add_child(tower_2_spawn)
	
func _on_tower_3_pressed():
	if cursor_target.cursor_available:
		var tower_3_spawn: Node3D = tower_3_scene.instantiate()
		tower_collector.add_child(tower_3_spawn)
	
