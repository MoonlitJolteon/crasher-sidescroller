extends Node2D

@onready var world: CanvasGroup = $CanvasGroup

@onready var player: CharacterBody2D = $Player

func _process(delta: float) -> void:
	
	world.position.x -= player.ground_speed.x * delta
	
	if world.position.x < -2000:
		world.position.x = 0
