# TODO during movement disallow another click to set a new target

extends CharacterBody2D

const MOTION_SPEED = 80
const FRICTION_FACTOR = 0.89
const TAN30DEG = tan(deg_to_rad(30))

@onready var _animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
#var target = position
#var velocity = Vector2()
@onready var target = position
@onready var tile_map = $"../TileMap"
@onready var line_2d = $"../Line2D"

var angle_to_player
# If we are in the rotation state (turn between tiles) or moving to the next tile.
var should_rotate = false
var player_initial_view_angle = 0 # Because the tank looks left

#var target = position
#var target_pos_clicked
var tile_position := Vector2i()  # hard-coded starting tile position
var tile_path = []  # of tile positions
var world_path = []  # of global coordinates
var screen_size # Size of the game window.
@export var speed = 100



func _ready():
	screen_size = get_viewport_rect().size
	var begining_pos_dict = tile_map.position_check(position)
	tile_position = begining_pos_dict.get('pos_clicked')
	#print('target:', target)
	#print('tile_map in Player:', tile_map.valid_cells)

func _input(event):
	if event.is_action_pressed("left_click"):
		var pos_dict = tile_map.position_check(get_global_mouse_position())

		tile_path.clear()
		world_path.clear()
		
		var pos_clicked = pos_dict.get('pos_clicked')
		var local_pos_center_position = pos_dict.get('local_pos_center_position')

		if pos_clicked in tile_map.valid_cells and not tile_position == pos_clicked:
			_animation_player.play("Tank_moves")

			var path_found = []
			path_found = tile_map.new_find_path(tile_position, pos_clicked)
			print('Path found', path_found)
			#line_2d.default_color = Color.WEB_MAROON
			
			# keep both world and map position arrays in memory
			tile_path = path_found

			for node in path_found:
				var path_position = tile_map.map_to_local(node)

				world_path.append(path_position)
			# draw line
			#line_2d.points = PackedVector2Array(world_path)
			# remove first (current) position
			tile_path.remove_at(0)
			world_path.remove_at(0)
			# get next position to move to
			tile_position = tile_path.pop_front()
			target = world_path.pop_front()
			should_rotate = true
		else:
			printerr("need move OR out of area!")

func snap_to_fix_angle(angle):
	var max_difference = 1
	var swaps = [30, 90, 120, -150, -90, -30]

	for swapped_angle in swaps:
		if angle > swapped_angle - max_difference and angle < swapped_angle + max_difference:
			angle = swapped_angle
		
	return angle

func _physics_process(delta):
	if target:
		if should_rotate:
			var delta_sign  = 1
			#print(
				#'PRE',
				#global_position, 
				#' ', 
				#(rotation * 180 / 3.14 if rotation is float else 0), 
				#' ', 
				#(angle_to_player * 180 / 3.14 if angle_to_player is float else 0)
			#)
			#print('GP', global_position, global_position.direction_to(target), )
			
			#150 -> -90
			#-150 -> 150
			#90 -> -150
			#-150 -> 90
			#-90 -> 150

			angle_to_player = snap_to_fix_angle(
				rad_to_deg(
					global_position.direction_to(target).angle()
				)
			)

			# FIXME
			#if player_initial_view_angle == 150 and angle_to_player == -90:
				#angle_to_player = 150 + 60
			
			rotation_degrees = move_toward(rotation_degrees, angle_to_player, delta_sign * delta * 100)

			print(
				'POST',
				should_rotate, 
				' ', 
				rotation_degrees, 
				' ', 
				angle_to_player
			)
			
			if snap_to_fix_angle(angle_to_player) == snap_to_fix_angle(rotation_degrees):
				print("rotation stops")
				should_rotate = false
		else:
			rotation_degrees = snap_to_fix_angle(rotation_degrees)
			player_initial_view_angle = rotation_degrees
			
			velocity = position.direction_to(target) * speed
			#look_at(target)
			if position.distance_to(target) > 1:
				move_and_slide()
			else:
				set_position(target)

				# we've reached current destination, get the next one (if any left)
				if tile_path.size() > 0:
					tile_position = tile_path.pop_front()
					target = world_path.pop_front()
					should_rotate = true # TODO what if we need to go straight to the next tile.
				else:
					_animation_player.stop()
