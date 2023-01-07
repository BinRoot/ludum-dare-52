extends Node2D

onready var grid = $Grid
onready var camera = $Camera2D
onready var camera_tween = $CameraTween
var money : int = 100
onready var money_label : Label = $Camera2D/Control/Money

func _ready():
	grid.num_units = 1
	update_camera()

func update_camera():
	var new_zoom = Vector2.ONE * max(
		grid.size.x / get_viewport().size.x, 
		grid.size.y / get_viewport().size.y
	) * 1.2
	var new_position = grid.size / 2
	camera_tween.interpolate_property(camera, "position",
		camera.position, new_position, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera_tween.interpolate_property(camera, "zoom",
		camera.zoom, new_zoom, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera_tween.start()
	money_label.rect_position.x = -1 * money_label.rect_size.x / 2
	money_label.rect_position.y = new_position.y + 5
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
	money -= 200

func _process(delta):
	money_label.text = "${0}".format([money])


func _on_Grid_on_harvest(value):
	money += value

func _on_Grid_on_feed():
	money -= 10


func _on_Grid_on_purchased(value):
	money -= value
