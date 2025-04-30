#level.gd
extends Node3D

var pause_menu_scene: PackedScene = preload("res://Scenes/UI/simpe_pause_menu.tscn")
const scenes = {
	'level1': "res://Scenes/Levels/level_1.tscn",
	'level2': "res://Scenes/Levels/level_2.tscn",
	'level3': "res://Scenes/Levels/level_3.tscn",
	'level4': "res://Scenes/Levels/level_4.tscn",
	'level5': "res://Scenes/Levels/level_5.tscn",
	'lobby': "res://Scenes/Levels/lobby.tscn",
	'gameover': "res://Scenes/Levels/gameover.tscn",
	# Tutorial Level
	# HighScore Level
	# Driving Range / Zen Mode, perma shooting for points / hit moving targets?
}
func _ready() -> void:
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	CheckpointManager.respawn()

func switch_level(target: String, start_position: Vector3, start_direction: float = 0.0):
	# Clear any existing balls
	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "golf_ball", "queue_free")
	# Set the new spawn position in CheckpointManager for the next level
	CheckpointManager.set_checkpoint(start_position, start_direction)
	await get_tree().create_timer(0.1).timeout
	# Change to the new scene
	get_tree().change_scene_to_file(scenes[target])
