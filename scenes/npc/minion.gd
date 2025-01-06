extends CharacterBody2D

enum NPCState {IDLE, WALKING, EMPLOYED, FOLLOW}
var state = NPCState.FOLLOW

@export var speed = 100
@export var health = 50
var master = null
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_root().get_node("Main/Player")
	master = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction
	velocity = Vector2.ZERO
	match state:
		NPCState.FOLLOW:
			if master and position.distance_to(player.position) > 70:
				# print(master)
				direction = (player.position - position).normalized()
				velocity = direction * speed
				move_and_slide()
			else:
				pass
				# print("NO MASTER")

func take_damage(amt : int, attacker):
	health -= amt
	if health <= 0:
		die()

func die():
	queue_free()
