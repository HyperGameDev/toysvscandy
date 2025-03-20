class_name HUD extends CanvasLayer

static var ref

@onready var tower_collector: Node3D = %Tower_Collector
@onready var cursor_target: Node3D = %Cursor_Target

@onready var tower_preview: TextureRect = %"TextureRect_Tower-Preview"

var tower_last_selected: Node3D


var menu_state: menu_states
enum menu_states {DEFAULT,HOLDING,SELECTED}

var side_menu_side: side_menu_sides
enum side_menu_sides {RIGHT,LEFT}


var side_ui_hovered: bool = false

@onready var side_ui: MarginContainer = %Side_UI
@onready var button_sell: Button = %Button_Sell
@onready var button_upgrade_left: Button = %Button_Upgrade_Left
@onready var button_upgrade_right: Button = %Button_Upgrade_Right

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

func _init() -> void:
	ref = self

func _ready() -> void:
	update_menu_state(menu_states.DEFAULT)
	update_side_menu_state(side_menu_sides.RIGHT)
	
	side_ui.mouse_entered.connect(_on_side_ui_hover)
	side_ui.mouse_exited.connect(_on_side_ui_unhover)
	button_sell.mouse_entered.connect(_on_button_sell_hover)
	button_sell.mouse_exited.connect(_on_button_sell_unhover)
	button_upgrade_left.mouse_entered.connect(_on_button_upgrade_left_hover)
	button_upgrade_left.mouse_exited.connect(_on_button_upgrade_left_unhover)
	button_upgrade_right.mouse_entered.connect(_on_button_upgrade_right_hover)
	button_upgrade_right.mouse_exited.connect(_on_button_upgrade_right_unhover)
	
	
	Messenger.tower_spawned.connect(_on_tower_spawned)
	Messenger.tower_placed.connect(_on_tower_placed)
	Messenger.tower_selected.connect(_on_tower_selected)
	
	button_start_wave.pressed.connect(_on_button_start_wave_pressed)
	
	button_sell.pressed.connect(_on_button_sell_pressed)
	
	button_tower_1.pressed.connect(_on_tower_1_pressed)
	button_tower_2.pressed.connect(_on_tower_2_pressed)
	button_tower_3.pressed.connect(_on_tower_3_pressed)
	
#func _physics_process(delta: float) -> void:
	#print("UI Hovered ",side_ui_hovered)
	
func update_menu_state(state):
	menu_state = state
	%"Animation_Menu-States".play("menu_state_change")
	%"Label_Menu-States".text = "Menu State: " + str(menu_states.keys()[menu_state])

func update_side_menu_state(state):
	side_menu_side = state
	%"Label_Side-Menu-States".text = "Side Menu: " + str(side_menu_sides.keys()[side_menu_side])
	
func set_side_ui_hover_bool(hover_bool:bool) -> void:
	side_ui_hovered = hover_bool
	
func _on_side_ui_hover() -> void:
	set_side_ui_hover_bool(true)
func _on_side_ui_unhover() -> void:
	set_side_ui_hover_bool(false)
	
func _on_button_sell_hover() -> void:
	set_side_ui_hover_bool(true)
func _on_button_sell_unhover() -> void:
	set_side_ui_hover_bool(false)
	
func _on_button_upgrade_left_hover() -> void:
	set_side_ui_hover_bool(true)
func _on_button_upgrade_left_unhover() -> void:
	set_side_ui_hover_bool(false)
	
func _on_button_upgrade_right_hover() -> void:
	set_side_ui_hover_bool(true)
func _on_button_upgrade_right_unhover() -> void:
	set_side_ui_hover_bool(false)
	

	
func _on_tower_spawned(_tower):	
	if menu_state != menu_states.HOLDING and side_ui_hovered == false:
		animation_bottom_ui.play("hide_bottom_ui")
		if menu_state != menu_states.DEFAULT and side_ui_hovered == false:
			hide_side_ui()
				
		update_menu_state(menu_states.HOLDING)
	
func _on_tower_placed(_tower):
	if menu_state != menu_states.DEFAULT and side_ui_hovered == false:
		animation_bottom_ui.play("show_bottom_ui")
		
		update_menu_state(menu_states.DEFAULT)
	
func _on_tower_selected(tower):
	if tower == null:
		if menu_state != menu_states.DEFAULT and side_ui_hovered == false:
			hide_side_ui()
			update_menu_state(menu_states.DEFAULT)
	else:  # An actual tower is selected
		tower_last_selected = tower
		setup_tower_ui(tower)
		var selected_tower_on_right: bool = tower.global_position.z <= 0  # Determine if the tower is on the right side

		if menu_state != menu_states.SELECTED and side_ui_hovered == false:
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

func setup_tower_ui(tower) -> void:
	var tower_dictionary: Dictionary = Globals.tower_data[str(tower.tower_types.keys()[tower.tower_type])]
	tower_preview.texture.viewport_path = tower_dictionary["icon"]

func hide_side_ui():
	if side_menu_side == side_menu_sides.LEFT:
		animation_side_ui.play("hide_side_ui_left")
	else:
		animation_side_ui.play("hide_side_ui_right")

func _on_button_start_wave_pressed():
	Messenger.start_next_wave.emit()
	label_wave.text = str(Globals.wave_number)
	
func _on_button_sell_pressed():
	tower_last_selected.queue_free()
	hide_side_ui()
	update_menu_state(menu_states.DEFAULT)

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
	
