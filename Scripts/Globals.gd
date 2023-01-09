extends Node

var init_money : int = 80
var money : int = init_money
var cost_replenish : int = 35
var cost_feed : int = 5
var cost_clean : int = 5
var cost_grid_unit : int = 150
var feed_heal : int = 15
var family_feed_heal : int = 2
var init_time_left : int = 24
var init_health : int = 45
var day_count : int = 1
var init_family_health : int = 90
var family_health_decay = 15
var min_health_for_harvest : int = 90
var harvest_earning : int = 100
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
	
func event_log_family_dead(character: String):
	day_event_log.append(
		{
			"type": "family_died",
			"character": character
		}
	)
	
func event_log_story(_day_count):
	var lines = [
		"Your family needs you",
		"You feel uneasy with work",
		"Your soul does not move",
		"Those hotdogs seem off",
		"Is this the life?",
		"You crave money",
		"You lust for more"
	]
	if _day_count < len(lines):
		day_event_log.append(
			{
				"type": "story",
				"text": lines[_day_count]
			}
		)

func is_harvestable_found():
	var num_potential_hotdogs = int(money / cost_feed)
	var hp_potential_heal = num_potential_hotdogs * feed_heal
	var is_found = false
	for unit in get_tree().get_nodes_in_group("unit"):
		if hp_potential_heal >= min_health_for_harvest - unit.health:
			is_found = true
			break
	return is_found
