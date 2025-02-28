@tool
extends Node2D

enum types {Spike}
var scenes = {types.Spike: preload("res://Entities/Traps/Spike/Spike.tscn")}
@export_enum("types") var type: set = _update_type
@export_range(1, 60) var quantity = 1: set = _update_quantity

func _ready():
	if self.get_children().size() == 0:
		var t = scenes[type].instantiate()
		self.add_child(t)
		t.set_owner(self)
	

func _update_type(value):
	type = value
	
	if self.get_children().size() > 0:
		for i in self.get_children():
			var t = scenes[type].instantiate()
			i.queue_free()
			self.add_child(t)
			t.set_owner(self)
			await t.tree_entered
	

func _update_quantity(value):
	quantity = self.get_children().size()
	if quantity < value:
		for i in range(value - quantity):
			var t = scenes[type].instantiate()
			self.add_child(t)
			t.set_owner(self)
			var trap_size = t.get_node("Sprite2D").get_texture().get_size().x
			t.position.x = (quantity) * trap_size
			quantity = self.get_children().size()
	else:
		for i in range(abs(value - quantity)):
			self.get_children()[quantity -1].queue_free()
			await self.get_children()[quantity -1].tree_exited
			quantity = self.get_children().size()
