extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
onready var img : TextureRect = $TextureRect
onready var sprite : AnimatedSprite = $AnimatedSprite
onready var blood_sprite : AnimatedSprite = $BloodSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

func harvest():
	sprite.play("harvest")
	blood_sprite.frame = 0
	blood_sprite.play("default")

func reset():
	sprite.play("idle")

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
