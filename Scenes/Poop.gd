extends Node2D

onready var animated_sprite : AnimatedSprite = $AnimatedSprite
onready var tween : Tween = $Tween
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	animated_sprite.frame = rng.randi_range(0, 4)

func shake():
	tween.interpolate_property(
		animated_sprite,
		"position",
		animated_sprite.position + Vector2.LEFT * 10,
		animated_sprite.position,
		0.1,
		Tween.TRANS_BOUNCE,
		Tween.EASE_IN_OUT
	)
	tween.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
