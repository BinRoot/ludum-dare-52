extends Node

var init_money : int = 100
var money : int = init_money
var cost_replenish : int = 50
var cost_feed : int = 5
var cost_grid_unit : int = 200
var feed_heal : int = 20
var family_feed_heal : int = 2
var init_time_left : int = 60
var init_health : int = 45
var day_count : int = 1
var init_family_health : int = 25
var family_health_decay = 10
var min_health_for_harvest : int = 90
var harvest_earning : int = 150
var harvested_units : Array = []
var day_event_log : Array = []
var time_left : int = init_time_left
var wife_harvest_earnings : int = 300
var child_harvest_earnings : int = 150
var num_units : int = 1

func _ready():
	pass
	
func eventLogNewUnit(unit_name : String):
	day_event_log.append(
		{
			"type": "new_unit",
			"name": unit_name
		}
	)

func event_log_poopy(unit_name: String):
	day_event_log.append(
		{
			"type": "poopy",
			"name": unit_name
		}
	)
