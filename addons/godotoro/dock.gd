tool
extends Control


enum State {
	PAUSED,
	RUNNING
}

enum Phase {
	IDLE,
	PAUSED,
	RUNNING,
	FOCUS,
	SHORT_BREAK,
	LONG_BREAK
}

var current_phase 				= Phase.FOCUS
var current_state				= State.PAUSED
var short_timer 				:int	= 300
var focus_timer					:int    = 1500
var long_timer 					:int	= 1800
var ticks 						:int	= 1
var max_sessions 				:int	= 4
var number_of_focus_sessions 	:int	= 0
var number_of_steps				:int    = 0

# Preloads
const PIP = preload("res://addons/godotoro/pip.tscn")
const MINI_PIP = preload("res://addons/godotoro/pip-mini.tscn")

# UI Elements
onready var long_time_slider = $VBoxContainer/MarginContainer/VBoxContainer3/editLongModule/longSlider
onready var short_time_slider = $VBoxContainer/MarginContainer/VBoxContainer3/editShortModule/shortSlider
onready var sessions_slider = $VBoxContainer/MarginContainer/VBoxContainer3/editSessionsModule/sessionSlider
onready var focus_slider_label = $VBoxContainer/MarginContainer/VBoxContainer3/editLongModule/HBoxContainer/currentFocusLengthLabel
onready var short_slider_label = $VBoxContainer/MarginContainer/VBoxContainer3/editShortModule/HBoxContainer/currentShortBreakLengthLabel
onready var session_slider_label = $VBoxContainer/MarginContainer/VBoxContainer3/editSessionsModule/HBoxContainer/sessionsLabel
onready var progress_bar = $VBoxContainer/Progress/MarginContainer2/ProgressBar
onready var timer_label = $VBoxContainer/Progress/MarginContainer3/HBoxContainer/timerLabel
onready var current_icon = $VBoxContainer/Progress/MarginContainer3/HBoxContainer/currentIcon

# Buttons
onready var shortBreak_btn = $VBoxContainer/CenterContainer/GridContainer/shortBreak
onready var longBreak_btn = $VBoxContainer/CenterContainer/GridContainer/longBreak
onready var focus_btn = $VBoxContainer/CenterContainer/GridContainer/focus
onready var unpause_btn = $VBoxContainer/CenterContainer/GridContainer/unpause
onready var pause_btn = $VBoxContainer/CenterContainer/GridContainer/pause
onready var stop_btn = $VBoxContainer/CenterContainer/GridContainer/stop

# Signals
signal stop_clock
signal start_clock

func _ready():
	long_time_slider.value = long_timer / 60 
	short_time_slider.value = short_timer / 60
	sessions_slider.value = max_sessions
	progress_bar.max_value = long_timer
	progress_bar.value = 0
	_set_clock_to_idle()
	_layout_pips()
	
	# Set Slider Labels
	focus_slider_label.text = String(long_time_slider.value) + " min"
	short_slider_label.text = String(short_time_slider.value) + " min"
	session_slider_label.text = String(max_sessions)
	
	# Connect Signals
	stop_btn.connect("enter_idle", self, "_set_clock_to_idle")
	pause_btn.connect("enter_paused", self, "_set_clock_to_paused")
	unpause_btn.connect("enter_running", self, "_set_clock_to_running")
	shortBreak_btn.connect("enter_short_break", self, "_set_clock_to_short_break")
	focus_btn.connect("enter_focus", self, "_set_clock_to_focus")
	longBreak_btn.connect("enter_long_break", self, "_set_clock_to_long_break")


func _initialize():
	long_timer = long_time_slider.value
	short_timer = short_time_slider.value
	max_sessions = sessions_slider.value


func _layout_pips():
	var pipProgress = $VBoxContainer/Progress/MarginContainer/pipProgress
	for pip in pipProgress.get_children():
		pip.queue_free()
	for i in sessions_slider.value:
		var pip_scene = PIP.instance()
		pipProgress.add_child(pip_scene)
		if i != sessions_slider.value - 1 and sessions_slider.value != 1:
			var pip_mini_scene = MINI_PIP.instance()
			pipProgress.add_child(pip_mini_scene)
	max_sessions = sessions_slider.value


func _update_pips():
	var pipProgress = $VBoxContainer/Progress/MarginContainer/pipProgress
	var count = 0
	var style_done = load("res://addons/godotoro/pip_done.tres")
	var style_progress = load("res://addons/godotoro/pip_progress.tres")
	var style_normal = load("res://addons/godotoro/pip_normal.tres")
	for pip in pipProgress.get_children():
		if count < number_of_steps:
			pip.add_stylebox_override("panel", style_done)
		elif count == number_of_steps:
			pip.add_stylebox_override("panel", style_progress)
		elif count > number_of_steps:
			pip.add_stylebox_override("panel", style_normal)
		count += 1


