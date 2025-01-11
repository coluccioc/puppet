extends CharacterBody2D

enum NPCState {IDLE, WALKING, HARVEST, FOLLOW}
var state = NPCState.HARVEST

@export var speed = 100
@export var health = 50
@export var max_resources = 50
var master = null
var player
var target
var routing

var wood = 0
var encumbered
var nearby_trees: Array = []
var nearest_resource
var chop_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area2d = $Area2D
	area2d.connect("area_entered", Callable(self, "_on_area_entered"))
	area2d.connect("body_exited", Callable(self, "_on_body_exited"))
	
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
			harvest()
		NPCState.IDLE:
			pass

# Find the resource dropoff nearest to the minion's current location, ideally
# factoring necessary pathing

func move_to(destination) -> void:
	
	if position.distance_to(destination) > 70:
		var direction
		velocity = Vector2.ZERO
		direction = (destination - position).normalized()
		velocity = direction * speed
		move_and_slide()

func harvest():
	if(target):
		print("Targeting")
	# If minion has >= max resource (weight?)
		if routing:
			move_to(target)
			if position.distance_to(target) < 50:
				routing = false
		elif is_encumbered():
			nearest_dropoff()
			if position.distance_to(target) < 50:
				player.wood += wood
				wood = 0
				nearest_tree()
			routing = true
		# Is not encumbered		
		else:
			if position.distance_to(target) < 50:
				if(nearby_trees.is_empty()):
					player.wood += wood
					wood = 0
					state = NPCState.IDLE
					print("Went Idle")
				else: chop()
			pass
	elif wood > 0:
		nearest_dropoff()
		routing = true
	else:
		nearest_tree()

func chop():
	if chop_timer == 0:
		if nearest_resource:
			nearest_resource.take_damage(25)
			chop_timer = 30
		else: nearest_tree()

func nearest_dropoff() -> void:
	target = null
	
func nearest_tree():
	print("Nearest Tree Search")
	if nearby_trees.is_empty():
		print("Empty Array")
		target = null
		return
	var nearest = nearby_trees[0]
	var distance = position.distance_to(nearest)
	for tree in nearby_trees:
		if position.distance_to(tree) < distance:
			nearest = tree
			distance = position.distance_to(tree)
	target = nearest.position
	nearest_resource = nearest
	

func is_encumbered() -> bool:
	if wood >= max_resources:
		return true
	else: return false
	
func _on_body_entered(body: Node) -> void:
	print("Entered Body")
	if body.is_in_group("trees"):
		nearby_trees.append(body)

func _on_body_exited(body: Node) -> void:
	print("Exit Body")
	if body.is_in_group("trees"):
		nearby_trees.erase(body)

func take_damage(amt : int, attacker):
	health -= amt
	if health <= 0:
		die()

func die():
	queue_free()
