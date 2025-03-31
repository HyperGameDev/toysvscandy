class_name HUD extends CanvasLayer

static var ref

@onready var tower_collector: Node3D = %Tower_Collector
@onready var cursor_target: Node3D = %Cursor_Target

@onready var tower_preview: TextureRect = %"TextureRect_Tower-Preview"
@onready var tower_name: Label = %"Label_Tower-Name"

var tower_last_selected: Node3D

var menu_state: menu_states
enum menu_states {DEFAULT,HOLDING,SELECTED}

var side_menu_side: side_menu_sides
enum side_menu_sides {RIGHT,LEFT}


var side_ui_hovered: bool = false

@onready var bottom_ui: MarginContainer = %Bottom_UI
@onready var side_ui: MarginContainer = %Side_UI

@onready var button_sell: Button = %Button_Sell
@onready var sell_amount: Label = %Label_Sell_Amount


@onready var upgrade_2_vbox: VBoxContainer = %VBox_Upgrade2

@onready var button_upgrade_left: Button = %Button_Upgrade_Left
@onready var button_upgrade_right: Button = %Button_Upgrade_Right

@onready var upgrade_left_cost: Label = %Label_Upgrade_Left_Cost
@onready var upgrade_right_cost: Label = %Label_Upgrade_Right_Cost


@onready var animation_bottom_ui: AnimationPlayer = %Animation_Bottom_UI
@onready var animation_side_ui: AnimationPlayer = %Animation_Side_UI

@onready var label_points: Label = %Label_Points
@onready var label_health: Label = %Label_Health



var side_ui_visible: bool = false

@onready var button_start_wave: Button = %"Button_Start-Wave"
@onready var label_wave: Label = %Label_Wave

@onready var button_tower_1: Button = %Button_Tower_1
@onready var tower_1_scene: PackedScene = preload("res://Assets/towers/tower_1_toysoldier.tscn")

@onready var button_tower_2: Button = %Button_Tower_2
@onready var tower_2_scene: PackedScene = preload("res://Assets/towers/tower_2_spinningtop.tscn")

@onready var button_tower_3: Button = %Button_Tower_3
@onready var tower_3_scene: PackedScene = preload("res://Assets/towers/tower_3_snowglobe.tscn")

@onready var button_tower_4: Button = %Button_Tower_4
@onready var tower_4_scene: PackedScene = preload("res://Assets/towers/tower_4_toyrocket.tscn")


@onready var button_tower_5: Button = %Button_Tower_5
@onready var tower_5_scene: PackedScene = preload("res://Assets/towers/tower_5_supersoldier.tscn")

func _init() -> void:
	ref = self

func _ready() -> void:
	update_ui_values()
	update_menu_state(menu_states.DEFAULT)
	update_side_menu_state(side_menu_sides.RIGHT)
	
	side_ui.mouse_entered.connect(_on_side_ui_hover)
	side_ui.mouse_exited.connect(_on_side_ui_unhover)
	button_sell.mouse_entered.connect(_on_button_sell_hover)
	button_sell.mouse_exited.connect(_on_button_sell_unhover)
	
	button_upgrade_left.mouse_entered.connect(_on_button_upgrade_left_hover)
	button_upgrade_left.mouse_exited.connect(_on_button_upgrade_left_unhover)
	button_upgrade_left.pressed.connect(_on_button_upgrade_left_pressed)
	
	button_upgrade_right.mouse_entered.connect(_on_button_upgrade_right_hover)
	button_upgrade_right.mouse_exited.connect(_on_button_upgrade_right_unhover)
	button_upgrade_right.pressed.connect(_on_button_upgrade_right_pressed)
	
	
	Messenger.tower_spawned.connect(_on_tower_spawned)
	Messenger.tower_placed.connect(_on_tower_placed)
	Messenger.tower_selected.connect(_on_tower_selected)
	
	Messenger.updated_health.connect(_on_updated_health)
	Messenger.updated_points.connect(_on_updated_points)
	
	
	button_start_wave.pressed.connect(_on_button_start_wave_pressed)
	Messenger.wave_ended.connect(_on_wave_ended)
	
	button_sell.pressed.connect(_on_button_sell_pressed)
	
	button_tower_1.pressed.connect(_on_tower_1_pressed)
	button_tower_2.pressed.connect(_on_tower_2_pressed)
	button_tower_3.pressed.connect(_on_tower_3_pressed)
	button_tower_4.pressed.connect(_on_tower_4_pressed)
	button_tower_5.pressed.connect(_on_tower_5_pressed)
	
