class_name Tower_Button extends Button

func _ready() -> void:
	fetch_viewport()
	
func fetch_viewport() -> void:
	for node in get_children():
		if node is SubViewport:
			var fetched_viewport: SubViewport = node
			setup_button_viewport(fetched_viewport)
			break
	
func setup_button_viewport(fetched_viewport) -> void:
	var button_viewport: SubViewport = fetched_viewport

	add_theme_icon_override("icon",button_viewport.get_texture())

#func add_something_to_viewport(viewport: SubViewport):
	## Use the existing health_bar instance
	#health_bar = ProgressBar.new()
	#viewport.add_child(health_bar)
