extends Node3D

@onready var animation: AnimationTree = %AnimationTree


func _ready() -> void:
	Messenger.target_missed.connect(_on_target_missed)
	
func _on_target_missed(_target_level):
	animation.set("parameters/eat/request", 1)
