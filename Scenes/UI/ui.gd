# ui.gd
extends Control

# References to the label nodes
@onready var level_label: Label = $MarginContainer/Panel/VBoxContainer/LevelLabel
@onready var strokes_label: Label = $MarginContainer/Panel/VBoxContainer/StrokesLabel
@onready var score_label: Label = $MarginContainer/Panel/VBoxContainer/ScoreLabel
@onready var time_label: Label = $MarginContainer/Panel/VBoxContainer/TimeLabel

func _ready():
	# Initial update
	update_ui()
	
func _process(delta):
	# Update time
	StatsManager.time += delta
	update_ui()
	
func update_ui():
	# Update all labels with current values from StatsManager
	level_label.text = "LEVEL: " + str(StatsManager.level)
	strokes_label.text = "STROKES: " + str(StatsManager.player_strokes)
	score_label.text = "SCORE: " + str(StatsManager.score)
	# Format time as minutes:seconds
	var minutes = int(StatsManager.time / 60)
	var seconds = int(StatsManager.time) % 60
	time_label.text = "TIME: %02d:%02d" % [minutes, seconds]
