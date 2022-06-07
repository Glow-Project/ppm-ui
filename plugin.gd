tool
extends EditorPlugin

# the dock instance
var dock

func _enter_tree():
	# load the dock
	dock = preload("res://addons/ppm-ui/Dock.tscn").instance()

	# change the displayed dock name
	dock.name = "ppm"

	# add the control to the dock
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)


func _exit_tree():
	# remove the dock
	remove_control_from_docks(dock)
