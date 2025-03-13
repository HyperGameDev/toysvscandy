class_name Projectile extends MeshInstance3D


func _ready() -> void:
	destroy_self()
	
func destroy_self():
	await get_tree().create_timer(.3).timeout
	queue_free()
