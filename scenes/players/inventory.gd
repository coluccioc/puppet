#TESTING THIS WITH NOTES
extends Node

var max_resources

var resources = {
	"wood" : 0,
	"stone" : 0,
	"gold" : 0,
	"souls" : 0
}

func add_resource(resource: String, amt: int) -> void:
	resources[resource] += amt

func spend_resource(resource: String, amt: int) -> bool:
	if resources[resource] >= amt:
		resources[resource] -= amt
		return true
	else:
		return false

func subtract_resource(resource: String, amt: int) -> void:
	resources[resource] -= amt
	if resources[resource] <= 0:
		resources[resource] = 0
