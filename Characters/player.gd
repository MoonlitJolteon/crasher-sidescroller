extends CharacterBody2D

@export var max_speed: float = 200.0
@export var acceleration: float = 50.0
@export var jump_force: float = -300.0
@export var base_weight: float = 1
@export var min_weight: float = 0.5
@export var max_weight: float = 2.0


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var animation_locked: bool = false
var direction: Vector2 = Vector2.ZERO
var was_in_air: bool = false
var current_speed: float = 0.0
var current_weight: float = base_weight
var is_jumping: bool = false

func _physics_process(delta: float) -> void:

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
			
func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

func jump():
	velocity.y = jump_force
	animated_sprite.play("jump_start")
	animation_locked = true

func land():
	animated_sprite.play("jump_end")
	animation_locked = true
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump_end":
		animation_locked = false
