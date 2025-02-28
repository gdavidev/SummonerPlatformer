extends CanvasLayer

@onready var label = $Panel/VBoxContainer/Label
#onready var input_sequence_handler = $"../InputSequenceHandler"
@export var player_path: NodePath
var health
#var combo = ""
var active: bool = true
var state: String

#func _ready():
#	input_sequence_handler.connect("input_sequence_updated", self, "_on_Input_Squence_Updated")


func connect_player():
	if !Global.player.is_connected("update_health", Callable(self, "update_health")):
		Global.player.connect("update_health", Callable(self, "update_health"))
		Global.player.get_node("StateMachine").connect("state_changed", Callable(self, "_on_StateMachine_state_changed"))
	health = "Health: " + str(Global.player.max_health)

func set_active(value):
	active = value
	

func _process(_delta):
	var grounded: String = "Grounded: " + str(Global.player.is_grounded)
	var jump_count: String = "Jump_num:" + str(Global.player.jump_count) 
	var wall_dir: String = "Wall_dir:" + str(Global.player.wall_direction)
	var speed: String = "Speed: " + str(snapped(Global.player.velocity.x, 0.01)) + "," +\
									str(snapped(Global.player.velocity.y, 0.01))
	label.text = state + "\n" + grounded + "\n" + jump_count + "\n" + wall_dir + \
				"\n" + speed + "\n" + health #+ "\n" + combo

func update_health(amount):
	health = "Health: " + str(amount)
	

#func _on_Input_Squence_Updated(value):
#	combo = "Combo: " + str(value)
#
#
func _on_StateMachine_state_changed(current_state):
	state = "State: " + str(current_state.name)
	
