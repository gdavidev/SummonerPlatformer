@tool
extends Area2D

@export_file("*.tscn", "*.scn") var file_path : set = set_file_path
@export var target_door: String
@onready var spawn_pos = $Front/SpawnPos.global_position
var rand

enum door_type {LEFT, RIGHT, DOWN, UP, SLOPE}
@export var direction: door_type : set = _update

func pick_door_direction():
	rand = randi() % 2
	match direction:
		door_type.LEFT, door_type.RIGHT:
			spawn_pos = $Front/SpawnPos.global_position
		door_type.DOWN:
			spawn_pos = $ToDown/SpawnPos.global_position
		door_type.UP:
			if Global.player.velocity.x < 0 or Global.player.direction == -1:
				spawn_pos = $ToSides/SpawnPosLeft.global_position
			else:
				spawn_pos = $ToSides/SpawnPosRight.global_position
			Global.player.velocity = Vector2.ZERO
	

func _update(value):
	direction = value
	if !Engine.is_editor_hint():
		await self.tree_entered
	$ToDown/SpawnPos.hide()
	$ToSides.hide()
	$Front.hide()
	match direction:
		door_type.LEFT:
			scale = Vector2(1, 1)
			rotation = 0
			$Front.show()
		door_type.RIGHT:
			scale = Vector2(-1, 1)
			rotation = 0
			$Front.show()
		door_type.DOWN:
			scale = Vector2(1, 1)
			rotation = PI/2
			$ToDown/SpawnPos.show()
		door_type.UP:
			scale = Vector2(-1, -1)
			rotation = PI/2
			$ToSides.show()
			


func set_file_path(path):
	if typeof(path) == TYPE_STRING and path.get_extension() in ["tscn", "scn"]:
		if !FileAccess.file_exists(path):
			return
		file_path = path
	

func _on_SceneTransitionTrigger_body_entered(body):
	if body.is_in_group("Player"):
		Global.load_scene_with_player(file_path, target_door)
	

