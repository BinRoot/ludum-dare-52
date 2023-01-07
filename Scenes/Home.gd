extends Node2D

signal on_exit

onready var camera : Camera2D = $Camera2D

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_pressed():
	emit_signal("on_exit")
