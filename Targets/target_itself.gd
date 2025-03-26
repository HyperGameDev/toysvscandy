extends Target

signal attack_target_detected

@onready var timer_frozen: Timer = %Timer_Frozen

var bool_check: bool = true

# HEY BTW if you add a ready, make sure to add super._ready into it!!

func _ready() -> void:
	super._ready()
	Messenger.target_frozen.connect(_on_target_frozen)
	
	timer_frozen.timeout.connect(_on_timer_frozen_timeout)

func _process(_delta: float) -> void:
	#super._process(_delta)
	if progress_ratio >= .99:
		reparent_to_collector()

func _on_target_frozen(target) -> void:
	if target == self:
		timer_frozen.start(3.)
		
func _on_timer_frozen_timeout() -> void:
	frozen = false
	speed = speed_array[target_level]
