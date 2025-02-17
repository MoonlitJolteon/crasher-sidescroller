extends CharacterBody2D

@export var max_speed: float = 200.0
@export var acceleration: float = 50.0
@export var jump_force: float = -300.0
@export var base_weight: float = 1
@export var min_weight: float = 0.5
@export var max_weight: float = 2.0
@export var weight_change_speed: float = 1000
@export var vertical_momentum_factor: float = 5000.0
@export var horizontal_momentum_factor: float = 500.0
@export var current_speed: float = 0.0
@export var ground_speed: Vector2 = Vector2.ZERO

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var weight_label = $WeightLabel

var animation_locked: bool = false
var direction: Vector2 = Vector2.ZERO
var was_in_air: bool = false
var current_weight: float = base_weight
var is_jumping: bool = false
var jump_start_weight: float = base_weight

func _process(_delta):
	# Update the label's text with the current weight
	weight_label.text = (
		"Weight: " + str(current_weight) +
		"\nDelta Weight: " + str(current_weight - jump_start_weight) +
		"\nVelocity X: " + str(ground_speed.x)
		)
	
	# Position the label above the character's head
	weight_label.global_position = global_position + Vector2(-20, -75) # Adjust the Y offset as needed


func _physics_process(delta: float) -> void:
	if ground_speed == null:
		return
	
	# Weight changing
	if Input.is_action_pressed("decrease_weight"):
		current_weight = max(current_weight - (weight_change_speed * delta), min_weight)
	elif Input.is_action_pressed("increase_weight"):
		current_weight = min(current_weight + (weight_change_speed * delta), max_weight)
	elif Input.is_action_pressed("reset_weight"):
		current_weight = base_weight
	
	if was_in_air == true and is_on_floor():
		current_speed = ground_speed.x
	
	ground_speed.x = current_speed

	# Gravity and inertia
	if not is_on_floor():
		velocity += get_gravity() * delta
		was_in_air = true
	
		if is_jumping:
			# Apply inertia on weight change
			var weight_change = current_weight - jump_start_weight
			ground_speed.x += -weight_change * vertical_momentum_factor * delta
			velocity.y += weight_change * horizontal_momentum_factor * delta
	else:
		if was_in_air == true:
			land()
		was_in_air = false
		is_jumping = false
		jump_start_weight = current_weight

		# Constant forward movement
		if abs(current_speed - max_speed) < 1:
			current_speed = max_speed
			
		if current_speed < max_speed:
			current_speed += acceleration * delta
		elif current_speed > max_speed:
			current_speed -= acceleration * delta * ((current_speed - max_speed) / 30)
	
	# Handle Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
	
	update_animation()
	move_and_slide()
	update_facing_direction()

func update_animation():
	if not animation_locked:
		if ground_speed.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
			
func update_facing_direction():
	if ground_speed.x > 0:
		animated_sprite.flip_h = false
	elif ground_speed.x < 0:
		animated_sprite.flip_h = true

func jump():
	velocity.y = jump_force
	animated_sprite.play("jump_start")
	animation_locked = true
	is_jumping = true

func land():
	animated_sprite.play("jump_end")
	animation_locked = true
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump_end":
		animation_locked = false
