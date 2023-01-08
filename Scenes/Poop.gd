extends Node2D

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	animated_sprite.frame = rng.randi_range(0, 4)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
