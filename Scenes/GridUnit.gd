extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
var health : int

signal on_harvest
signal on_harvest_attempted
signal on_feed
signal on_purchased

enum State {
	OCCUPIED,
	VACANT,
	HARVESTING,
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
onready var name_label = $Control/NameLabel
onready var clean_button = $Control/CleanButton
onready var harvest_timer = $HarvestTimer
onready var harvested_label = $Control/HarvestedLabel
onready var harvested_label_tween = $HarvestedLabelTween
onready var apple_sprite : Sprite = $AppleSprite
onready var sickle_sprite : Sprite = $SickleSprite
onready var broom_sprite : Sprite = $BroomSprite
onready var hotdog_sprite : AnimatedSprite = $HotdogSprite
onready var harvest_sfx : AudioStreamPlayer = $HarvestSfx
onready var wrong_sfx : AudioStreamPlayer = $WrongSfx
onready var click_sfx : AudioStreamPlayer = $ClickSfx
onready var unlock_sfx : AudioStreamPlayer = $UnlockSfx
onready var sweep_sfx : AudioStreamPlayer = $SweepSfx
onready var harvest_pop_sprite : AnimatedSprite = $HarvestPopSprite
onready var lock_sprite : AnimatedSprite = $LockSprite
onready var poop_timer : Timer = $PoopTimer
onready var hunger_timer : Timer = $HungerTimer

var rng = RandomNumberGenerator.new()
var current_state = State.OCCUPIED
var harvest_earning = Globals.harvest_earning
var is_new = false
var cost_replenish = Globals.cost_replenish
var is_locked : bool = false
var is_hotdog_eating : bool = false
var is_harvest_ever_clicked : bool = false

var num_poop : int = 0
var names = ["Stevo", "Buzzly", "Ferret", "Pinecone", "Biscult", "Quaxter", 
	"Gulb", "Eithing", "Crumptop", "Joera", "Vixta", "Yindig", "Ripertha",
	"Bigs", "Smol", "Rink", "Oppa", "Rinta", "Lint", "Henry", "Nishant"]
var unit_name : String

func _ready():
	reset()

func harvest():
	harvest_sfx.play()
	is_harvest_ever_clicked = true
	emit_signal("on_harvest_attempted", harvest_earning)
	prisoner.harvest()
	current_state = State.HARVESTING
	harvest_timer.start()
	
func feed():
	if Globals.money >= Globals.cost_feed:
		emit_signal("on_feed")
		hotdog_sprite.frame = 11
		hotdog_sprite.play()
		is_hotdog_eating = true
	
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
	name_label.visible = current_state == State.OCCUPIED
	prisoner.visible = current_state in [State.OCCUPIED, State.HARVESTING, State.DEAD]
	feed_button.visible = current_state == State.OCCUPIED
	poop1.visible = current_state in [State.OCCUPIED, State.DEAD, State.HARVESTING]
	poop2.visible = current_state in [State.OCCUPIED, State.DEAD, State.HARVESTING]
	poop3.visible = current_state in [State.OCCUPIED, State.DEAD, State.HARVESTING]
	if not (current_state in [State.HARVESTING]):
		harvested_label.visible = false
	clean_button.visible = current_state in [State.OCCUPIED, State.DEAD]
	harvest_button.visible = current_state == State.OCCUPIED and health >= Globals.min_health_for_harvest
	buy_button.visible = current_state == State.VACANT
	buy_button.text = "${0}".format([cost_replenish])
	buy_button.rect_position = get_size() / 2 - buy_button.rect_size / 2 + Vector2.DOWN * 40
	lock_sprite.position = get_size() / 2 + Vector2.UP * 40
	harvest_pop_sprite.position = get_size() / 2
	prisoner.position = prison_cell.size / 2 - prisoner.size / 2 + Vector2.LEFT * 19 + Vector2.UP * 15
	if current_state in [State.OCCUPIED, State.DEAD, State.HARVESTING]:
		update_poop()
	apple_sprite.visible = feed_button.visible
	sickle_sprite.visible = harvest_button.visible
	broom_sprite.visible = clean_button.visible
	lock_sprite.visible = buy_button.visible and is_locked

func set_size(_new_size):
	push_warning("cannot update GridUnit size")
	
func get_size():
	return prison_cell.size


func _on_HungerTimer_timeout():
	health = max(health - 1, 0)
#	if num_poop == 0:
#		health = max(health - 1, 0)
#	else:
#		health = max(health - 5 * num_poop * num_poop, 0)
		
		
	if health <= 0 and current_state == State.OCCUPIED:
		current_state = State.DEAD
		prisoner.dead()

func _on_FeedButton_pressed():
	if num_poop == 0 and not is_hotdog_eating:
		click_sfx.play()
		feed()
	else:
		wrong_sfx.play()
		for poop in get_tree().get_nodes_in_group("poop"):
			poop.shake()

func _on_HarvestButton_pressed():
	if num_poop == 0:
		click_sfx.play()
		harvest()
	else:
		wrong_sfx.play()
		for poop in get_tree().get_nodes_in_group("poop"):
			poop.shake()


func _on_RespawnTimer_timeout():
	reset()
	
func reset():
	if not is_harvest_ever_clicked:
		health = 65
	else:
		health = rng.randi_range(Globals.init_health - 30, Globals.init_health)
	num_poop = 0
	prisoner.reset()
	
