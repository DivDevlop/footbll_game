extends Control

# Node references
@onready var result_label := $Panel/VBoxContainer/PlayerResult
@onready var time_label := $Panel/VBoxContainer/TimeLabel
@onready var leaderboard := $Panel/VBoxContainer/Leaderboard
@onready var back_button := $Panel/VBoxContainer/BackButton

func _ready():
	show_player_result()
	populate_fake_leaderboard()
	back_button.pressed.connect(_on_BackButton_pressed)


# Display player's result and match time
func show_player_result():
	if GameData.last_match_winner == "LEFT TEAM":
		result_label.text = "Result: YOU WON"
	else:
		result_label.text = "Result: YOU LOST"

	time_label.text = "Completion Time: " + format_time(GameData.last_match_time)


# Format seconds to MM:SS
func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]


# Populate leaderboard with fake data + player
func populate_fake_leaderboard():
	leaderboard.clear()

	# Fake players
	var fake_players = [
		{"name": "RazorX", "time": 92},
		{"name": "NeoStriker", "time": 105},
		{"name": "ShadowKick", "time": 110},
		{"name": "GoalBot_7", "time": 125},
		{"name": "IronFoot", "time": 140}
	]

	# Add the player at the end
	fake_players.append({
		"name": "YOU",
		"time": int(GameData.last_match_time)
	})

	# Sort by best time (lowest first)
	fake_players.sort_custom(func(a, b):
		return a["time"] < b["time"]
	)

	# Add entries to ItemList
	for i in fake_players.size():
		var entry = fake_players[i]
		leaderboard.add_item(
			str(i + 1) + ". " + entry["name"] + "  -  " + format_time(entry["time"])
		)


# Back button pressed → return to GameModeSelect
func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://menues/scenes/game_mode_selector/game_mode_select.tscn")
