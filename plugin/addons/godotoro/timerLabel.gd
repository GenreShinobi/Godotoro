tool
extends Label


func toggle(on):
	if on and !is_visible(): show()
	elif !on: hide()
