@tool
extends EditorPlugin

var main_plugin := preload("res://addons/tsv_to_credits_list/main_plugin.tscn").instantiate()

var _file_dialog: FileDialog = FileDialog.new()

var maximum_credit_length: int = 100
var lines_to_generate: int

var title_font_size: int = 52

var titles_array: Array[String] = []
var credits_dictionary: Dictionary[String,Array] = {
}

func _enter_tree() -> void:
	add_control_to_bottom_panel(main_plugin,"TSV to Credits List")
	
	create_file_dialog()
	
	scene_changed.connect(_on_scene_changed)
	
	main_plugin.button_upload.pressed.connect(_on_upload_pressed)
	main_plugin.button_generate.pressed.connect(_on_generate_pressed)
	main_plugin.button_reset.pressed.connect(_on_reset_pressed)

func create_file_dialog() -> void:
	var base_control : Panel = EditorInterface.get_base_control()
	
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.filters = PackedStringArray(["*.tsv"])
	_file_dialog.connect("file_selected",_on_file_selected)
	
	base_control.add_child(_file_dialog)
	
func _on_upload_pressed() -> void:
	_file_dialog.show()
	_file_dialog.popup_centered_ratio(.5)
	
func _on_reset_pressed() -> void:
	show_preview_elements(false)
	main_plugin.file_name.text = "Upload a file..."
	reset_buttons(false)
	
func reset_buttons(do_reset:bool) -> void:
	main_plugin.button_reset.visible = do_reset
	main_plugin.button_upload.disabled = do_reset

func _on_file_selected(path) -> void:
	_file_dialog.hide()
	reset_buttons(true)
	
	clear_previous_tsv_data()
	
	var tsv_file_path: String = path
	main_plugin.file_name.text = tsv_file_path
	
	load_tsv(tsv_file_path)
	
func clear_previous_tsv_data() -> void:
	var tsv_table_rows: Array[Node] = main_plugin.vbox_tsv_table.get_children()
	titles_array.clear()
	for row in tsv_table_rows:
		if row.name == "Row0":
			continue
		row.queue_free()
		

func load_tsv(path) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var tsv_data: String = file.get_as_text()
	
	parse_tsv(tsv_data)
	
func parse_tsv(data) -> void:
	var lines: PackedStringArray = data.split("\n")
	parse_credits(lines)
	
func parse_credits(lines) -> void:
	var titles_data: PackedStringArray = lines[0].split("\t")
	var names_array: Array[Array] = []
	
	for line in lines:
		var line_data: PackedStringArray = line.split("\t")
		if total_above_zero(line_data):
			var name_string: String = line_data[0] # [column number] Could this be moved to the next for loop?
			
			for title in range(titles_data.size()): # iterate through titles
				if title > 1:
					var credit_int: int = int(line_data[title]) # (row[column])
					if credit_int > 0:
						names_array.append([name_string,credit_int,check_title(titles_data[title])])
					
			names_array.sort_custom(func(a, b): return a[1] > b[1])

			for title in range(titles_data.size()):
				if title > 1:
					var title_string: String = check_title(titles_data[title])
					#var sorted_name_string: String = names_array[[0]]
					
					if not credits_dictionary.has(title_string):
						credits_dictionary[title_string] = []
	
	for i in names_array:
		var title_key: String = i[2]
		var name_to_add: String = i[0]
		
		if credits_dictionary[title_key].has(name_to_add):
			continue
		else:
			credits_dictionary[title_key].append(name_to_add)
			continue
	
	for title in titles_data.slice(2):
		#find titles but ignore first two columns
		
		titles_array.append(title.substr(0,maximum_credit_length))
		
	lines_to_generate = titles_array.size()
	if lines_to_generate > 0:
		generate_preview()
	
	#print("\r\r",credits_dictionary)
	
func total_above_zero(line_data) -> bool:
	return int(line_data[1]) > 0 # Check column 2 (totals) for anything not 0
	
func check_title(title:String) -> String:
	if title.find("\r") != -1:  # Checks if \r exists in the string
		return title.replace("\r", "")
	else:
		return title

func generate_preview() -> void:
	generate_table_preview()
	show_tsv_to_generate()
	
