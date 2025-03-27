extends Node

@warning_ignore_start("unused_signal")

signal start_next_wave

signal target_added_to_path
signal target_removed_from_path ##arg1: PathFollow3D = self

signal target_destroyed ##arg1: PathFollow3D = self

signal path_empty


signal target_frozen ##arg1: PathFollow3D = target frozen

signal tower_spawned ##arg1: Node3D = tower self
signal tower_placed ##arg1: Node3D = tower self

signal tower_hovered ##arg1: Node3D = tower self, else null
signal tower_selected ##arg1: Node3D = tower self, else null
