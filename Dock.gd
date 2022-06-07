extends Control

var config_path = "res://ppm.json"
var file_content: Dictionary

func _ready():
	refresh()

func fetch_from_file():
	var file = File.new()

	if not file.file_exists(config_path):
		return

	file.open(config_path)
	var content = parse_json(file.get_as_text())
	file.close()
	return content

func refresh():
	file_content = fetch_from_file()
	update_ui()

func update_ui(content: Dictionary = file_content):
	pass

func _on_Timer_timeout():
	refresh()
