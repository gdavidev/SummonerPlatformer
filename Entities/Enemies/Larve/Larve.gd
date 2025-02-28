extends Enemy

@export_enum("Right", "Left") var direction  = "Right"
@export_range(0.0, 60.0) var speed = 30.0
@export var grv := 120.0

#var velocity: Vector2
var dir:= 1
var body_in_hitbox = null
var is_player_blocking := false
var is_falling := false
var is_ignoring_rotation: bool = false

@onready var incoming_corner = $Body/Raycasts/IncomingCorner
@onready var corner_normal = $Body/Raycasts/CornerNormal
@onready var foward_ray = $Body/Raycasts/Foward
@onready var body = $"Body"

func _ready():
	$AnimationPlayer.play("Ready")
	if direction == "Right":
		dir = 1
	else:
		dir = -1
	body.scale.x = dir
	

func damage_colliding_body():
	if body_in_hitbox != null:
		body_in_hitbox.damage(self.global_position, damage, knockback, true)
	

func move_foward():
	if not is_player_blocking:
		velocity = (transform.x * (speed * int(!is_falling)) *dir)
	

func apply_movement(_delta):
	if incoming_corner.is_colliding():
		is_falling = false
		if foward_ray.is_colliding():
			global_position = foward_ray.get_collision_point()
			rotation = foward_ray.get_collision_normal().angle() + PI/2
	elif corner_normal.is_colliding():
		rotation = corner_normal.get_collision_normal().angle() + PI/2
		global_position = corner_normal.get_collision_point()
	else:
		is_falling = true
	
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	

func apply_gravity(_delta):
	velocity.y += grv * _delta
	

func apply_damage(amount):
	health -= amount
	$"Timers/StaggeredTime".start()
	if health <= 0:
		$StateMachine.current_state.emit_signal("finished", "Died")
	else:
		$StateMachine.current_state.emit_signal("finished", "Staggered")
	

func _on_BlockedByPlayer_body_entered(_body):
	is_player_blocking = true
	

func _on_BlockedByPlayer_body_exited(_body):
	is_player_blocking = false
	

func _on_TouchDamageHitBox_area_entered(area):
	if area.get_parent().has_method("damage"):
		body_in_hitbox = area.get_parent()


func _on_TouchDamageHitBox_area_exited(_area):
	body_in_hitbox = null
