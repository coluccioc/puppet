extends CharacterBody2D

enum NPCState {IDLE, WALKING, EMPLOYED}

@export var speed = 100
@export var health = 50
var master = null
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("root/Main/Player")
	master = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
