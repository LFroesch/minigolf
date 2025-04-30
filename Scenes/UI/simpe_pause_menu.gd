# simple_pause_menu.gd
extends CanvasLayer

@onready var pause_menu = $PauseMenu
@onready var settings_menu = $SettingsMenu
var confirmation_dialog: ConfirmationDialog

func _ready():
	pause_menu.visible = false
	settings_menu.visible = false
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to reset the game?\nYou cannot undo this.\nAll checkpoints and progress will be lost."
	confirmation_dialog.title = "Reset Game"
	var label = confirmation_dialog.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_dialog.get_ok_button().text = "Reset"
	confirmation_dialog.get_cancel_button().text = "Cancel"
	confirmation_dialog.confirmed.connect(_on_reset_confirmed)
	add_child(confirmation_dialog)

func _input(event):
	if event.is_action_pressed("menu"):
		toggle_pause_menu()
		settings_menu.visible = false

func toggle_pause_menu():
	pause_menu.visible = !pause_menu.visible
	
	get_tree().paused = pause_menu.visible
	
	if pause_menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_resume_button_pressed() -> void:
	toggle_pause_menu()

func _on_settings_button_pressed() -> void:
	settings_menu.visible = true

func _on_back_button_pressed() -> void:
	settings_menu.visible = false

func _on_unstuck_button_pressed() -> void:
	get_tree().paused = false
	CheckpointManager.respawn()
	toggle_pause_menu()

func _on_reset_game_button_pressed() -> void:
	confirmation_dialog.popup_centered()

func _on_reset_confirmed() -> void:
	StatsManager.reset_stats()
	CheckpointManager.reset()
	toggle_pause_menu()

func _on_update_button_pressed() -> void:
	OS.shell_open("https://lfroesch.itch.io/trial-run")