func _set_clock_to_idle():
	emit_signal("stop_clock")
	current_phase = Phase.IDLE
	number_of_focus_sessions = 0
	number_of_steps = 0
	_update_pips()
	get_tree().call_group("running", "toggle", false)
	get_tree().call_group("control", "toggle", false)
	get_tree().call_group("idle", "toggle", true)
	get_tree().call_group("edit_module", "toggle", false)


func _set_clock_to_focus(paused :bool = false):
	current_icon.texture = load_icon("Icon_5")
	if current_phase == Phase.LONG_BREAK:
		number_of_steps = 0
	current_phase = Phase.FOCUS
	ticks = focus_timer + 1
	progress_bar.max_value = focus_timer + 1
	progress_bar.value = 0
	if number_of_focus_sessions < max_sessions - 1:
		get_tree().call_group("idle", "toggle", false)
		get_tree().call_group("break", "toggle", false)
		get_tree().call_group("final_focus", "toggle", false)
		get_tree().call_group("focus", "toggle", true)
	else:
		get_tree().call_group("idle", "toggle", false)
		get_tree().call_group("break", "toggle", false)
		get_tree().call_group("focus", "toggle", false)
		get_tree().call_group("final_focus", "toggle", true)
	number_of_focus_sessions += 1
	if paused:
		_set_clock_to_paused()
		ticks -= 1
	else:
		_set_clock_to_running()
	_update_pips()
	number_of_steps += 1


func _set_clock_to_short_break(paused :bool = false):
	current_icon.texture = load_icon("Icon_4")
	current_phase = Phase.SHORT_BREAK
	ticks = short_time_slider.value * 60 + 1
	progress_bar.max_value = short_time_slider.value * 60
	progress_bar.value = 0
	get_tree().call_group("idle", "toggle", false)
	get_tree().call_group("focus", "toggle", false)
	get_tree().call_group("break", "toggle", true)
	if paused:
		_set_clock_to_paused()
		ticks -= 1
	else:
		_set_clock_to_running()
	_update_pips()
	number_of_steps += 1
	
	
func _set_clock_to_long_break(paused :bool = false):
	current_icon.texture = load_icon("Icon_6")
	current_phase = Phase.LONG_BREAK
	number_of_focus_sessions = 0
	ticks = long_time_slider.value * 60 + 1
	progress_bar.max_value = long_time_slider.value  * 60
	progress_bar.value = 0
	get_tree().call_group("idle", "toggle", false)
	get_tree().call_group("focus", "toggle", false)
	get_tree().call_group("final_focus", "toggle", false)
	get_tree().call_group("break", "toggle", true)
	if paused:
		ticks -= 1
		_set_clock_to_paused()
	else:
		_set_clock_to_running()
	_update_pips()
	number_of_steps += 1


func _set_clock_to_running():
	current_state = State.RUNNING
	get_tree().call_group("paused", "toggle", false)
	get_tree().call_group("running", "toggle", true)
	emit_signal("start_clock")


func _set_clock_to_paused():
	current_state = State.PAUSED
	get_tree().call_group("running", "toggle", false)
	get_tree().call_group("paused", "toggle", true)
	emit_signal("stop_clock")


func _set_clock_to_next_phase():
	if current_phase == Phase.FOCUS and number_of_focus_sessions < max_sessions:
		_set_clock_to_short_break(true)
	elif current_phase == Phase.FOCUS and number_of_focus_sessions == max_sessions:
		_set_clock_to_long_break(true)
	elif current_phase == Phase.SHORT_BREAK or current_phase == Phase.LONG_BREAK:
		_set_clock_to_focus(true)


func _on_ticking():
#	print(String(Phase.keys()[current_phase]))
	if current_state == State.RUNNING:
		ticks -= 1
		if ticks <= 0:
			_set_clock_to_next_phase()
			progress_bar.value = 0
		else:
			progress_bar.value += 1

	var time = ticks
	var seconds = time % 60
	time /= 60
	var minutes = time % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]


func _on_sessionSlider_value_changed(value: float) -> void:
	session_slider_label.text = String(value)
	_layout_pips()


func _on_longSlider_value_changed(value: float) -> void:
	focus_slider_label.text = String(value) + " min"


func _on_shortSlider_value_changed(value: float) -> void:
	short_slider_label.text = String(value) + " min"


func _on_startButton_pressed() -> void:
	_set_clock_to_focus()


func load_icon(icon_ref):
	return load("res://addons/godotoro/"+icon_ref+".png")
