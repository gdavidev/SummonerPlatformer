#remember to reset the state varibles in exit_state()
extends Node
class_name State

# warning-ignore:unused_signal
signal finished(_new_state)

@export_node_path("StateMachine") var parent_sm_path: NodePath
@export_node_path("Node") var parent_path: NodePath
@export_node_path("AnimationPlayer") var anim_path: NodePath

@onready var parent_sm: Node = get_node(parent_sm_path)
@onready var parent: Node = get_node(parent_path)
@onready var anim: Node = get_node(anim_path)

func _ready():
	pass

# warning-ignore:unused_argument
func enter(_old_state):
	return
	

# warning-ignore:unused_argument
func exit(_new_state):
	return
	

# warning-ignore:unused_argument
func handle_input(_event):
	return
	

# warning-ignore:unused_argument
func update(_delta):
	return
	

# warning-ignore:unused_argument
func _on_Animation_finished(_anim_name):
	return
	
