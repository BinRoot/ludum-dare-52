extends Node2D

onready var grid_tester = $GridTester
onready var home = $Home
onready var home_audio : AudioStreamPlayer = $HomeAudio

enum State {
	Work,
	Home
}

var current_state = State.Work

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


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
	grid_tester.pause()
	home_audio.play()
	home.reset()
	get_tree().call_group("day_audio", "stop")

func _on_Home_on_exit():
	current_state = State.Work
	Globals.day_event_log = []
	Globals.day_count += 1
	home_audio.stop()	
	grid_tester.init()
