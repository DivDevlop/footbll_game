extends RigidBody3D

@export_range(0.0, 1.0, 0.01) var player_assist: float = 0.5
@export var ai_goal: Node3D
@export var avoid_radius: float = 2.0  # distance to detect nearby AI
@export var ai_group_name: String = "AI"  # put all AI in this group

func apply_player_kick(force: float, player_pos: Vector3) -> void:
	# Base direction from player to ball
	var dir: Vector3 = (global_position - player_pos).normalized()
	
	# Assist toward goal
	var goal_dir: Vector3 = (ai_goal.global_position - global_position).normalized()
	var final_dir: Vector3 = dir.lerp(goal_dir, player_assist).normalized()
	
	# Check for nearby AI
	var closest_ai: Node3D = null
	var min_dist: float = avoid_radius
	for ai in get_tree().get_nodes_in_group(ai_group_name):
		var d = ai.global_position.distance_to(global_position)
		if d < min_dist:
			min_dist = d
			closest_ai = ai
	
	# If AI is very close, adjust kick left or right randomly
	if closest_ai:
		var side_offset = Vector3()
		# Randomly choose left or right relative to goal direction
		if randf() < 0.5:
			side_offset = Vector3(-goal_dir.z, 0, goal_dir.x)  # perpendicular left
		else:
			side_offset = Vector3(goal_dir.z, 0, -goal_dir.x)  # perpendicular right
		# Small offset so ball avoids AI
		final_dir = (final_dir + side_offset.normalized() * 0.5).normalized()
	
	# Small random offset for natural feel
	var random_offset = Vector3(randf_range(-0.05, 0.05), 0, randf_range(-0.05, 0.05))
	final_dir = (final_dir + random_offset).normalized()
	
	# Apply velocity
	linear_velocity = final_dir * force
