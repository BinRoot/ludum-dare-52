extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
var health : int = 100

signal on_harvest
signal on_feed
signal on_purchased

enum State {
	OCCUPIED,
	VACANT
}

onready var prison_cell = $PrisonCell
onready var prisoner = $Prisoner
onready var progress_bar = $Control/ProgressBar
onready var feed_button = $Control/FeedButton
onready var harvest_button = $Control/HarvestButton
onready var buy_button = $Control/BuyButton
var rng = RandomNumberGenerator.new()
var current_state = State.OCCUPIED
var cell_purchase_price : int = 20


func _ready():
	reset()

func harvest():
	emit_signal("on_harvest", health)
	health = 0
	current_state = State.VACANT
	
func feed():
	emit_signal("on_feed")
	health = min(100, health + 20)
	

func _process(delta):
	progress_bar.value = health
	progress_bar.visible = current_state == State.OCCUPIED
	prisoner.visible = current_state == State.OCCUPIED
	feed_button.visible = current_state == State.OCCUPIED
	harvest_button.visible = current_state == State.OCCUPIED
	buy_button.visible = current_state == State.VACANT
	buy_button.text = "Buy (${0})".format([cell_purchase_price])
	prisoner.position = prison_cell.size / 2 - prisoner.size / 2

func set_size(new_size):
	push_warning("cannot update GridUnit size")
	
func get_size():
	return prison_cell.size


func _on_HungerTimer_timeout():
	health = max(health - 5, 0)

func _on_FeedButton_pressed():
	feed()

func _on_HarvestButton_pressed():
	harvest()


func _on_RespawnTimer_timeout():
	reset()
	
func reset():
	health = 100
	current_state = State.OCCUPIED
	rng.randomize()
	prisoner.modulate = Color(
		rng.randf(), 
		rng.randf(), 
		rng.randf(),
		1.0
	)


func _on_BuyButton_pressed():
	# TODO: check purchase price is possible first
	emit_signal("on_purchased", cell_purchase_price)
	reset()
