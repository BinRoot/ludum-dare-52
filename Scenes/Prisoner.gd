extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
onready var img : TextureRect = $TextureRect
onready var sprite : AnimatedSprite = $AnimatedSprite
onready var blood_sprite : AnimatedSprite = $BloodSprite
onready var harvest_pop_sprite : AnimatedSprite = $HarvestPopSprite
var is_being_harvested = false
var is_dead = false
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	reset()

func dead():
	if not is_being_harvested:
		sprite.play("dead")
		is_dead = true

func harvest():
	is_being_harvested = true
	sprite.play("harvest")
	blood_sprite.frame = 0
	blood_sprite.play("default")

func after_hotdog_eaten():
	if not is_being_harvested:
		sprite.frame = 0
		sprite.play("after_eat")

func reset():
	sprite.play("idle_0")

func set_color(color):
	sprite.modulate = color

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_size(_new_size):
	push_warning("cannot set Prisoner size")
	
func get_size():
	return Vector2(
		img.rect_size.x * img.rect_scale.x,
		img.rect_size.y * img.rect_scale.y
	)


func _on_Timer_timeout():
	if not is_being_harvested and not is_dead:
		var random_number = rng.randi_range(0, 4)
		sprite.play("idle_{0}".format([random_number]))

