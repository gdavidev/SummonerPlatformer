extends CanvasLayer

var coins: int
var health: int
var mana: int

var equipped_ablity_1
var equipped_ablity_2
var equipped_ablity_3

@onready var health_bar = $MarginContainer/Container/Sprite2D/Health
@onready var mana_bar = $MarginContainer/Container/Sprite2D/Mana

func _ready():
	update_bars()
	

func connect_player():
	if !Global.player.is_connected("update_health", Callable(self, "_on_Player_health_updated")):
		Global.player.connect("update_health", Callable(self, "_on_Player_health_updated"))
	health = Global.player.health
	

func update_bars():
	if is_instance_valid(Global.player):
		health_bar.value = Global.player.health * 100 / Global.player.max_health
	

func _on_Player_health_updated(value):
	health = value
	update_bars()
	
