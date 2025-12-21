extends CharacterBody3D

@export_category("Player Movement")
@export var speed := 5.0
@export var jump_velocity := 4.5
const ROTATION_SPEED := 6.0

#slowly rotate the charcter to point in the direction of the camera_pivot
@onready var camera_pivot : Node3D = $camera_pivot
@onready var playermodel : Node3D = $playermodel

enum animation_state {IDLE,RUNNING,JUMPING}
var player_animation_state : animation_state = animation_state.IDLE
@onready var animation_player : AnimationPlayer = $"playermodel/character-male-e2/AnimationPlayer"



# Kicking
@export var kick_force: float = 6.0
@export var hard_kick_multiplier: float = 1.5
@export var player_assist: float = 0.5  # 0 = no assistance, 1 = full assist

# Node references
@onready var kick_area: Area3D = $Kick_area
@export var ai_goal: Node3D  # assign in Inspector
@export var hard_kick_action: String = "hard_kick"  # input map action







func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		#player_animation_state = animation_state.JUMPING
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (camera_pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		#now rotate the model
		rotate_model(direction, delta)
		player_animation_state = animation_state.RUNNING
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		player_animation_state = animation_state.IDLE
	
	if not is_on_floor():
		player_animation_state = animation_state.JUMPING
	
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






func rotate_model(direction: Vector3, delta : float) -> void:
	#rotate the model to match the springarm
	playermodel.basis = lerp(playermodel.basis, Basis.looking_at(direction), 10.0 * delta)
