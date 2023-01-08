extends Node2D

signal on_exit

onready var camera : Camera2D = $Camera2D
onready var money_label : Label = $Control/MoneyLabel
onready var event_log_holder : VBoxContainer = $Control/ScrollContainer/MarginContainer/EventLogHolder
var dynamic_font = preload("res://Resources/UIFont2_Small.tres")

func _ready():
	reset()
	
func reset():
	for child in event_log_holder.get_children():
		event_log_holder.remove_child(child)
	for event in Globals.day_event_log:
		if event["type"] == "new_unit":
			var l = Label.new()
			l.text = "{0} joined".format([event["name"]])
			l.add_font_override("font", dynamic_font)
			event_log_holder.add_child(l)
			l.margin_left = 10

func _process(delta):
	money_label.text = "${0}".format([Globals.money])

func _on_Button_pressed():
	emit_signal("on_exit")
