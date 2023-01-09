extends Node2D

signal on_exit

onready var camera : Camera2D = $Camera2D
onready var money_label : Label = $Control/MoneyLabel
onready var event_log_holder : VBoxContainer = $Control/ScrollContainer/MarginContainer/EventLogHolder
onready var family1 = $Control/FamilyMember
onready var family2 = $Control/FamilyMember2
onready var family3 = $Control/FamilyMember3
onready var click_sound = $ClickSound
var dynamic_font = preload("res://Resources/UIFont2_Small.tres")

func _ready():
	reset(false)
	
func reset(is_sick_mode = true):
	if is_sick_mode:
		family1.sick1()
		family2.sick1()
		family3.sick1()
	for child in event_log_holder.get_children():
		event_log_holder.remove_child(child)
	for event in Globals.day_event_log:
		var label_text = null
		if event["type"] == "new_unit":
			pass
			#label_text = "{0} joined".format([event["name"]])
		elif event["type"] == "poopy":
			label_text = "{0} slept in filth".format([event["name"]])
		if label_text != null:
			var l = Label.new()
			l.text = label_text
			l.add_font_override("font", dynamic_font)
			event_log_holder.add_child(l)
			l.margin_left = 10
	

func _process(delta):
	money_label.text = "${0}".format([Globals.money])

func _on_Button_pressed():
	click_sound.play()
	emit_signal("on_exit")


