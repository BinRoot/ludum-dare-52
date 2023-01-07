extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
var health : int

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
onready var poop1 = $Poop
onready var poop2 = $Poop2
onready var poop3 = $Poop3
onready var name_label = $Control/ProgressBar/NameLabel
onready var clean_button = $Control/CleanButton
var rng = RandomNumberGenerator.new()
var current_state = State.OCCUPIED
var cell_purchase_price : int = 60
var num_poop : int = 0
var names = ["Stevo", "Buzzly", "Ferret", "Pinecone", "Biscult", "Quaxter", 
	"Gulb", "Eithing", "Crumptop", "Joera", "Vixta", "Yindig", "Ripertha",
	"Bigs", "Smol", "Rink", "Oppa", "Rinta"]
var unit_name : String

func _ready():
	reset()

func harvest():
	emit_signal("on_harvest", health)
	health = 0
	current_state = State.VACANT
	
func feed():
	emit_signal("on_feed")
	health = min(100, health + 20)
	
func update_poop():
	poop1.visible = false
	poop2.visible = false
	poop3.visible = false
	if num_poop >= 1:
		poop1.visible = true
	if num_poop >= 2:
		poop2.visible = true
	if num_poop >= 3:
		poop3.visible = true

func _process(delta):
	progress_bar.value = health
	progress_bar.visible = current_state == State.OCCUPIED
	prisoner.visible = current_state == State.OCCUPIED
	feed_button.visible = current_state == State.OCCUPIED
	poop1.visible = current_state == State.OCCUPIED
	poop2.visible = current_state == State.OCCUPIED
	poop3.visible = current_state == State.OCCUPIED
	clean_button.visible = current_state == State.OCCUPIED
	harvest_button.visible = current_state == State.OCCUPIED and health > 75
	buy_button.visible = current_state == State.VACANT
	buy_button.text = "Buy (${0})".format([cell_purchase_price])
	prisoner.position = prison_cell.size / 2 - prisoner.size / 2
	if current_state == State.OCCUPIED:
		update_poop()

func set_size(_new_size):
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
	health = 20
	num_poop = 0
	current_state = State.OCCUPIED
	rng.randomize()
	var unit_names = []
	for unit in get_tree().get_nodes_in_group("unit"):
		unit_names.append(unit.unit_name)
	for _i in range(10):
		unit_name = names[rng.randi_range(0, len(names) - 1)]
		if not (unit_name in unit_names):
			break
	name_label.text = unit_name
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


func _on_PoopTimer_timeout():
	num_poop = min(3, num_poop + 1)


func _on_CleanButton_pressed():
	num_poop = 0
