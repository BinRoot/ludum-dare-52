extends Control

onready var progress_bar : ProgressBar = $ProgressBar
var health : int = 50

func _ready():
	pass 


func _process(delta):
	progress_bar.value = health


func _on_Button_pressed():
	if Globals.money >= Globals.cost_feed:
		Globals.money -= Globals.cost_feed
		health = min(100, health + Globals.feed_heal)
