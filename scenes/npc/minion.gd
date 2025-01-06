extends CharacterBody2D

enum NPCState {IDLE, WALKING, HARVEST, FOLLOW}
var state = NPCState.FOLLOW

@export var speed = 100
@export var health = 50
@export var max_resources = 50
var master = null
var player
var target
var routing

var wood = 0
var encumbered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_root().get_node("Main/Player")
	master = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		NPCState.FOLLOW:
			if master:
				target = master.position
				move_to(target)
			else:
				pass
				# print("NO MASTER")
		NPCState.HARVEST:
			# If minion has >= max resource (weight?)
			if encumbered:
				# MAYBE CHECK IF TARGET FIRST TO MAKE SURE TREE DIDNT DIE OTW
				# If we moving, we keep on moving
				if routing:
					move_to(target)
				else:
					nearest_dropoff()
					if target:
						move_to(target)
						routing = true
			else:
				# Check to see if we're at a target
				# If at target
				pass

# Find the resource dropoff nearest to the minion's current location, ideally
# factoring necessary pathing
func nearest_dropoff() -> void:
	target = null

func move_to(destination) -> void:
	if position.distance_to(destination) > 70:
		var direction
		velocity = Vector2.ZERO
		direction = (destination - position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(amt : int, attacker):
	health -= amt
	if health <= 0:
		die()

func die():
	queue_free()