func generate_table_preview() -> void:
	var tsv_table: VBoxContainer = main_plugin.vbox_tsv_table
	
	for i in lines_to_generate:
		var tsv_row := preload("res://addons/tsv_to_credits_list/row.tscn").instantiate()
		tsv_table.add_child(tsv_row)
		tsv_row.get_node("%Label_Credit").text = titles_array[i]
		#print(titles_array[i])
		
func _on_scene_changed(scene):
	var generate_button: Button = main_plugin.button_generate
	
	if scene == null:
		generate_button.disabled = true
		generate_button.text = "[SCENE IS EMPTY]"
	else:
		generate_button.disabled = false
		generate_button.text = "Generate (in " + str(scene.name) + ")"
	
func show_preview_elements(do_show: bool) -> void:
	var tsv_preview: PanelContainer = main_plugin.tsv_preview
	var tsv_instructions: Label = main_plugin.tsv_instructions
	var generate_button: Button = main_plugin.button_generate 
	
	tsv_preview.visible = do_show
	tsv_instructions.visible = do_show
	generate_button.visible = do_show

func show_tsv_to_generate() -> void:
	var scene_being_edited := get_editor_interface().get_edited_scene_root()
	
	show_preview_elements(true)
	
	_on_scene_changed(scene_being_edited)
	
func _on_generate_pressed() -> void:
	var scene_being_edited := get_editor_interface().get_edited_scene_root()
	var add_a_list: bool = true
	
	var hbox_error: HBoxContainer = main_plugin.hbox_error
	var label_error_msg: Label = main_plugin.label_error_msg
	
	for node in scene_being_edited.get_children():
		if node is CreditsList_TSV_Import:
			add_a_list = false
			
			hbox_error.visible = true
			label_error_msg.text = "A credits lists already exists!"
			
			break
			
	if add_a_list:
		hbox_error.visible = false
		var credits_list := preload("res://addons/tsv_to_credits_list/tsv_credits_list.tscn").instantiate()

		if scene_being_edited:
			scene_being_edited.add_child(credits_list)
			generate_credits(scene_being_edited,credits_list)
			
	
func generate_credits(scene_being_edited,list_to_add_credits_to) -> void:
	var credits_container: ScrollContainer = list_to_add_credits_to.credits_container
	var labels_vbox: VBoxContainer = list_to_add_credits_to.labels_vbox
	var credit_titles_count_max: int = credits_dictionary.size()
	var credit_titles_count_current: int = 0
	var credit_titles_keys = credits_dictionary.keys()
	
	for credit_title in range(credit_titles_count_max):
		var credit_title_key: String = credit_titles_keys[credit_title]
		create_title_label(scene_being_edited,labels_vbox,credit_title_key)
		
		var credit_names_count_max: int = credits_dictionary[credit_title_key].size()
		for credit_name in range(credit_names_count_max):
			var credit_name_to_add: String = credits_dictionary[credit_title_key][credit_name]
			create_name_label(scene_being_edited,labels_vbox,credit_name_to_add)
	

	add_list_to_edited_scene(scene_being_edited,list_to_add_credits_to)
	
func create_title_label(scene_being_edited,vbox: VBoxContainer, credit_title: String) -> void:
	var title_label := preload("res://addons/tsv_to_credits_list/label_credit_1.tscn").instantiate()
	vbox.add_child(title_label)
	title_label.owner = scene_being_edited
	title_label.text = "\r\r\r" + credit_title
	title_label.add_theme_font_size_override("font_size",title_font_size)
	
	var title_separator := preload("res://addons/tsv_to_credits_list/title_separator.tscn").instantiate()
	vbox.add_child(title_separator)
	title_separator.owner = scene_being_edited
	
func create_name_label(scene_being_edited,vbox: VBoxContainer, credit_name: String) -> void:
	var name_label := preload("res://addons/tsv_to_credits_list/label_credit_1.tscn").instantiate()
	vbox.add_child(name_label)
	name_label.owner = scene_being_edited
	name_label.text = credit_name
	
func add_list_to_edited_scene(scene_with_credits,credits_list_to_add):
				
	credits_list_to_add.owner = scene_with_credits
	
	
	
	if not get_parent().is_editable_instance(credits_list_to_add):
		get_parent().set_editable_instance(credits_list_to_add,true)
	
	

func _exit_tree() -> void:
	remove_control_from_bottom_panel(main_plugin)
	main_plugin.queue_free()
