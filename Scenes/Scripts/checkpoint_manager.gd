#checkpoint_manager.gd (autoload)
extends Node

var respawn_position: Vector3 = Vector3.ZERO
var respawn_direction: float = 0.0
var has_hit_ball: bool = false
var ball_scene = preload("res://Scenes/Balls/golf_ball_red.tscn")

func set_checkpoint(position: Vector3, direction: float = 0.0) -> void:
	respawn_position = position
	respawn_direction = direction
	has_hit_ball = true
	print("Checkpoint set at: ", position, " facing: ", direction)

func respawn() -> void:
	# Only respawn if we've hit the ball at least once
	if respawn_position == Vector3.ZERO:
		print("Cannot respawn - no checkpoint set yet")
		return
		
	# Remove current ball
	get_tree().call_group("golf_ball", "queue_free")
	
	# Spawn new ball with correct physics properties
	var new_ball = ball_scene.instantiate()
	get_tree().current_scene.add_child(new_ball)
	new_ball.global_position = respawn_position
	# Position player
	var player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	if player:
		var offset = Vector3(0, 0.2, 0.2).rotated(Vector3.UP, respawn_direction)
		player.global_position = respawn_position + offset

func reset() -> void:
	get_tree().reload_current_scene.call_deferred()
