extends Area3D

@export_enum("LEFT", "RIGHT") var goal_side : String

func _on_body_entered(body):
	if body.name == "Ball":
		get_node("/root/Game/ScoreManager").goal_scored(goal_side)
