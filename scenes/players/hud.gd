extends CanvasLayer
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("/root/Main/Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		$CustomText.text = str(player.wood) + " " + str(player.health)
