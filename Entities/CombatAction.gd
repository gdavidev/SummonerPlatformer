#remember to reset the state varibles in exit_state()
extends Node
class_name CombatAction

@export var damage: float = 10.0

signal finished(_new_state)

@export_node_path("Node") var parent_sm_path: NodePath
@export_node_path("Node") var parent_path: NodePath
@export_node_path("Node") var anim_path: NodePath
@onready var parent_sm: Node = get_node(parent_sm_path)
@onready var parent: Node = get_node(parent_path)
@onready var anim: Node = get_node(anim_path)

@onready var combat_handler: Node = get_node("../CombatHandler")

func _ready():
	get_node("HitBox").connect("body_entered", Callable(self, "_on_HitBox_body_entered"))
	get_node("HitBox/CollisionShape2D").disabled = true
	await parent.tree_entered
	parent.hit_lag_timer.connect("timeout", Callable(self, "_on_HitLagTimer_timeout"))
	

func enter(_old_state):
	pass
	

func exit(_new_state):
	get_node("HitBox/CollisionShape2D").disabled = true
	parent.hit_lag_timer.stop()
	anim.playback_speed = 1
	

func handle_input(_event):
	return
	

func update(_delta):
	parent.handle_move_input()
	parent.get_x_input()
	parent.get_y_input()
	parent.apply_gravity(_delta)
	parent.apply_movement(_delta)
	

func _on_Animation_finished(_anim_name):
	return
	

func _on_HitBox_body_entered(body):
	if body.has_method("damage"):
		#parent.hit_lag_timer.start()
		#anim.playback_speed = 0.0
		body.damage(damage)
	

func _on_HitLagTimer_timeout():
	anim.playback_speed = 1
	
