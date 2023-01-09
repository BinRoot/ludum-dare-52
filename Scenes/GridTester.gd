extends Node2D

signal on_timeout

onready var grid = $Grid
onready var camera = $Camera2D
onready var camera_tween = $CameraTween
onready var money_label : Label = $Camera2D/Control/Money
onready var time_left_label : Label = $Camera2D/Control/TimeLeft
onready var day_count_timer : Timer = $DayCountDown
onready var day_end_audio : AudioStreamPlayer = $DayEndAudio
onready var lights_out_tween : Tween = $LightsOutTween
onready var lights_out_audio : AudioStreamPlayer = $LightsOutAudio
onready var money_tween : Tween = $MoneyTween
onready var day_x_label : Label = $Camera2D/Control/DayX
onready var day_x_tween : Tween = $DayXTween
var num_times_horn_played = 0
var num_bells = 2
var is_already_quitting = false
var is_feed_ever_pressed = false

func _ready():
	grid.num_units = 1
	update_camera(true)

func pause():
	day_count_timer.stop()

func init():
	Globals.time_left = Globals.init_time_left
	day_x_label.visible = true
	day_x_label.rect_pivot_offset = day_x_label.rect_size / 2
	day_x_label.text = "You made it to day {0}".format([Globals.day_count])
	day_x_tween.interpolate_property(
		day_x_label,
		"rect_scale",
		day_x_label.rect_scale * 1.2,
		day_x_label.rect_scale,
		5,
		Tween.TRANS_EXPO,
		Tween.EASE_IN_OUT
	)
	day_x_tween.start()
	is_already_quitting = false
	grid.resume_audio()
	day_count_timer.start()
	lights_out_tween.interpolate_property(
		self,
		"modulate",
		Color.black,
		Color.white,
		0.7,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)
	lights_out_tween.start()
	num_times_horn_played = 0

func update_camera(is_instant = false):
	var new_zoom = Vector2.ONE * max(
		grid.size.x / get_viewport().size.x, 
		grid.size.y / get_viewport().size.y
	) * 1.2
	var new_position = grid.size / 2 + Vector2.DOWN * 15
	if is_instant:
		camera.position = new_position
		camera.zoom = new_zoom
	else:
		camera_tween.interpolate_property(camera, "position",
			camera.position, new_position, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		camera_tween.interpolate_property(camera, "zoom",
			camera.zoom, new_zoom, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		camera_tween.start()
		
	var y_pos = new_position.y + 50 * new_zoom.y
	var font_size = new_zoom.x * 100
	if Globals.num_units == 1:
		y_pos = new_position.y - 80
	elif Globals.num_units == 2:
		y_pos = new_position.y - 15
	elif Globals.num_units == 3:
		y_pos = new_position.y + 30
	elif Globals.num_units >= 4 and Globals.num_units <= 6:
		y_pos = new_position.y - 15
		font_size = new_zoom.x * 50
	elif Globals.num_units >= 7 and Globals.num_units <= 9:
		y_pos = new_position.y - 15
		font_size = new_zoom.x * 50
	
	time_left_label.rect_position = Vector2(
		-1 * money_label.rect_size.x / 2 + 200,
		y_pos
	)
	time_left_label.get("custom_fonts/font").size = font_size
	money_label.rect_position = Vector2(
		-1 * money_label.rect_size.x / 2 - 200,
		y_pos
	)
	money_label.get("custom_fonts/font").size = font_size
	

func _input(event):
#	if event.is_action_pressed("ui_up"):
#		buy_unit()
#	if event.is_action_pressed("ui_down"):
#		grid.num_units -= 1
#		update_camera()
	if event.is_action_pressed("ui_cancel"):
		Globals.time_left = 2

func shake_money():
	money_label.rect_pivot_offset = money_label.rect_size / 2
	money_tween.interpolate_property(
		money_label,
		"rect_scale",
		Vector2.ONE * 2,
		Vector2.ONE * 1,
		0.5,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT
	)
	money_tween.start()

func buy_unit():
	if Globals.money >= Globals.cost_grid_unit:
		grid.increment_num_units()
		update_camera()
		Globals.money -= Globals.cost_grid_unit

func _process(delta):
	money_label.text = "${0}".format([Globals.money])
	time_left_label.text = "{0}".format([max(0, Globals.time_left)])
	
	var is_found = Globals.is_harvestable_found()
	if not is_found and not is_already_quitting:
		is_already_quitting = true
		Globals.time_left = 2

func _on_Grid_on_harvest(value):
	Globals.money += value
	shake_money()

func _on_Grid_on_feed():
	Globals.money -= Globals.cost_feed
	is_feed_ever_pressed = true


func _on_Grid_on_purchased(value):
	Globals.money -= value


func _on_DayCountDown_timeout():
	if is_feed_ever_pressed:
		Globals.time_left -= 1
		if Globals.time_left <= 0 and not day_end_audio.playing and num_times_horn_played < num_bells:
			day_end_audio.play()
			num_times_horn_played += 1
		
		if Globals.time_left <= -5 and visible == true:
			emit_signal("on_timeout")


func _on_Grid_on_grid_changed():
	update_camera()


func _on_DayEndAudio_finished():
	if modulate == Color.white and num_times_horn_played == num_bells:
		lights_out_audio.play()
		lights_out_tween.interpolate_property(
			self,
			"modulate",
			Color.white,
			Color.black,
			1,
			Tween.TRANS_EXPO,
			Tween.EASE_IN
		)
		lights_out_tween.start()


func _on_DayXTween_tween_all_completed():
	day_x_label.visible = false
