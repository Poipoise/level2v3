extends TileMap

@onready var minimap = $CanvasLayer/Minimap

# Called when the node enters the scene tree for the first time.
func _ready():
	for object in get_tree().get_nodes_in_group("minimap_objects"):
		object.removed.connect(minimap._on_object_removed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
