extends Node3D

@onready var strokes_label: Label3D = $StrokesLabel
@onready var time_label: Label3D = $TimeLabel
@onready var score_label: Label3D = $ScoreLabel

func _ready():
	# Initial update
	update_ui()
	
func update_ui():
	# Update all labels with current values from StatsManager
	strokes_label.text = "STROKES: " + str(StatsManager.player_strokes)
	score_label.text = "SCORE: " + str(StatsManager.score)
	
	# Format time as minutes:seconds
	var minutes = int(StatsManager.time / 60)
	var seconds = int(StatsManager.time) % 60
	time_label.text = "TIME: %02d:%02d" % [minutes, seconds]
