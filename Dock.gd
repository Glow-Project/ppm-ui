@tool
extends Control

var dependency_item_scene = preload("./components/dependency_item/DependencyItem.tscn")

var config_path = "res://ppm.json"
var config: Dictionary

func _ready():
	refresh()

func fetch_from_file():
	var file = FileAccess.open(config_path, FileAccess.READ)
	
	if not file.file_exists(config_path):
		return
	
	file.open(config_path, file.READ)
	var content = JSON.parse_string(file.get_as_text())
	file.close()
	return content

func write_to_file(content: Dictionary = config):
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	file.open(config_path, file.WRITE)
	file.store_string(JSON.stringify(content))
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
	%OptionButton.select(1 if content["plugin"] else 0)
	
	# ===[ Dependency list ]===
	var deps = %Dependencies
	clear_children(deps)
	
	for dep in content["dependencies"]:
		var dep_item = dependency_item_scene.instantiate()
		dep_item.dependency_name = dep["identifier"]
		dep_item.delete_pressed.connect(_on_DependencyItem_delete_pressed)
		deps.add_child(dep_item)


func _on_Timer_timeout():
	refresh()

func _on_DependencyItem_delete_pressed(dependency):
	var conf: ConfirmationDialog = %ConfirmationDialog
	var orig_txt = conf.dialog_text
	conf.dialog_text = orig_txt % dependency.dependency_name
	conf.popup_centered()
	
	conf.confirmed.connect(func():
		var _unused = OS.execute("ppm", ["uninstall", dependency.dependency_name])
		refresh()
	)
	conf.visibility_changed.connect(func(): 
		if not conf.visible:
			conf.dialog_text = orig_txt
	)

func _on_OptionButton_item_selected(index: int):
	config["plugin"] = index == 1
	write_to_file()
	update_ui()

func _on_Init_pressed():
	var _unused = OS.execute("ppm", ["init"])
	refresh()
