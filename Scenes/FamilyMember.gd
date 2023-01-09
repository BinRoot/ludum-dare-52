extends Control

onready var progress_bar : ProgressBar = $ProgressBar
onready var sprite : AnimatedSprite = $AnimatedSprite
onready var harvest_button : Button = $HarvestButton
onready var harvest_sprite : Sprite = $HarvestSprite
onready var feed_sprite : Sprite = $FeedSprite
onready var wrong_sound : AudioStreamPlayer = $WrongSound
onready var harvest_sound : AudioStreamPlayer = $HarvestSound
onready var click_sound : AudioStreamPlayer = $ClickSound
onready var feed_button : Button = $FeedButton
onready var head_stone : TextureRect = $HeadStone
var rng = RandomNumberGenerator.new()

var health : int = Globals.init_family_health

export(String, "boy", "girl", "wife") var character

func _ready():
	rng.randomize() 


func _process(delta):
	progress_bar.value = health
	var animation_name = "{0}_idle".format([character])
	if health < 50:
		animation_name = "{0}_sick".format([character])
	sprite.play(animation_name)
	
#	var is_harvestable = (Globals.day_count > 1) and (health > 0) and (Globals.money < 5 or health >= Globals.min_health_for_harvest)
	var is_harvestable = (Globals.day_count > 1) and (health > 0) and (Globals.money <= 5)
	harvest_button.visible = is_harvestable
	harvest_sprite.visible = is_harvestable
	sprite.visible = health > 0
	head_stone.visible = health <= 0


func _on_Button_pressed():
	if health >= 100:
		wrong_sound.play()
	else:
		click_sound.play()
		if Globals.money >= Globals.cost_feed:
			Globals.money -= Globals.cost_feed
			health = min(100, health + Globals.family_feed_heal)
			
func sick1():
	var delta = 3
	health -= rng.randi_range(Globals.family_health_decay - delta, Globals.family_health_decay + delta) + Globals.day_count + Globals.num_units
	if health <= 0:
		Globals.event_log_family_dead(character)
	update_dead()

func update_dead():
	if health <= 0:
		feed_button.visible = false
		harvest_button.visible = false
		feed_sprite.visible = false
		harvest_sprite.visible = false

func _on_HarvestButton_pressed():
	var money_earned = Globals.child_harvest_earnings
	if character == "wife":
		 money_earned = Globals.wife_harvest_earnings
	click_sound.play()
	Globals.money += money_earned
	health = 0
	update_dead()
	harvest_sound.play()
	
