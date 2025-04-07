extends Node

@warning_ignore_start("unused_signal")

signal start_next_wave

signal game_won

signal target_added_to_path ##arg1: PathFollow3d = target_to_reparent
signal target_removed_from_path ##arg1: PathFollow3D = self

signal wave_ended

signal target_missed ##arg1: int = target_level
signal target_attacked

signal tower_upgraded ##arg1: Node3D = tower_last_selected, arg2: String = "upgrade name"; RANGE,DOUBLE,FASTER,+ TIME,BIGGER

signal points_spent ##arg1: int = spent amount
signal points_earned ##arg1: int = tower sold for amount

signal updated_health
signal updated_points

signal target_frozen ##arg1: PathFollow3D = target frozen

signal tower_spawned ##arg1: Node3D = tower self
signal tower_placed ##arg1: Node3D = tower self

signal tower_unheld

signal tower_hovered ##arg1: Node3D = tower self, else null
signal tower_selected ##arg1: Node3D = tower self, else null
