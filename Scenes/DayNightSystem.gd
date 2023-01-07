extends Node2D

onready var grid_tester = $GridTester
onready var home = $Home

enum State {
	Work,
	Home
}

var current_state = State.Work

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_state == State.Work:
		grid_tester.visible = true
		grid_tester.camera.current = true
		home.visible = false
		home.camera.current = false
	elif current_state == State.Home:
		grid_tester.visible = false
		grid_tester.camera.current = false
		home.visible = true
		home.camera.current = true

func _on_GridTester_on_timeout():
	current_state = State.Home


func _on_Home_on_exit():
	current_state = State.Work
	grid_tester.init()