	if is_locked:
		cost_replenish = Globals.cost_grid_unit * Globals.num_units
	else:
		cost_replenish = Globals.cost_replenish
	if is_locked:
		current_state = State.VACANT
	else:
		current_state = State.OCCUPIED
	if is_new:
		pass
	rng.randomize()
	var unit_names = []
	for unit in get_tree().get_nodes_in_group("unit"):
		unit_names.append(unit.unit_name)
	for _i in range(10):
		unit_name = names[rng.randi_range(0, len(names) - 1)]
		if not (unit_name in unit_names):
			break
	name_label.text = unit_name
	prisoner.set_color(Color(
		rng.randf(), 
		rng.randf(), 
		rng.randf(),
		1.0
	))
	if not is_locked:
		Globals.eventLogNewUnit(unit_name)


func _on_BuyButton_pressed():
	if Globals.money >= cost_replenish:
		if is_locked:
			lock_sprite.play("unlock")
			unlock_sfx.play()
			yield(lock_sprite, "animation_finished")
		emit_signal("on_purchased", cost_replenish)
		is_locked = false
		reset()


func _on_PoopTimer_timeout():
	if current_state == State.OCCUPIED and not is_hotdog_eating and Globals.time_left > 0:
		num_poop = min(3, num_poop + 1)
	update_poop_timer()
	poop_timer.wait_time = rng.randi_range(3, 9)
	poop_timer.start()

func update_poop_timer():
	if num_poop == 0:
		hunger_timer.wait_time = 4
	elif num_poop == 1:
		hunger_timer.wait_time = 2
	elif num_poop == 2:
		hunger_timer.wait_time = 1
	elif num_poop == 3:
		hunger_timer.wait_time = 0.5

func _on_CleanButton_pressed():
	if num_poop > 0:
		click_sfx.play()
		sweep_sfx.play()
	num_poop = 0
	update_poop_timer()
	if current_state == State.DEAD:
		current_state = State.VACANT


func _on_HarvestTimer_timeout():
	harvest_pop_sprite.play()
	harvested_label.text = "${0}".format([harvest_earning])
	harvested_label.visible = true
	var starting_pos = get_size() / 2 - harvested_label.rect_size / 2
	var starting_scale = Vector2.ONE
	harvested_label.rect_position = starting_pos
	harvested_label.rect_scale = starting_scale
	harvested_label.rect_pivot_offset = harvested_label.rect_size / 2
	harvested_label_tween.interpolate_property(
		harvested_label, 
		"rect_position",
		starting_pos,
		starting_pos + Vector2.UP * 100,
		0.8,
		Tween.TRANS_CUBIC,
		Tween.EASE_OUT
	)
	harvested_label_tween.interpolate_property(
		harvested_label, 
		"rect_scale",
		starting_scale,
		starting_scale * 1.2,
		0.3,
		Tween.TRANS_QUINT,
		Tween.EASE_IN
	)
	harvested_label_tween.start()
	yield(harvested_label_tween, "tween_completed")
	yield(harvested_label_tween, "tween_completed")
	
	harvested_label_tween.interpolate_property(
		harvested_label, 
		"rect_position",
		harvested_label.rect_position,
		harvested_label.rect_position + Vector2.DOWN * 50,
		2,
		Tween.TRANS_EXPO,
		Tween.EASE_IN
	)
	harvested_label_tween.interpolate_property(
		harvested_label, 
		"rect_rotation",
		0,
		-5,
		2,
		Tween.TRANS_BACK,
		Tween.EASE_OUT
	)
	harvested_label_tween.start()
	yield(harvested_label_tween, "tween_completed")
	yield(harvested_label_tween, "tween_completed")
	
	harvested_label_tween.interpolate_property(
		harvested_label, 
		"rect_rotation",
		-5,
		0,
		2,
		Tween.TRANS_BOUNCE,
		Tween.EASE_OUT
	)
	harvested_label_tween.start()
	yield(harvested_label_tween, "tween_completed")
	
	current_state = State.VACANT
	emit_signal("on_harvest", harvest_earning)
	health = 0


func _on_HotdogSprite_animation_finished():
	prisoner.after_hotdog_eaten()
	is_hotdog_eating = false
	health = min(100, health + Globals.feed_heal)
