extends StaticBody2D

@export var damage: int = 20
@export var knockback: float = 1.5

var body_in_hitbox

func _physics_process(_delta):
	if body_in_hitbox:
		body_in_hitbox.damage(global_position, damage, knockback, true)
	

func _on_HitBox_area_entered(area):
	if area.get_parent().has_method("damage"):
		body_in_hitbox = area.get_parent()


func _on_HitBox_area_exited(_area):
	body_in_hitbox = null
