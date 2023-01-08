extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
onready var img : TextureRect = $TextureRect
onready var sprite : AnimatedSprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()

func harvest():
	sprite.play("harvest")

func reset():
	sprite.play("idle")

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
