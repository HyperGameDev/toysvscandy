extends Target


var bool_check: bool = true

# HEY BTW if you add a ready, make sure to add super._ready into it!!
func _process(_delta: float) -> void:
	#super._process(_delta)
	if progress_ratio >= .99:
		reparent(Target_Collector.ref)
		position = Vector3.ZERO
		progress = 0.
		process_mode = PROCESS_MODE_DISABLED
