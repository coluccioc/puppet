extends StaticBody2D

@export var size = 100
var health = size
var last_attacker = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(damage : int, attacker: Node):
	health -= damage
	var logs = min(damage, damage+health)
	if(attacker.inv and attacker.inv.has_method("add_resource")):
		attacker.inv.add_resource("wood", logs)
	elif attacker.inv:
		print("no inv")
	if(health <= 0):
		queue_free()
