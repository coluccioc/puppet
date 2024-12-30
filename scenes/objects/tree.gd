extends StaticBody2D

@export var size = 100
var health = size
var last_attacker = null

signal destroyed(attacker)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(damage : int, attacker: Node):
	health -= damage
	last_attacker = attacker
	if health <= 0:
		queue_free()
		emit_signal("destroyed", last_attacker)
		
