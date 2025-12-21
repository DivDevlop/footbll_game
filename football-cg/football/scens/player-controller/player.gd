extends CharacterBody3D

# Movement
@export var speed: float = 6.0
@export var rotation_speed: float = 10.0

# Kicking
@export var kick_force: float = 6.0
@export var hard_kick_multiplier: float = 1.5
@export var player_assist: float = 0.5  # 0 = no assistance, 1 = full assist

# Node references
@onready var kick_area: Area3D = $Kick_area
@export var ai_goal: Node3D  # assign in Inspector
@export var hard_kick_action: String = "hard_kick"  # input map action

func _physics_process(delta: float) -> void:
	# --- Movement ---
	var input: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)

	# Normalize input to prevent faster diagonal movement
	if input.length() > 1.0:
		input = input.normalized()

	# Velocity
	velocity.x = input.x * speed
	velocity.z = input.y * speed
	velocity.y = 0

	# Rotate toward movement
	if input.length() > 0.1:
		var target_angle: float = atan2(-input.x, -input.y)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

	move_and_slide()

	# --- Kick ---
	for body in kick_area.get_overlapping_bodies():
		if body is RigidBody3D and body.name == "Ball":
			var force = kick_force
			if Input.is_action_pressed(hard_kick_action):
				force *= hard_kick_multiplier

			# Call the ball's assisted kick function
			body.apply_player_kick(force, global_position)
			body.player_assist = player_assist  # sync slider/easiness
