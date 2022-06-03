tool
extends EditorPlugin

var shake = 0.0
var shake_intensity = 0.0
var timer = 0.0

const Dock = preload("res://addons/godotoro/dock.tscn")
var dock
var tick = false

signal ticking


func _enter_tree():
	# Add the main panel
	dock = Dock.instance()
	connect("ticking", dock, "_on_ticking")
	dock.connect("stop_clock", self, "_on_stop_ticking")
	dock.connect("start_clock", self, "_on_start_ticking")
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)


func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.free()


func _process(delta):
	if tick:
		timer += delta
		if timer > 1:
			timer = 0
			emit_signal("ticking")


func _on_stop_ticking():
	tick = false


func _on_start_ticking():
	tick = true
