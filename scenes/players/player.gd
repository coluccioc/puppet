extends CharacterBody2D
var inv
var stats

signal hit

@export var speed = 200
@export var health = 100

var screen_size

var cooldowns = {
	"swing" : 0,
	"dash" : 0
}

var movement_locked = false
var facing_direction = Vector2.DOWN


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	$PlayerAnimations.play()
	$SwingArea/SwingHitbox.set_deferred("monitoring", false)
	$SwingArea/SwingHitbox.set_deferred("disabled", true)
	
	#reference helper scripts
	inv = $Inventory
	stats = $Stats
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# subtract one from all active cooldowns
	decrement_cds()
	
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	velocity = velocity.normalized() * speed
	
	# Update facing_direction
	if velocity != Vector2.ZERO:
		facing_direction = velocity.normalized()
		
	# See if player is swinging. If so, turn off collision. 1 frame hit
	if cooldowns["swing"] > 0 and !$SwingArea/SwingHitbox.disabled:
			$SwingArea/SwingHitbox.set_deferred("monitoring", false)
			$SwingArea/SwingHitbox.set_deferred("disabled", true)
	
	if movement_locked:
		pass
	else:
		move_and_slide()
		# position += velocity * delta
		# position = position.clamp(Vector2.ZERO, screen_size)
		
		if velocity.x != 0:
			$PlayerAnimations.animation = "walk"
			$PlayerAnimations.flip_v = false
			$PlayerAnimations.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$PlayerAnimations.animation = "idle"
			# $AnimatedSprite2D.flip_v = velocity.y > 0
		else:
			$PlayerAnimations.animation = "idle"
	
	# Setting elifs for conflicting actions. Can't do two at once, so cascade
	
	# Check to see if new swing is input
	if Input.is_action_pressed("action") and cooldowns["swing"] == 0:
		cooldowns["swing"] = 30
		update_swing_hitbox_position()
		$SwingArea/SwingHitbox.set_deferred("monitoring", true)
		$SwingArea/SwingHitbox.set_deferred("disabled", false)

		if facing_direction.x != 0:
			$PlayerAnimations.animation = "swingH"
		else:
			$PlayerAnimations.animation = "swingV"
	# Trying temp speed boost first while player still controls movement each frame.
	# Could also try a TowerFall type dash lockout where player must move in the faced direction
	elif Input.is_action_pressed("dash") and cooldowns["dash"] == 0:
		cooldowns["dash"] = 15

func update_swing_hitbox_position():
	var offset = facing_direction * 16
	$SwingArea/SwingHitbox.position = offset

func _on_swing_area_body_entered(body: Node2D) -> void:
		if body.has_method("take_damage"):
			body.take_damage(25, self)

func take_damage(amt, attacker):
	if(attacker != self):
		health -= amt

func decrement_cds():
	for i in cooldowns:
		if cooldowns[i] > 0:
			cooldowns[i] -=1
