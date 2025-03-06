extends CanvasLayer

@onready var button_start_wave: Button = %"Button_Start-Wave"
@onready var label_wave: Label = %Label_Wave

func _ready() -> void:
	button_start_wave.pressed.connect(_on_button_start_wave_pressed)

func _on_button_start_wave_pressed():
	Messenger.start_next_wave.emit()
	label_wave.text = str(Globals.wave_number)
