extends Control
class_name PuzzleSettings

@export var settings_container : VBoxContainer
var settings_by_id : Dictionary[String,PuzzleSetting] = {}

func _ready() -> void:
	hide()
	create_all_settings()

func create_all_settings() -> void:
	for setting in PuzzleFramework.settings:
		setting.create_nodes(settings_container)
		settings_by_id[setting.key] = setting
		setting.value_changed.connect(_on_value_changed)

func _on_value_changed(setting:PuzzleSetting) -> void:
	pass

func get_by_key(key:String) -> PuzzleSetting:
	if key in settings_by_id: return settings_by_id[key]
	return null
	
