extends CharacterBody3D

# Enum for difficulty dropdown
enum Difficulty { EASY, MEDIUM, HARD }

# Exports
@export var difficulty: Difficulty = Difficulty.MEDIUM
@export var ball: RigidBody3D
@export var player_goal: Node3D  # The player's goal AI will try to score into
@export var ai_goal: Node3D      # AI's own goal (for defensive logic)
@export var kick_area: Area3D    # Reference to AI's kick area

# Internal variables
var speed: float
var kick_force: float
var reaction_time: float
var timer: float = 0.0
var target_position: Vector3

func _ready() -> void:
	# Set AI parameters based on difficulty
	match difficulty:
		Difficulty.EASY:
			speed = 4.0
			kick_force = 5.0
			reaction_time = 0.6
		Difficulty.MEDIUM:
			speed = 8.0
			kick_force = 7.0
			reaction_time = 0.2
		Difficulty.HARD:
			speed = 15.0
			kick_force = 8.5
			reaction_time = 0.1
	target_position = global_position

func _physics_process(delta: float) -> void:
	if not ball:
		return

	# Update target position every reaction_time
	timer -= delta
	if timer <= 0.0:
		timer = reaction_time
		# Add slight randomness to make AI human-like
		var random_offset = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
		target_position = ball.global_position + random_offset

	# Smooth movement toward target
	var direction: Vector3 = (target_position - global_position).normalized()
	var move_velocity: Vector3 = direction * speed
	velocity.x = lerp(velocity.x, move_velocity.x, 0.2)
	velocity.z = lerp(velocity.z, move_velocity.z, 0.2)
	velocity.y = 0

	# Smooth rotation toward movement
	if direction.length() > 0.1:
		var target_angle: float = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 0.2)

	move_and_slide()

	# Kick ball if close
	for body in kick_area.get_overlapping_bodies():
		if body is RigidBody3D and body.name == "Ball":
			var kick_dir: Vector3 = (player_goal.global_position - body.global_position).normalized()

			# Add slight deviation for humanized kick
			var deviation = Vector3(randf_range(-0.2, 0.2), 0, randf_range(-0.2, 0.2))
			kick_dir = (kick_dir + deviation).normalized()

			# Kick accuracy based on difficulty
			var accuracy: float = 1.0
			match difficulty:
				Difficulty.EASY:
					accuracy = randf_range(0.7, 0.9)
				Difficulty.MEDIUM:
					accuracy = randf_range(0.85, 1.0)
				Difficulty.HARD:
					accuracy = randf_range(0.9, 1.0)

			# Random chance for hard kick
			var hard_kick_chance: float
			match difficulty:
				Difficulty.EASY:
					hard_kick_chance = 0.2
				Difficulty.MEDIUM:
					hard_kick_chance = 0.5
				Difficulty.HARD:
					hard_kick_chance = 0.8

			var force = kick_force * accuracy
			if randf() < hard_kick_chance:
				force *= 1.5  # AI performs a stronger kick

			body.linear_velocity = kick_dir * force
