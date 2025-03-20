extends CanvasLayer

@onready var tower_collector: Node3D = %Tower_Collector
@onready var cursor_target: Node3D = %Cursor_Target

var menu_state: menu_states
enum menu_states {DEFAULT,HOLDING,SELECTED}

var side_menu_side: side_menu_sides
enum side_menu_sides {RIGHT,LEFT}

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
	update_side_menu_state(side_menu_sides.RIGHT)
	Messenger.tower_spawned.connect(_on_tower_spawned)
	Messenger.tower_placed.connect(_on_tower_placed)
	Messenger.tower_selected.connect(_on_tower_selected)
	
	button_start_wave.pressed.connect(_on_button_start_wave_pressed)
	
	button_tower_1.pressed.connect(_on_tower_1_pressed)
	button_tower_2.pressed.connect(_on_tower_2_pressed)
	button_tower_3.pressed.connect(_on_tower_3_pressed)
	
func update_menu_state(state):
	menu_state = state
	%"Animation_Menu-States".play("menu_state_change")
	%"Label_Menu-States".text = "Menu State: " + str(menu_states.keys()[menu_state])

func update_side_menu_state(state):
	side_menu_side = state
	%"Label_Side-Menu-States".text = "Side Menu: " + str(side_menu_sides.keys()[side_menu_side])
	
func _on_tower_spawned(_tower):	
	if menu_state != menu_states.HOLDING:
		animation_bottom_ui.play("hide_bottom_ui")
		if menu_state != menu_states.DEFAULT:
			hide_side_ui()
				
		update_menu_state(menu_states.HOLDING)
	
func _on_tower_placed(_tower):
	if menu_state != menu_states.DEFAULT:
		animation_bottom_ui.play("show_bottom_ui")
		
		update_menu_state(menu_states.DEFAULT)
	
func _on_tower_selected(tower):
	if tower == null:
		print("Null tower selected")
		if menu_state != menu_states.DEFAULT:
			hide_side_ui()
			update_menu_state(menu_states.DEFAULT)
	else:  # An actual tower is selected
		var selected_tower_on_right: bool = tower.global_position.z <= 0  # Determine if the tower is on the right side

		if menu_state != menu_states.SELECTED:
			# Show the correct side menu for the first selected tower
			if selected_tower_on_right:
				update_side_menu_state(side_menu_sides.RIGHT)
				animation_side_ui.play("show_side_ui_right")
			else:
				update_side_menu_state(side_menu_sides.LEFT)
				animation_side_ui.play("show_side_ui_left")
			update_menu_state(menu_states.SELECTED)
			
		else:  # Already in SELECTED state, check if the side needs to switch
			if selected_tower_on_right and side_menu_side == side_menu_sides.LEFT:
				# Switch from LEFT to RIGHT
				hide_side_ui()
				update_side_menu_state(side_menu_sides.RIGHT)
				animation_side_ui.play("show_side_ui_right")
			elif not selected_tower_on_right and side_menu_side == side_menu_sides.RIGHT:
				# Switch from RIGHT to LEFT
				hide_side_ui()
				update_side_menu_state(side_menu_sides.LEFT)
				animation_side_ui.play("show_side_ui_left")

				

func hide_side_ui():
	if side_menu_side == side_menu_sides.LEFT:
		animation_side_ui.play("hide_side_ui_left")
	else:
		animation_side_ui.play("hide_side_ui_right")

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
	
