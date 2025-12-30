extends Node

@onready var player := $"../Players/Player"
@onready var ai_1 := $"../Players/AI"
@onready var ai_2: CharacterBody3D = $"../Players/AI2"

var duplicated_ai: Array = []

@onready var goal_popup: CanvasLayer = $"../GoalPopup"

func _ready():
	apply_difficulty()
	configure_match()

	
	goal_popup.visible = true
	goal_popup.get_node("Panel/VBoxContainer/goal_text").text = "Get Ready!"
	goal_popup.get_node("Panel/VBoxContainer/score_text").text = " "

	# Pause the game
	get_tree().paused = true

	# Wait for few seconds (change time if needed)
	await get_tree().create_timer(2.5).timeout

	# Resume game
	get_tree().paused = false
	goal_popup.visible = false


func configure_match():
	match GameData.game_mode:
		"1v1":
			ai_2.queue_free()


		"1v2":
			pass


		"Free":
			ai_1.queue_free()
			ai_2.queue_free()







func apply_difficulty():
	# This matches your exported Difficulty dropdown
	#GameData.difficulty
	ai_1.difficulty = GameData.difficulty
	ai_2.difficulty = GameData.difficulty
