extends Node2D

onready var grid_tester = $GridTester
onready var home = $Home
onready var game_over = $GameOver
onready var home_audio : AudioStreamPlayer = $HomeAudio

enum State {
	Work,
	Home,
	GameOver
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
	elif current_state == State.GameOver:
		grid_tester.visible = false
		grid_tester.camera.current = false
		home.visible = false
		home.camera.current = false
		game_over.visible = true
		game_over.camera.current = true

func log_poopy_situation():
	for unit in get_tree().get_nodes_in_group("unit"):
		if unit.num_poop > 0:
			Globals.event_log_poopy(unit.unit_name)


func _on_GridTester_on_timeout():
	log_poopy_situation()
	current_state = State.Home
	grid_tester.pause()
	home_audio.play()
	Globals.event_log_story(Globals.day_count)
	home.reset()
	get_tree().call_group("day_audio", "stop")
	

func _on_Home_on_exit():
	home_audio.stop()
	var is_found = Globals.is_harvestable_found()
	if Globals.day_count == 1 and Globals.money <= 0 and not is_found:
		current_state = State.GameOver
		game_over.reason = "day1"
	elif Globals.day_count > 1 and Globals.money <= 0 and not is_found:
		current_state = State.GameOver
		game_over.reason = "day1"
	else:
		current_state = State.Work
		Globals.day_event_log = []
		Globals.day_count += 1
		grid_tester.init()