#func _physics_process(delta: float) -> void:
	#print("UI Hovered ",side_ui_hovered)
	
func _input(_event: InputEvent) -> void:
	if menu_state == menu_states.HOLDING:
		if Input.is_action_just_pressed("Cancel") or Input.is_action_just_pressed("Action2"):
			Messenger.tower_unheld.emit()
			held_tower_unheld()
	
func update_menu_state(state):
	menu_state = state
	%"Animation_Menu-States".play("menu_state_change")
	%"Label_Menu-States".text = "Menu State: " + str(menu_states.keys()[menu_state])

func update_side_menu_state(state):
	side_menu_side = state
	%"Label_Side-Menu-States".text = "Side Menu: " + str(side_menu_sides.keys()[side_menu_side])
	
func _on_button_upgrade_left_pressed() -> void:
	upgrade_tower(tower_last_selected,1)

func _on_button_upgrade_right_pressed() -> void:
	upgrade_tower(tower_last_selected,2)
	
func upgrade_tower(tower:Node3D,upgrade_number:int) -> void:
	var tower_dictionary: Dictionary = Globals.tower_data[str(tower.tower_types.keys()[tower.tower_type])]
	
	var upgrade_cost: int = tower_dictionary["upgrade" + str(upgrade_number) + "_cost"]
	var upgrade_name: String = tower_dictionary["upgrade" + str(upgrade_number) + "_name"]
	
	if upgrade_cost <= Globals.points:
		tower.towers_upgraded[str(tower.tower_types.keys()[tower.tower_type])]["upgrade" + str(upgrade_number) + "_upgraded"] = true
		Messenger.points_spent.emit(upgrade_cost)
		Messenger.tower_upgraded.emit(tower,upgrade_name) 
		setup_tower_ui(tower_last_selected)
	
	
	
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
	
func update_ui_values() -> void:
	_on_updated_health()
	_on_updated_points()
	
func _on_updated_health() -> void:
	label_health.text = str(clamp(Globals.health,0,40))
	
func _on_updated_points() -> void:
	var current_points: int = Globals.points
	label_points.text = str(current_points)
	update_tower_buttons(current_points)
	
func update_tower_buttons(points):
	if points < 250:
		button_tower_1.disabled = true
	else:
		button_tower_1.disabled = false
	
	if points < 400:
		button_tower_2.disabled = true
	else:
		button_tower_2.disabled = false
		
	if points < 850:
		button_tower_3.disabled = true
	else:
		button_tower_3.disabled = false
		
	if points < 900:
		button_tower_4.disabled = true
	else:
		button_tower_4.disabled = false
		
	if points < 4000:
		button_tower_5.disabled = true
	else:
		button_tower_5.disabled = false

func _on_tower_spawned(_tower):	
	if menu_state != menu_states.HOLDING and side_ui_hovered == false:
		animation_bottom_ui.play("hide_bottom_ui")
		if menu_state != menu_states.DEFAULT and side_ui_hovered == false:
			hide_side_ui()
				
		update_menu_state(menu_states.HOLDING)
	
func _on_tower_placed(_tower):
	held_tower_unheld()
		
