extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
var health : int

signal on_harvest
signal on_feed
signal on_purchased

enum State {
	OCCUPIED,
	VACANT,
	DEAD
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
onready var harvest_timer = $HarvestTimer
var rng = RandomNumberGenerator.new()
var current_state = State.OCCUPIED

var num_poop : int = 0
var names = ["Stevo", "Buzzly", "Ferret", "Pinecone", "Biscult", "Quaxter", 
	"Gulb", "Eithing", "Crumptop", "Joera", "Vixta", "Yindig", "Ripertha",
	"Bigs", "Smol", "Rink", "Oppa", "Rinta", "Lint"]
var unit_name : String

func _ready():
	reset()

func harvest():
	prisoner.harvest()
	harvest_timer.start()
	
func feed():
	if Globals.money >= Globals.cost_feed:
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
	poop1.visible = current_state in [State.OCCUPIED, State.DEAD]
	poop2.visible = current_state in [State.OCCUPIED, State.DEAD]
	poop3.visible = current_state in [State.OCCUPIED, State.DEAD]
	clean_button.visible = current_state in [State.OCCUPIED, State.DEAD]
	harvest_button.visible = current_state == State.OCCUPIED and health > 90
	buy_button.visible = current_state == State.VACANT
	buy_button.text = "Buy (${0})".format([Globals.cost_replenish])
	prisoner.position = prison_cell.size / 2 - prisoner.size / 2
	if current_state in [State.OCCUPIED, State.DEAD]:
		update_poop()

func set_size(_new_size):
	push_warning("cannot update GridUnit size")
	
func get_size():
	return prison_cell.size


func _on_HungerTimer_timeout():
	health = max(health - 5 * num_poop * num_poop, 0)
	if health <= 0 and current_state == State.OCCUPIED:
		current_state = State.DEAD

func _on_FeedButton_pressed():
	feed()

func _on_HarvestButton_pressed():
	harvest()


func _on_RespawnTimer_timeout():
	reset()
	
func reset():
	health = 20
	num_poop = 0
	prisoner.reset()
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
	if Globals.money >= Globals.cost_replenish:
		emit_signal("on_purchased", Globals.cost_replenish)
		reset()


func _on_PoopTimer_timeout():
	if current_state == State.OCCUPIED:
		num_poop = min(3, num_poop + 1)


func _on_CleanButton_pressed():
	num_poop = 0
	if current_state == State.DEAD:
		current_state = State.VACANT


func _on_HarvestTimer_timeout():
	current_state = State.VACANT
	emit_signal("on_harvest", Globals.harvest_earning)
	health = 0
