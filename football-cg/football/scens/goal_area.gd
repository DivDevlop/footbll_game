extends Area3D

var player_score: int = 0
var ai_score: int = 0


enum goal { goal_for, goal_against }

# Expose it as a dropdown in Inspector
@export var goal_side: goal
@onready var label_3d: Label3D = $Label3D
@export var side: String

@export var respawn_position:Node3D
func _ready() -> void:
	label_3d.text = side

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Ball":
		if goal.goal_for == goal_side:
			ai_score += 1
			print("Player:", player_score, "         AI:", ai_score)
		else:
			player_score += 1
			print("Player:", player_score, "AI:", ai_score)
		# Reset ball to center
		body.global_position = respawn_position.global_position
