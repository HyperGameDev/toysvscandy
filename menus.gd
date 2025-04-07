class_name Menus extends CanvasLayer

static var ref

@onready var center_ui: MarginContainer = %Center_UI

@onready var label_center_ui: Label = %Label_Center_Menu


@onready var button_continue: Button = %Button_Continue
@onready var button_game_over_restart: Button = %Button_GameOver_Restart
@onready var button_continue: Button = %Button_Continue


@onready var button_play: Button = %Button_Play
@onready var button_credits: Button = %Button_Credits


func _init() -> void:
	ref = self
	
func _ready() -> void:
	button_game_over_restart.pressed.connect(_on_button_restart_pressed)
	button_continue.pressed.connect(_on_button_continue_pressed)
	
func _on_button_restart_pressed() -> void:
	Globals.reload()
	
func _on_button_continue_pressed() -> void:
	center_ui.visible = false
