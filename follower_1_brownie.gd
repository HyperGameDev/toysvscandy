class_name Target extends PathFollow3D

@export var speed: float = 10.

func _process(delta: float) -> void:
	progress += speed * delta
