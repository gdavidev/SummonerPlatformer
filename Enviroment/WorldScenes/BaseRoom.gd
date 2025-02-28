extends Node2D

@export_node_path("TileMap") var main_tilemap_path

#func set_camera_limits():
	#var main_tilemap = get_node(main_tilemap_path)
	#var map_limits = main_tilemap.get_used_rect()
	#var map_cellsize = main_tilemap.tile_set.tile_size
	#Global.current_camera.limit_left = (map_limits.position.x * map_cellsize.x) + 3.3 * 16
	#Global.current_camera.limit_right = (map_limits.end.x * map_cellsize.x) - 3.0* 16
	#Global.current_camera.limit_top = (map_limits.position.y * map_cellsize.y) + 5.1 * 16
	#Global.current_camera.limit_bottom = (map_limits.end.y * map_cellsize.y) - 1.3 * 16
	

func _process(_delta):
	if Input.is_action_just_pressed("ui_end"):
		Engine.time_scale = 0.2
	if Input.is_action_just_pressed("ui_home"):
		Engine.time_scale = 1.0
		
	if Input.is_action_just_pressed("ui_page_up"):
		Engine.time_scale += 0.5
	if Input.is_action_just_pressed("ui_page_down"):
		Engine.time_scale -= 0.5
	
