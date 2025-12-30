extends Node

@export var win_score := 5

var left_team_score := 0
var right_team_score := 0


var match_start_time : float = 0.0
var match_end_time : float = 0.0
var match_duration : float = 0.0



@onready var players_node := get_parent().get_node("Players")
@onready var ball := get_parent().get_node("Ball")
@onready var goal_popup := get_parent().get_node("GoalPopup")

var player_spawn_positions := {}
var ball_spawn_position : Vector3

func _ready():
	match_start_time = Time.get_ticks_msec()
	# Save initial player positions
	for player in players_node.get_children():
		if player is CharacterBody3D:
			player_spawn_positions[player] = player.global_transform.origin

	# Save ball spawn position
	ball_spawn_position = ball.global_transform.origin


func goal_scored(goal_side: String):
	# LEFT goal means RIGHT team scored
	if goal_side == "LEFT":
		right_team_score += 1
	else:
		left_team_score += 1

	# Show UI popup
	goal_popup.show_goal(left_team_score, right_team_score)

	# Reset positions
	reset_positions()

	# Check win condition
	check_match_end()


func reset_positions():
	for player in player_spawn_positions.keys():
		if not is_instance_valid(player):
			continue

		player.velocity = Vector3.ZERO
		player.global_transform.origin = player_spawn_positions[player]

	# Reset ball (also check!)
	if is_instance_valid(ball):
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO
		ball.global_transform.origin = ball_spawn_position

func check_match_end():
	if left_team_score >= win_score:
		match_won("LEFT TEAM")
	if right_team_score >= win_score:
		match_won("RIGHT TEAM")


func match_won(winning_team: String):
	match_end_time = Time.get_ticks_msec()
	match_duration = (match_end_time - match_start_time) / 1000.0  # seconds

	GameData.last_match_time = match_duration
	GameData.last_match_winner = winning_team

	var player_won := (winning_team == "LEFT TEAM")
	goal_popup.show_result(player_won)

	save_team_score(winning_team)

	left_team_score = 0
	right_team_score = 0

	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://menues/scenes/score_board/score_board.tscn")


func save_team_score(team_name: String):
	if not GameData.team_scores.has(team_name):
		GameData.team_scores[team_name] = 0

	GameData.team_scores[team_name] += 1
