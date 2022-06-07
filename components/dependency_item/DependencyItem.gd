extends Control

signal delete_pressed(dependency)

export var dependency_name: String

func _ready():
	$Name.text = dependency_name

func _on_DeleteButton_pressed():
	emit_signal("delete_pressed", self)
