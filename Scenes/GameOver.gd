extends Node2D

export(String, "day1", "family") var reason
onready var descripiton : Label = $Description
onready var camera : Camera2D = $Camera2D
onready var dayx_label : Label = $DayX

func _ready():
	pass # Replace with function body.


func _process(delta):
	if reason == "day1":
		descripiton.text = "With no money left for resources, your family eventually starved."
	elif reason == "family":
		descripiton.text = "Your family is dead. You have no reason to go on."
	
	dayx_label.text = "You made it to day {0}".format([Globals.day_count])

func _on_Restart_pressed():
	get_tree().reload_current_scene()
	Globals.time_left = Globals.init_time_left
	Globals.money = Globals.init_money
	Globals.day_count = 1
	Globals.day_event_log = []