func held_tower_unheld():
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
		setup_tower_ui(tower_last_selected)
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
	tower_name.text = tower_dictionary["tower_name"]
	
	sell_amount.text = str(calculate_sold_amount(tower))
	
	var upgrade1_cost: int = tower_dictionary["upgrade1_cost"]
	
	if tower.towers_upgraded[str(tower.tower_types.keys()[tower.tower_type])]["upgrade1_upgraded"] == false:
		button_upgrade_left.disabled = false
		button_upgrade_left.text = tower_dictionary["upgrade1_name"]
		if upgrade1_cost > Globals.points:
			button_upgrade_left.icon = tower_dictionary["upgrade1_icon_x"]
		else:
			button_upgrade_left.icon = tower_dictionary["upgrade1_icon"]
			
	else:
		button_upgrade_left.disabled = true
		button_upgrade_left.text = "OWNED"

	upgrade_left_cost.text = str(upgrade1_cost)
	
	var has_2_upgrades: bool = tower_dictionary["has_2_upgrades"]
	
	if has_2_upgrades:
		var upgrade2_cost: int = tower_dictionary["upgrade2_cost"]
		if tower.towers_upgraded[str(tower.tower_types.keys()[tower.tower_type])]["upgrade2_upgraded"] == false:
			button_upgrade_right.disabled = false
			button_upgrade_right.text = tower_dictionary["upgrade2_name"]
			
			if upgrade2_cost > Globals.points:
				button_upgrade_right.icon = tower_dictionary["upgrade2_icon_x"]
			else:
				button_upgrade_right.icon = tower_dictionary["upgrade2_icon"]
				
		else:
			button_upgrade_right.disabled = true
			button_upgrade_right.text = "OWNED"
			
		upgrade_right_cost.text = str(upgrade2_cost)
		if upgrade_2_vbox.visible == false:
			upgrade_2_vbox.visible = true
	else:
		upgrade_2_vbox.visible = false
		
func hide_side_ui():
	if side_menu_side == side_menu_sides.LEFT:
		animation_side_ui.play("hide_side_ui_left")
	else:
		animation_side_ui.play("hide_side_ui_right")	
		
func _on_wave_ended() -> void:
	button_start_wave.disabled = false

func _on_button_start_wave_pressed() -> void:
	Messenger.start_next_wave.emit()
	label_wave.text = str(Globals.wave_number)
	button_start_wave.disabled = true
	
func _on_button_sell_pressed() -> void:
	var tower_sold: Node3D = tower_last_selected
	tower_sold.queue_free()
	Messenger.points_earned.emit(calculate_sold_amount(tower_sold))
	hide_side_ui()
	update_menu_state(menu_states.DEFAULT)
	
func calculate_sold_amount(tower) -> int:
	var upgrade1_upgraded: bool = tower.towers_upgraded[str(tower.tower_types.keys()[tower.tower_type])]["upgrade1_upgraded"] 
	var upgrade2_upgraded: bool = tower.towers_upgraded[str(tower.tower_types.keys()[tower.tower_type])]["upgrade2_upgraded"] 
	
	var tower_base_worth: int = Globals.tower_data[str(tower.tower_types.keys()[tower.tower_type])]["tower_cost"]
	var upgrade1_worth: int
	var upgrade2_worth: int
	
	if upgrade1_upgraded:
		upgrade1_worth = Globals.tower_data[str(tower.tower_types.keys()[tower.tower_type])]["upgrade1_cost"]
	else:
		upgrade1_worth = 0
	
	if upgrade2_upgraded:
		upgrade2_worth = Globals.tower_data[str(tower.tower_types.keys()[tower.tower_type])]["upgrade2_cost"]
	else:
		upgrade2_worth = 0
		
	var gross_sell_value: int = tower_base_worth + upgrade1_worth + upgrade2_worth
	var net_sell_value: int = ceili(gross_sell_value * .8)
	
	return net_sell_value
		
	

func _on_tower_1_pressed() -> void:
	if cursor_target.cursor_available:
		var tower_1_spawn: Node3D = tower_1_scene.instantiate()
		tower_collector.add_child(tower_1_spawn)
		Messenger.points_spent.emit(250)
	
func _on_tower_2_pressed() -> void:
	if cursor_target.cursor_available:
		var tower_2_spawn: Node3D = tower_2_scene.instantiate()
		tower_collector.add_child(tower_2_spawn)
		Messenger.points_spent.emit(400)
	
func _on_tower_3_pressed() -> void:
	if cursor_target.cursor_available:
		var tower_3_spawn: Node3D = tower_3_scene.instantiate()
		tower_collector.add_child(tower_3_spawn)
		Messenger.points_spent.emit(850)
		
func _on_tower_4_pressed() -> void:
	if cursor_target.cursor_available:
		var tower_4_spawn: Node3D = tower_4_scene.instantiate()
		tower_collector.add_child(tower_4_spawn)
		Messenger.points_spent.emit(900)
	
func _on_tower_5_pressed() -> void:
	if cursor_target.cursor_available:
		var tower_5_spawn: Node3D = tower_5_scene.instantiate()
		tower_collector.add_child(tower_5_spawn)
		Messenger.points_spent.emit(4000)
