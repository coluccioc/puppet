extends Node2D
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player = get_node("/root/Main/Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#player.wood += 1
	pass
	

func _on_tree_destroyed(attacker):
	if attacker and attacker.has_method("add_wood"):
		attacker.add_wood(10)  # Give the player 10 wood
