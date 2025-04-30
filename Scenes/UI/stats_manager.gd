#stats_manager.gd (autoload)
extends Node

var player_strokes: int = 0
var par_for_course: int = 0
var level: int = 1
var time: float = 0.0
var score: float = 0.0

func record_stroke() -> void:
	player_strokes += 1

func erase_stroke() -> void:
	player_strokes -= 1

func reset_stats() -> void:
	player_strokes = 0
	level = 1
	time = 0.0
	score = 0.0
	
func increase_level() -> void:
	level += 1

func increase_score(amount: float) -> void:
	score += amount
