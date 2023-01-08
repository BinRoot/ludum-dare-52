extends Node

var money : int = 100
var cost_replenish : int = 50
var cost_feed : int = 5
var cost_grid_unit : int = 200
var feed_heal : int = 20
var init_time_left : int = 60
var init_health : int = 80
var day_count : int = 1
var harvest_earning : int = 200
var harvested_units : Array = []
var day_event_log : Array = []

func _ready():
	pass
	
func eventLogNewUnit(unit_name : String):
	day_event_log.append(
		{
			"type": "new_unit",
			"name": unit_name
		}
	)

