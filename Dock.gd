tool
extends Control

var dependency_item_scene = preload("res://addons/ppm-ui/components/dependency_item/DependencyItem.tscn")

var config_path = "res://ppm.json"
var config: Dictionary

var plugin_type_container: Control
var dependency_container: Control
var plugin_type_dropdown: OptionButton

func _ready():
	plugin_type_container = $VBoxContainer/PluginTypeContainer
	dependency_container = $VBoxContainer/DependencyContainer
	plugin_type_dropdown = plugin_type_container.get_node("OptionButton")

	if not len(plugin_type_dropdown.items):
		plugin_type_dropdown.add_item("Game")
		plugin_type_dropdown.add_item("Plugin")

	refresh()

func fetch_from_file():
	var file = File.new()

	if not file.file_exists(config_path):
		return

	file.open(config_path, file.READ)
	var content = parse_json(file.get_as_text())
	file.close()
	return content

func write_to_file(content: Dictionary = config):
	var file = File.new()
	file.open(config_path, file.WRITE)
	file.store_string(to_json(content))
	file.close()

func refresh():
	var fetched_content = fetch_from_file()
	if fetched_content != null:
		config = fetched_content
		$VBoxContainer.show()
		$InitContainer.hide()
		update_ui()
	else:
		$InitContainer.show()
		$VBoxContainer.hide()

func clear_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)

func update_ui(content: Dictionary = config):
	# ===[ Plugin type ]===
	plugin_type_dropdown.select(1 if content["plugin"] else 0)

	# ===[ Dependency list ]===
	var deps = dependency_container.get_node("Dependencies")
	clear_children(deps)

	for dep in content["dependencies"]:
		var dep_item = dependency_item_scene.instance()
		dep_item.dependency_name = dep
		dep_item.connect("delete_pressed", self, "_on_DependencyItem_delete_pressed")
		deps.add_child(dep_item)		


func _on_Timer_timeout():
	refresh()

func _on_DependencyItem_delete_pressed(dependency):
	OS.execute("ppm", ["uninstall", dependency.dependency_name])
	refresh()

func _on_OptionButton_item_selected(index: int):
	config["plugin"] = index == 1
	write_to_file()
	update_ui()

func _on_Init_pressed():
	OS.execute("ppm", ["init"])
	refresh()
