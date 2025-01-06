extends StaticBody2D

@export var minion_scene: PackedScene  # Reference to the Minion scene
@export var spawn_radius: float = 50  # Radius around the workshop to attempt spawning
@export var spawn_interval: float = 20  # Time in seconds between spawns
@export var max_attempts: int = 10  # Maximum attempts to find a collision-free spot

var spawn_timer: float = 0

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_minion()
		spawn_timer = 0

func spawn_minion() -> void:
	# Get the direct space state for collision checks
	var space_state = get_world_2d().direct_space_state

	for i in range(max_attempts):
		var spawn_offset = Vector2(randf_range(-spawn_radius, spawn_radius), randf_range(-spawn_radius, spawn_radius))
		if spawn_offset.length() > spawn_radius:
			continue  # Skip points outside the radius

		var spawn_position = global_position + spawn_offset

		# Define a small collision shape for the check
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 5.0  # Adjust the size to match your minion's size

		var collision_query = PhysicsShapeQueryParameters2D.new()
		collision_query.shape = circle_shape
		collision_query.transform = Transform2D(0, spawn_position)  # Position the circle
		collision_query.collision_mask = 1  # Adjust mask as needed

		var collisions = space_state.intersect_shape(collision_query, 1)  # Maximum results to return

		if collisions.size() == 0:  # No collisions detected
			var minion = minion_scene.instantiate()
			minion.global_position = spawn_position
			get_parent().add_child(minion)
			print("Minion spawned at:", spawn_position)
			return

	print("Failed to find collision-free spot after", max_attempts, "attempts")
