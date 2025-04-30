extends Node3D

@export_group("Teleport")
@export var target_level: String = ''
@export var target_location = Vector3(0,1,0)

@onready var area_3d: Area3D = $Area3D

func _ready() -> void:
	area_3d.body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if target_level == 'level1':
		StatsManager.reset_stats()
	elif target_level != 'gameover':
		StatsManager.increase_level()
	var current_scene = get_tree().current_scene
	current_scene.switch_level(target_level, target_location)
