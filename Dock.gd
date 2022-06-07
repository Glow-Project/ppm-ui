tool
extends Control

var dependency_item_scene = preload("res://addons/ppm-ui/components/dependency_item/DependencyItem.tscn")

var config_path = "res://ppm.json"
var file_content: Dictionary

func _ready():
	refresh()

func fetch_from_file():
	var file = File.new()

	if not file.file_exists(config_path):
		return

	file.open(config_path, file.READ)
	var content = parse_json(file.get_as_text())
	file.close()
	return content

func refresh():
	file_content = fetch_from_file()
	if file_content != null:
		update_ui()

func clear_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)

func update_ui(content: Dictionary = file_content):
	var deps = $DependencyContainer/Dependencies
	clear_children(deps)

	for dep in content["dependencies"]:
		var dep_item = dependency_item_scene.instance()
		dep_item.dependency_name = dep
		dep_item.connect("delete_pressed", self, "_on_DependencyItem_delete_pressed")
		deps.add_child(dep_item)		

func _on_Timer_timeout():
	refresh()

func _on_DependencyItem_delete_pressed(dependency):
	print("HERE")
	OS.execute("ppm", ["uninstall", dependency.dependency_name])
	refresh()
