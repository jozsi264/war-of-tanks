extends Node2D

# Transform2D * root
@onready var global_pos: Vector2 = global_transform * position
@onready var global_rot: float = global_transform.x.angle() 
@onready var global_scl: Vector2 = global_transform * scale

var tile_map_pos

func _ready():
	print("root", position)

func _unhandled_input(event):
	if event is InputEventMouse and event.is_action_pressed("left_click"):
		#print('get_global_transform():', get_global_transform())
		#print('Camera2D:', $Camera2D.get_canvas_transform().affine_inverse())
		#print('$Player:', $Player.get_canvas_transform().affine_inverse())
		var event_transform = Transform2D().translated(event.position)
		#print('transform:', event_transform)
		
		var grid_local_transform = event_transform * $Camera2D.get_canvas_transform().affine_inverse()
		#print('tilemap_transform:', grid_local_transform)
	
		tile_map_pos = $TileMap.local_to_map(grid_local_transform.get_origin())
