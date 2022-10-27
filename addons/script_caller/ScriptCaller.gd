@tool
extends EditorPlugin

var dock
var script_picker: EditorScriptPicker
var resource_picker: EditorResourcePicker

func button_pressed():
	var script: GDScript = script_picker.edited_resource
	script.new().call("run_script", resource_picker.edited_resource)

func _enter_tree():
	dock = preload("res://addons/script_caller/dock.tscn").instantiate()
	var run_button: Button = dock.find_child("Button")
	run_button.button_down.connect(button_pressed)

	script_picker = EditorScriptPicker.new()
	var script: Control = dock.find_child("Script")
	script_picker.set_position(script.position)
	script_picker.set_size(script.get_size())

	resource_picker = EditorResourcePicker.new()
	var res: Control = dock.find_child("Resource")
	resource_picker.set_position(res.position)
	resource_picker.set_size(res.get_size())
	
	dock.add_child(resource_picker)
	dock.add_child(script_picker)
	dock.remove_child(res)
	dock.remove_child(script)
	add_control_to_dock(DOCK_SLOT_LEFT_BL, dock)


func _exit_tree():
	remove_control_from_docks(dock)
