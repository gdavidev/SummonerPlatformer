extends Node

const UNIT_SIZE = 16

@onready var pos_pointer = preload("res://Debug/PositionPointer.tscn")
@onready var player = $Player: set = set_player
@onready var scene_transition = $SceneTransition
@onready var current_camera
@onready var post_processing = $CanvasLayer/PostProcessing_tool

func _ready():
	randomize()
	self.get_node("/root/Global").process_mode = Node.PROCESS_MODE_ALWAYS
	#Engine.set_target_fps(Engine.get_physics_ticks_per_second())
	
	add_player_if_not_already()
	

func add_player_if_not_already():
	if get_tree().current_scene.get_node_or_null("Allies/Player") == null:
		player.get_parent().remove_child(player)
		#current_camera.get_parent().remove_child(current_camera)
		get_tree().current_scene.get_node_or_null("Allies").add_child(player)
		#player.add_child(current_camera)
		#get_tree().current_scene.set_camera_limits()
		#player.global_position = get_tree().current_scene.get_node("RespawnPosition").global_position
		

func set_player(value):
	player = value
	if value != null:
		$DebugDisplay.connect_player()
		$UI.connect_player()
	

func _input(event):
	if event is InputEvent and event.is_action_pressed("pause"):
		Global.pause()
	if event is InputEvent and event.is_action_pressed("reset"):
		Global.reload()


func pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	

func point_at(pos: Vector2, _name: String = "None"):
	if _name == "None":
		_name = str(pos)
	var p = pos_pointer.instantiate()
	get_tree().current_scene.add_child(p)
	p.place(pos, _name)
	

func load_scene_with_player(file_path, target_door):
	scene_transition.fade_in()
	var last_camera_pos = current_camera.global_position
	current_camera.get_parent().remove_child(current_camera)
	self.add_child(current_camera)
	current_camera.global_position = last_camera_pos
	last_camera_pos = null
	player.get_parent().remove_child(player)
	await get_tree().create_timer(0.2).timeout
	current_camera.get_parent().remove_child(current_camera)
	get_tree().change_scene_to_file(file_path)
	await get_tree().node_added
	await get_tree().current_scene.ready
	await get_tree().idle_frame
	get_tree().current_scene.get_node("Allies").add_child(player)
	player.add_child(current_camera)
	get_tree().current_scene.set_camera_limits()
	current_camera.global_position = player.global_position
	var target_door_node = get_tree().current_scene.get_node("Doors/" + target_door)
	for i in get_tree().get_nodes_in_group("Door"):
		i.pick_door_direction()
	player.global_position = target_door_node.spawn_pos
	await get_tree().create_timer(0.2).timeout
	scene_transition.fade_out()
	

func reload():
	if scene_transition.transitioning == true:
		return
	scene_transition.fade_in()
	await get_tree().create_timer(0.2).timeout
	$DebugDisplay.set_active(false)
	if player.is_inside_tree():
		current_camera.get_parent().remove_child(current_camera)
		player.get_parent().remove_child(player)
	add_child(current_camera)
	add_child(player)
	
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	await get_tree().idle_frame
	add_player_if_not_already()
	scene_transition.fade_out()
	await get_tree().create_timer(0.2).timeout
	get_tree().current_scene.set_camera_limits()
	for i in get_tree().get_nodes_in_group("Door"):
		i.pick_door_direction()
	$DebugDisplay.set_active(true)
	
