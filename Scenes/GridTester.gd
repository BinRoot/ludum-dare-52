extends Node2D

signal on_timeout

onready var grid = $Grid
onready var camera = $Camera2D
onready var camera_tween = $CameraTween
onready var money_label : Label = $Camera2D/Control/Money
onready var time_left_label : Label = $Camera2D/Control/TimeLeft

var time_left = 60

func _ready():
	grid.num_units = 1
	update_camera(true)

func init():
	time_left = 60

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
		-new_position.y
	)
	time_left_label.get("custom_fonts/font").size = new_zoom.x * 30
	money_label.rect_position = Vector2(
		-1 * money_label.rect_size.x / 2,
		new_position.y + 5
	)
	money_label.get("custom_fonts/font").size = new_zoom.x * 30
	

func _input(event):
	if event.is_action_pressed("ui_up"):
		buy_unit()
	if event.is_action_pressed("ui_down"):
		grid.num_units -= 1
		update_camera()

func buy_unit():
	grid.increment_num_units()
	update_camera()
	Globals.money -= 200

func _process(delta):
	money_label.text = "${0}".format([Globals.money])
	time_left_label.text = "{0}".format([time_left])

func _on_Grid_on_harvest(value):
	Globals.money += value

func _on_Grid_on_feed():
	Globals.money -= 10


func _on_Grid_on_purchased(value):
	Globals.money -= value


func _on_DayCountDown_timeout():
	time_left -= 1
	if time_left <= 0:
		emit_signal("on_timeout")
