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
var num_times_horn_played = 0
var num_bells = 2

func _ready():
	grid.num_units = 1
	update_camera(true)

func pause():
	day_count_timer.stop()

func init():
	Globals.time_left = Globals.init_time_left
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
	var new_position = grid.size / 2
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
	time_left_label.rect_position = Vector2(
		-1 * time_left_label.rect_size.x / 2,
		-new_position.y - 20
	)
	time_left_label.get("custom_fonts/font").size = new_zoom.x * 35
	money_label.rect_position = Vector2(
		-1 * money_label.rect_size.x / 2,
		new_position.y + 5
	)
	money_label.get("custom_fonts/font").size = new_zoom.x * 35
	

func _input(event):
#	if event.is_action_pressed("ui_up"):
#		buy_unit()
#	if event.is_action_pressed("ui_down"):
#		grid.num_units -= 1
#		update_camera()
	if event.is_action_pressed("ui_cancel"):
		Globals.time_left = 2

func buy_unit():
	if Globals.money >= Globals.cost_grid_unit:
		grid.increment_num_units()
		update_camera()
		Globals.money -= Globals.cost_grid_unit

func _process(delta):
	money_label.text = "${0}".format([Globals.money])
	time_left_label.text = "{0}".format([max(0, Globals.time_left)])
	
	var num_potential_hotdogs = int(Globals.money / Globals.cost_feed)
	var hp_potential_heal = num_potential_hotdogs * Globals.feed_heal
	
	var is_found = false
	for unit in get_tree().get_nodes_in_group("unit"):
		if hp_potential_heal >= Globals.min_health_for_harvest - unit.health:
			is_found = true
			break
	if not is_found:
		pass #time_left = 2

func _on_Grid_on_harvest(value):
	Globals.money += value

func _on_Grid_on_feed():
	Globals.money -= Globals.cost_feed


func _on_Grid_on_purchased(value):
	Globals.money -= value


func _on_DayCountDown_timeout():
	Globals.time_left -= 1
	if Globals.time_left <= 0 and not day_end_audio.playing and num_times_horn_played < num_bells:
		day_end_audio.play()
		num_times_horn_played += 1
	
	if Globals.time_left <= -10 and visible == true:
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
