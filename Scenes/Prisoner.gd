extends Node2D

var size : Vector2 = Vector2.ZERO setget set_size, get_size
onready var img : TextureRect = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_size(new_size):
	push_warning("cannot set Prisoner size")
	
func get_size():
	return Vector2(
		img.rect_size.x * img.rect_scale.x,
		img.rect_size.y * img.rect_scale.y
	)
