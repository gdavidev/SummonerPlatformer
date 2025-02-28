extends CharacterBody2D

signal grounded_updated(is_grounded)
signal update_health(health)
signal player_damaged(can_damage_boost, damager)
signal dead

const WALL_JUMP_FORCE = Vector2(160, -210)
const LEDGE_JUMP_FORCE = Vector2(0, -220)
const DAMAGE_BOOST_FORCE = Vector2(150, -120)
const KNOCKBACK_FORCE = Vector2(250, -200)
const SLOPE_STOP_THRESHOLD = 30.0
const DROPTHRU_BIT = 2

var max_speed := 110.0
var grav: float
var terminal_velocity = 1000
var min_jump_height := 0.8 * 16
var max_jump_height := 2.8 * 16
var jump_duration := 0.38
var health = 100 
var max_health = 100

#var velocity: Vector2
var max_jump_velocity: float
var min_jump_velocity: float

var jump_count: int = 0

var x_input: int
var y_input: int
var direction: int = 1
var wall_direction: int = 0

var is_jumping: bool = false
var is_grounded: bool
var is_inside_drop_thru: bool = false

@onready var ground_rays = $GroundRays
@onready var left_wall_rays = $WallRays/LeftWallRays
@onready var right_wall_rays = $WallRays/RightWallRays
@onready var ledge_rays = $LedgeDetection/LedgeRays
@onready var is_ground_near = $LedgeDetection/IsGroundNear
@onready var drop_thru_rays = $DropThruDetection/DropThruRays
@onready var ceilling_rays = $"CeillingDetection"

@onready var anim = $AnimationPlayer
@onready var sm = $StateMachine
@onready var body = $PlayerBody

@onready var coyote_timer = $Timers/CoyoteTimer
@onready var jump_buffer = $Timers/JumpBuffer
@onready var wall_leaving_cooldown = $Timers/WallLeavingCoolDown
@onready var wall_stickness_timer = $Timers/WallSticknessTimer
@onready var glide_call_timer = $Timers/GlideCallTimer
@onready var leaving_ledge_time = $Timers/LeavingLedgeTime
@onready var wall_jump_lose_control_time = $Timers/WallJumpLoseControlTime
@onready var ivulnerability_time = $"Timers/InvulnerabilityTimer"
@onready var damage_boost_time_window = $Timers/DamageBoostTimeWindow
@onready var damage_boost_travel_time = $Timers/DamageBoostTravelTime
@onready var knockback_lose_control_time = $Timers/KnockBackLoseControlTime
@onready var pan_camera_delay = $Timers/PanCameraDelay
@onready var hit_lag_timer = $Timers/HitLagTimer

func _ready():
	#kinematic equation for jumping arc
	grav = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2* grav * max_jump_height)
	min_jump_velocity = -sqrt(2* grav * min_jump_height)
	
	Global.player = self
	emit_signal("update_health", health)
	

func _process(_delta):
	#Global.post_processing.fog_overlay_velocity = lerp(Global.post_processing.fog_overlay_velocity, velocity * 0.0001, 0.1) + Vector2(0.001, 0.001)
	
	if !ivulnerability_time.is_stopped():
		if ground_rays.get_children()[2].get_collision_mask_value(4) == false:
			for i in ground_rays.get_children():
				i.set_collision_mask_value(4,  true)
			

func damage(damager_pos: Vector2, amount: int = 0, knockback_multiplier:float = 1, can_damage_boost := true):
	if ivulnerability_time.is_stopped():
		ivulnerability_time.start()
		health -= amount
		emit_signal("update_health", health)
		if can_damage_boost:
			damage_boost_time_window.start()
		
		emit_signal("player_damaged", can_damage_boost, knockback_multiplier, damager_pos)
	

func apply_knockback(dir, multiplier: float = 1.0):
	knockback_lose_control_time.start()
	velocity = Vector2(KNOCKBACK_FORCE.x * dir, KNOCKBACK_FORCE.y) * multiplier
	is_jumping = true
	

func get_x_input():
	x_input = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	

func get_y_input():
	y_input = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	

func handle_move_input():
	velocity.x = lerp(velocity.x, max_speed * x_input, get_h_weight())
	
	if x_input != 0:
		if is_grounded:
			update_facing_direction()
	

func update_facing_direction(override = null):
	if override != null:
		direction = override
	elif x_input != 0:
		direction = x_input
	body.scale.x = direction
	

func apply_movement(_delta):
	#var snap = Vector2.UP * 8 if !is_jumping else Vector2.ZERO
	
	if is_jumping && velocity.y >= 0:
		is_jumping = false
	
	if x_input == 0 && abs(velocity.x) < SLOPE_STOP_THRESHOLD:
		velocity.x = 0
	
	var was_grounded = is_grounded
	set_velocity(velocity)
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(deg_to_rad(46))
	move_and_slide()
	velocity.y = velocity.y
	#make the check for ground between was_grounded and is coyote_timer.start()
	if !is_inside_drop_thru:
		uptate_ground_state()
	if !is_grounded:
		if was_grounded && !is_jumping:
			coyote_timer.start()
			velocity.y = 0
	else:
		jump_count = 0
		
	if is_grounded and !jump_buffer.is_stopped() and !sm.current_state is CombatAction:
		jump_buffer.stop()
		jump()
	

func uptate_ground_state():
	is_grounded = !is_jumping and get_collision_mask_value(DROPTHRU_BIT) and \
					check_colliding_raycasts(ground_rays)
	emit_signal("grounded_updated", is_grounded)
	

