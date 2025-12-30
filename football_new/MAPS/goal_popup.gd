extends CanvasLayer

@onready var title_label :=$Panel/VBoxContainer/goal_text
@onready var score_label := $Panel/VBoxContainer/score_text




func show_goal(left_score: int, right_score: int):
	title_label.text = "GOAL!"
	score_label.text = str(left_score) + "  -  " + str(right_score)

	show_popup(2.0)


func show_result(player_won: bool):
	if player_won:
		title_label.text = "YOU WON"
	else:
		title_label.text = "YOU LOST"

	score_label.text = ""
	show_popup(3.0)


func show_popup(duration: float):
	visible = true
	get_tree().paused = true

	await get_tree().create_timer(duration).timeout

	get_tree().paused = false
	visible = false
