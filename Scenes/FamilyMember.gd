extends Control

onready var progress_bar : ProgressBar = $ProgressBar
onready var sprite : AnimatedSprite = $AnimatedSprite
var health : int = 15

export(String, "boy", "girl", "wife") var character

func _ready():
	pass 


func _process(delta):
	progress_bar.value = health
	var animation_name = "{0}_idle".format([character])
	if health < 50:
		animation_name = "{0}_sick".format([character])
	sprite.play(animation_name)

func _on_Button_pressed():
	if Globals.money >= Globals.cost_feed:
		Globals.money -= Globals.cost_feed
		health = min(100, health + Globals.feed_heal)
