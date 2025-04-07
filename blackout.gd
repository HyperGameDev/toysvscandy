extends CanvasLayer

func _ready() -> void:
	%animation_blackout.play("fade_in")

func load_game_begin():
	HUD.ref.bottom_ui.visible = false
	Menus.ref.center_ui.visible = true