func update_wall_direction():
	var is_near_wall_left = check_is_valid_wall(left_wall_rays)
	var is_near_wall_right = check_is_valid_wall(right_wall_rays)
	
	if is_near_wall_left[0] and is_near_wall_right[0]:
		wall_direction = x_input
	else:
		wall_direction = int(is_near_wall_right[0]) - int(is_near_wall_left[0])
	

func check_is_valid_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI * 0.55:
				return [true, wall_raycasts.get_children()[0].get_collision_point(),
						wall_raycasts.get_children()[1].get_collision_point()]
	return [false]
	

func get_h_weight():
	if is_grounded:
		return 0.2
	else:
		if x_input == 0:
			return 0.02
		elif x_input == sign(velocity.x) and abs(velocity.x) > max_speed:
			return 0.0
		else:
			return 0.1
	

func ledge_grab():
	var hand_pos = $LedgeDetection/HandPos/Left.global_position if wall_direction == -1 \
					 else $LedgeDetection/HandPos/Right.global_position
	var self_to_ledge_pos = get_ledge() + (global_position - hand_pos)
	self.global_position = self_to_ledge_pos
	

func get_ledge():
	var left_ray = ledge_rays.get_node("LeftRay")
	var right_ray = ledge_rays.get_node("RightRay")
	#var upper_left_wall_cast = left_wall_rays.get_node("UpperRay")
	#var upper_right_wall_cast = right_wall_rays.get_node("UpperRay")
	
	var direct_space = get_world_2d().direct_space_state
	
	left_ray.force_raycast_update()
	right_ray.force_raycast_update()
	
	if not is_ground_near.is_colliding():
		if wall_direction == -1 and !left_ray.is_colliding():
			var left_wall_collision_point = check_is_valid_wall(left_wall_rays)[2]
			#var cast_from = Vector2(left_ray.global_position.x + \
						#(left_wall_collision_point.x - left_ray.global_position.x) + wall_direction,
						 #left_ray.global_position.y)
			#var collision = direct_space.intersect_ray(cast_from,
				 #left_wall_collision_point, [], 2, true, false)
			
			var intersect_params := PhysicsRayQueryParameters2D.new()
			intersect_params.from = Vector2(left_ray.global_position.x + \
						(left_wall_collision_point.x - left_ray.global_position.x) + wall_direction,
						 left_ray.global_position.y)
			intersect_params.to = left_wall_collision_point
			intersect_params.collision_mask = 2
			intersect_params.collide_with_bodies = true
			intersect_params.collide_with_areas = false
			var collision = direct_space.intersect_ray(intersect_params)
			
			if collision:
				velocity.y = 0
				return collision.position
			else:
				return null
		
		if wall_direction == 1 and !right_ray.is_colliding():
			var right_wall_collision_point = check_is_valid_wall(right_wall_rays)[2]
			#var cast_from = Vector2(right_ray.global_position.x + \
						#(right_wall_collision_point.x - right_ray.global_position.x) + wall_direction,
						 #right_ray.global_position.y)
			#var collision = direct_space.intersect_ray(cast_from,
				 #right_wall_collision_point, [], 2, true, false)
			
			var intersect_params := PhysicsRayQueryParameters2D.new()
			intersect_params.from = Vector2(right_ray.global_position.x + \
						(right_wall_collision_point.x - right_ray.global_position.x) + wall_direction,
						 right_ray.global_position.y)
			intersect_params.to = right_wall_collision_point
			intersect_params.collision_mask = 2
			intersect_params.collide_with_bodies = true
			intersect_params.collide_with_areas = false
			var collision = direct_space.intersect_ray(intersect_params)
			
			if collision:
				velocity.y = 0
				return collision.position
			else:
				return null
		
		if wall_direction == 0:
			return 0
	

func step(applied_force: Vector2):
	velocity = Vector2.ZERO
	if applied_force.y <= 0:
		is_jumping = true
	velocity = applied_force
	

func jump(jump_force_override:Vector2 = Vector2.ZERO):
	if jump_force_override != Vector2.ZERO:
		velocity = jump_force_override
	else:
		velocity.y = max_jump_velocity - abs(velocity.x)/3
		velocity.x = velocity.x if velocity.x == 0 or !is_grounded else velocity.x * 1.18
	jump_count += 1
	is_jumping = true
	update_facing_direction()
	

func check_colliding_raycasts(raycasts):
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
		
	return false
	

func apply_gravity(_delta):
	if coyote_timer.is_stopped():
		velocity.y += grav * _delta
		velocity.y = clamp(velocity.y, -terminal_velocity, terminal_velocity)
	

func cap_speed_attaking():
	velocity.x = lerp(velocity.x, max_speed/4 * x_input, 0.5)
	

func cap_gravity_glide():
	velocity.y = lerp(velocity.y, 50, 0.5)
	

func handle_glide_call():
	if Input.is_action_pressed("jump"):
		if glide_call_timer.is_stopped():
			glide_call_timer.start()
	else:
		glide_call_timer.stop()
		

func handle_wall_stikness():
	if x_input != 0 and x_input != wall_direction:
		if wall_stickness_timer.is_stopped():
			wall_stickness_timer.start()
	else:
		wall_stickness_timer.stop()


func cap_gravity_wall_slide():
	var max_velocity
	if y_input == 1:
		max_velocity = grav / 4
	else:
		max_velocity = grav / 8
	velocity.y = min(velocity.y, max_velocity)
	

func _on_DropThruBitPassed_body_exited(_body):
	set_collision_mask_value(DROPTHRU_BIT, true)
	is_inside_drop_thru = false
	

func _on_DropThruBitPassed_body_entered(_body):
	is_inside_drop_thru = true
	

func _on_InvulnerabilityTimer_timeout():
	if ground_rays.get_children()[2].get_collision_mask_value(4) == true:
		for i in ground_rays.get_children():
			i.set_collision_mask_value(4,  false)
