extends CharacterBody2D

enum NPCState {IDLE, WALKING, HARVESTING, FOLLOWING, FIGHTING}
var state = NPCState.HARVESTING

@export var speed = 100
@export var health = 50
@export var team = 1

# team allegience handlers
var allies: Array = []
var enemies: Array = []

var master = null
var player
var dropoff
var target
var routing

var inv

var cooldowns = {
	"refresh" : 0,
	"dash" : 0
}

var nearby_trees: Array = []
var nearby_enemies: Array = []
var nearest_resource
var chop_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var area2d = $Area2D
	area2d.connect("area_entered", Callable(self, "_on_area_entered"))
	area2d.connect("body_exited", Callable(self, "_on_body_exited"))
	
	player = get_tree().get_root().get_node("Main/Player")
	dropoff = get_tree().get_root().get_node("Main/Workshop")
	master = player
	
	inv = $Inventory
	inv.max_resources = 50


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		NPCState.FOLLOWING:
			if master:
				target = master.position
				move_to(target, 70)
			else:
				pass
				# print("NO MASTER")
		NPCState.HARVESTING:
			harvest()
		NPCState.IDLE:
			pass
		NPCState.FIGHTING:
			fight()

# Find the resource dropoff nearest to the minion's current location, ideally
# factoring necessary pathing

func move_to(destination, radius) -> void:
	
	if position.distance_to(destination) > radius:
		var direction
		velocity = Vector2.ZERO
		direction = (destination - position).normalized()
		velocity = direction * speed
		move_and_slide()

func fight():
	if nearby_enemies.is_empty():
		pass
	else:
		if cooldowns["refresh"] == 0:
			target = nearest(nearby_enemies)

func harvest():
	if(target):
	# If minion has >= max resource (weight?)
		if routing:
			# print("routing")
			move_to(target, 49)
			if position.distance_to(target) < 50:
				print("made it")
				routing = false
		elif is_encumbered():
			print("encumbered")
			target = nearest_dropoff()
			if(target):
				if position.distance_to(target) < 50 and player.inv:
					player.inv.add_resource("wood", inv.resources["wood"])
					inv.resources["wood"] = 0
					target = nearest(nearby_trees)
				routing = true
		# Is not encumbered
		else:
			if position.distance_to(target) < 50:
				if(nearby_trees.size()==0):
					player.inv.add_resource("wood", inv.resources["wood"])
					inv.resources["wood"] = 0
					state = NPCState.IDLE
					print("Went Idle")
				else: chop()
			else:
				target = nearest(nearby_trees)
	elif inv.resources["wood"] > 0:
		print("woodless")
		target = nearest_dropoff()
		routing = true
	else:
		target = nearest(nearby_trees)
		if (!target):
			state = NPCState.IDLE

func chop():
	if chop_timer == 0:
		print(str(nearest_resource))
		if nearest_resource and is_instance_valid(nearest_resource):
			print("chopping")
			nearest_resource.take_damage(25, self)
			chop_timer = 30
		else: target = nearest(nearby_trees)
	else:
		chop_timer -= 1

func nearest_dropoff():
	return dropoff.position
	
func nearest(nearby : Array):
	# print("Nearest Tree Search")
	if nearby.size() == 0:
		# print(str(nearby_trees.size()))
		return null
	var nearest = nearby[0]
	var distance = position.distance_to(nearest.position)
	for node in nearby:
		if position.distance_to(node.position) < distance:
			nearest = node
			distance = position.distance_to(node.position)
	nearest_resource = nearest
	routing = true
	return nearest.position


func is_encumbered() -> bool:
	if inv.resources["wood"] >= inv.max_resources:
		return true
	else: return false


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("tree"):
		print("Tree Added")
		nearby_trees.append(body)
	elif "team" in body:
		if body.team != team and body.team != 0:
			nearby_enemies.append(body)
	#Add more checks here for other nearby lists

func _on_body_exited(body: Node) -> void:
	print("Exit Body")
	if body.is_in_group("tree"):
		nearby_trees.erase(body)

func take_damage(amt : int, attacker):
	health -= amt
	if health <= 0:
		die()

func set_team(t: int):
	team = t
	if t not in allies:
		allies.append(t)
	
func add_ally_team(t: int):
	if t not in allies:
		allies.append(t)
	
func add_enemy_team(t: int):
	if t not in enemies:
		enemies.append(t)
	
func decrement_cds():
	for i in cooldowns:
		if cooldowns[i] > 0:
			cooldowns[i] -=1
	
func die():
	queue_free()
