@tool
extends Control

@onready var button_upload: Button = %Button_Upload
@onready var button_generate: Button = %Button_Generate

@onready var file_name: Label = %Label_FileName

@onready var vbox_tsv_table: VBoxContainer = %VBox_LoadedTSV
@onready var tsv_preview: PanelContainer = %TSV_Preview

@onready var hbox_error: HBoxContainer = %HBox_ERROR
@onready var label_error_msg: Label = %Label_ERROR_MSG

@onready var button_reset: Button = %Button_Reset
@onready var tsv_instructions: Label = %Label_Instructions
