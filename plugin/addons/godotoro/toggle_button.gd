tool
extends Panel

export (String) var icon = "Icon_4"
export (String) var module = "editShortModule"
var selected = false
var exited_color = Color("#202431")

signal toggle(button)

func _ready():
	var icon_texture : TextureRect = $CenterContainer/TextureRect
	icon_texture.texture = load("res://addons/godotoro/" + icon + ".png")


func toggle(on):
	if on: show()
	else: hide()


func _on_ToggleButton_mouse_entered() -> void:
	if !selected:
		var style = load("res://addons/godotoro/button_hover.tres")
		add_stylebox_override("panel", style)


func _on_ToggleButton_mouse_exited() -> void:
	if !selected:
		var style = load("res://addons/godotoro/button_normal.tres")
		add_stylebox_override("panel", style)


func _on_ToggleButton_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		selected = !selected
		
		if selected:
			var style = load("res://addons/godotoro/button_toggle.tres")
			add_stylebox_override("panel", style)
			var toggles = get_tree().get_nodes_in_group("toggle")
			for btn in toggles:
				if btn != self:
					var off_style = load("res://addons/godotoro/button_normal.tres")
					btn.selected = false
					btn.add_stylebox_override("panel",off_style)
			
			get_tree().call_group("edit_module", "toggle", false)
			get_tree().call_group(module, "toggle", true)
		else:
			var style = load("res://addons/godotoro/button_normal.tres")
			add_stylebox_override("panel", style)
			get_tree().call_group(module, "toggle", false)


func _on_ToggleButton_hide() -> void:
	selected = false
	var style = load("res://addons/godotoro/button_normal.tres")
	add_stylebox_override("panel", style)
