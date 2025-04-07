class_name Menus extends CanvasLayer

static var ref

var show_credits: bool = false

@onready var center_ui: MarginContainer = %Center_UI

@onready var label_center_ui: Label = %Label_Center_Menu


@onready var button_continue: Button = %Button_Continue
@onready var button_game_over_restart: Button = %Button_GameOver_Restart


@onready var button_play: Button = %Button_Play
@onready var button_credits: Button = %Button_Credits

@onready var credits_l: MarginContainer = %Container_Credits_L
@onready var credits_r: MarginContainer = %Container_Credits_R


func _init() -> void:
	ref = self
	
func _ready() -> void:
	button_game_over_restart.pressed.connect(_on_button_restart_pressed)
	button_continue.pressed.connect(_on_button_continue_pressed)
	
	button_play.pressed.connect(_on_button_play_pressed)
	button_credits.pressed.connect(_on_button_credits_pressed)
	
func hide_separators():
	pass

func _on_button_play_pressed():
	%Path.visible = true
	%Baby.visible = true
	center_ui.visible = false
	HUD.ref.top_ui.visible = true
	HUD.ref.bottom_ui.visible = true
	HUD.ref.side_ui.visible = true
	
	
	if show_credits:
		_on_button_credits_pressed()	
		

func _on_button_credits_pressed():
	show_credits = !show_credits
	
	if show_credits:
		credits_r.visible = true
		credits_l.visible = true
		credits_r.get_node("animation").play("scroll")
		credits_l.get_node("animation").play("scroll")
	else:
		credits_r.get_node("animation").stop()
		credits_l.get_node("animation").stop()
		
		credits_r.visible = false
		credits_l.visible = false
	
func _on_button_restart_pressed() -> void:
	Globals.reload()
	
func _on_button_continue_pressed() -> void:
	HUD.ref._on_button_settings_pressed()
