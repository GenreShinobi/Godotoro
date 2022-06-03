tool
extends Panel

enum Phase {
	IDLE,
	PAUSED,
	RUNNING,
	FOCUS,
	SHORT_BREAK,
	LONG_BREAK
}

export (String) var icon = "Icon_4"
export (Phase) var phase = Phase.FOCUS
var selected = false
var exited_color = Color("#202431")

signal toggle(button)
signal enter_idle
signal enter_paused
signal enter_running
signal enter_short_break
signal enter_focus
signal enter_long_break


func _ready():
	var icon_texture : TextureRect = $CenterContainer/TextureRect
	icon_texture.texture = load("res://addons/godotoro/" + icon + ".png")


func toggle(on):
	if on: show()
	else: hide()


func _on_Button_mouse_entered() -> void:
	var style = load("res://addons/godotoro/button_hover.tres")
	add_stylebox_override("panel", style)


func _on_Button_mouse_exited() -> void:
	var style = load("res://addons/godotoro/button_normal.tres")
	add_stylebox_override("panel", style)


func _on_Button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		emit_signal("enter_" + Phase.keys()[phase].to_lower())


func _on_Button_hide() -> void:
	var style = load("res://addons/godotoro/button_normal.tres")
	add_stylebox_override("panel", style)
