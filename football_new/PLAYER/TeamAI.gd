extends Node3D

# =========================
# ENUM
# =========================
enum TeamState { ATTACK, DEFEND }

# =========================
# EXPORTS
# =========================
@export var team_id := 0              # 0 = Player team, 1 = Opponent
@export var ball: RigidBody3D
@export var opponent_goal: Node3D
@export var own_goal: Node3D
@export var human_player: Node3D      # ONLY for player team

# =========================
# INTERNAL
# =========================
var state : TeamState = TeamState.DEFEND
var ai_players : Array = []

# =========================
# FORMATION OFFSETS (5v5)
# =========================
var formation := {
	"GK": Vector3(0, 0, -10),
	"DEFENDER": Vector3(0, 0, -6),
	"MIDFIELDER": Vector3(0, 0, -2),
	"WINGER_L": Vector3(-5, 0, -2),
	"WINGER_R": Vector3(5, 0, -2),
	"STRIKER": Vector3(0, 0, 4)
}

# =========================
# READY
# =========================
func _ready() -> void:
	for child in get_children():
		if child.has_method("set_team_context"):
			ai_players.append(child)
			child.set_team_context(self)

# =========================
# PROCESS
# =========================
func _physics_process(delta: float) -> void:
	update_team_state()
	update_team_positions()

# =========================
# TEAM STATE
# =========================
func update_team_state() -> void:
	var owner = ball.get_parent()

	if owner:
		# Player team: human has the ball
		if team_id == 0 and human_player and owner == human_player:
			state = TeamState.ATTACK
			return

		# Same team has the ball (AI or player)
		if owner.is_in_group("team_%d" % team_id):
			state = TeamState.ATTACK
		else:
			state = TeamState.DEFEND
	else:
		state = TeamState.DEFEND


# =========================
# POSITIONING
# =========================
func update_team_positions() -> void:
	var base_pos : Vector3

	if state == TeamState.ATTACK:
		base_pos = ball.global_position
	else:
		base_pos = own_goal.global_position

	for ai in ai_players:
		var offset = get_role_offset(ai.role)
		ai.team_target_position = base_pos + offset

# =========================
# ROLE OFFSET
# =========================
func get_role_offset(role) -> Vector3:
	match role:
		0: return formation["GK"]
		1: return formation["DEFENDER"]
		2: return formation["MIDFIELDER"]
		3: return formation["WINGER_L"]
		4: return formation["STRIKER"]
		_: return Vector3.ZERO
