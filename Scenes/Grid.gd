extends Node2D

signal on_harvest
signal on_feed
signal on_purchased

var num_units : int = 1 setget set_num_units
var size : Vector2 = Vector2.ZERO setget set_size, get_size
onready var grid_unit_holder = $GridUnitHolder
var grid_unit_scene = preload("res://Scenes/GridUnit.tscn")
var gap_between_grids = 10
onready var main_loop : AudioStreamPlayer = $MainLoop
onready var opening_loop : AudioStreamPlayer = $OpeningLoop

func _ready():
	opening_loop.play()

func _process(delta):
	pass

func set_size(_new_size):
	push_warning("cannot set Grid size")


func get_size():
	var max_vec : Vector2 = Vector2.ZERO
	for child in grid_unit_holder.get_children():
		var child_pos = child.position + child.size
		if child_pos.y > max_vec.y:
			max_vec.y = child_pos.y
		if child_pos.x > max_vec.x:
			max_vec.x = child_pos.x
	return max_vec

func _on_harvest(value):
	emit_signal("on_harvest", value)

func _on_feed():
	emit_signal("on_feed")

func _on_purchased(value):
	emit_signal("on_purchased", value)

func add_grid_unit(i):
	var grid_unit_inst = grid_unit_scene.instance()
	grid_unit_holder.add_child(grid_unit_inst)
	grid_unit_inst.position.x += (grid_unit_inst.size.x + gap_between_grids) * (i % 3)
	grid_unit_inst.position.y += (grid_unit_inst.size.y + gap_between_grids) * int(i / 3)
	grid_unit_inst.connect("on_harvest", self, "_on_harvest")
	grid_unit_inst.connect("on_feed", self, "_on_feed")
	grid_unit_inst.connect("on_purchased", self, "_on_purchased")

func increment_num_units():
	set_num_units(num_units + 1)

func set_num_units(new_num_units):
	if new_num_units > 1:
		opening_loop.stop()
		main_loop.play()
	if new_num_units == num_units + 1:
		add_grid_unit(new_num_units - 1)
	elif new_num_units == num_units - 1:
		grid_unit_holder.remove_child(
			grid_unit_holder.get_children()[-1]
		)
	else:
		for child_node in grid_unit_holder.get_children():
			grid_unit_holder.remove_child(child_node)
		for i in range(new_num_units):
			add_grid_unit(i)
	num_units = new_num_units
