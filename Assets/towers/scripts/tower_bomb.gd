class_name Tower_Bomb extends Single_Towers


func _on_tower_placed(tower) -> void:
	lockdown_launchpad()
		
func lockdown_launchpad() -> void:
	%Pad.top_level = true
	%Wing_L.top_level = true
	%Wing_R.top_level = true
