#golfball.gd
extends RigidBody3D

var max_height_from_ground = 0.5
var return_force = 5.0
var wall_detection_distance = 0.1
var wall_push_force = 0.2
var ray_cast_down: RayCast3D
var ray_casts: Array[RayCast3D] = []
var ray_directions = [
	Vector3(1, 0, 0),
	Vector3(-1, 0, 0),
	Vector3(0, 0, 1),
	Vector3(0, 0, -1),
]

func _ready():
	# Set initial respawn point
	if CheckpointManager.respawn_position == Vector3.ZERO:
		CheckpointManager.set_checkpoint(global_position)
		
	contact_monitor = true
	max_contacts_reported = 4
	continuous_cd = true
	can_sleep = true
	add_to_group("golf_ball")
	
	mass = 0.5
	linear_damp = 1.0
	angular_damp = 1.0
	setup_raycasts()

func setup_raycasts():
	# Create downward raycast
	ray_cast_down = RayCast3D.new()
	ray_cast_down.name = "RayCastDown"
	ray_cast_down.target_position = Vector3(0, -10, 0)
	ray_cast_down.enabled = true
	add_child(ray_cast_down, true)
	ray_cast_down.top_level = true
	
	# Create horizontal raycasts
	for i in range(ray_directions.size()):
		var ray = RayCast3D.new()
		ray.name = "RayCastWall" + str(i)
		ray.target_position = ray_directions[i] * wall_detection_distance
		ray.enabled = true
		add_child(ray, true)
		ray.top_level = true
		ray_casts.append(ray)

func _physics_process(_delta):
	update_raycast_positions()
	check_ground_distance()
	check_wall_collisions()

func update_raycast_positions():
	# Update downward raycast
	if ray_cast_down:
		ray_cast_down.global_position = global_position
		ray_cast_down.global_rotation = Vector3.ZERO
	
	# Update horizontal raycasts
	for i in range(ray_casts.size()):
		if ray_casts[i]:
			ray_casts[i].global_position = global_position
			# Keep their original directions
			ray_casts[i].target_position = ray_directions[i] * wall_detection_distance

func check_ground_distance():
	if ray_cast_down.is_colliding():
		var collision_point = ray_cast_down.get_collision_point()
		var height_from_ground = global_position.y - collision_point.y
		
		# If ball is too high above ground, apply a force to bring it back
		if height_from_ground > max_height_from_ground:
			var force = Vector3(0, -return_force * (height_from_ground - max_height_from_ground), 0)
			apply_central_force(force)

func check_wall_collisions():
	for i in range(ray_casts.size()):
		if ray_casts[i].is_colliding():
			var collision_point = ray_casts[i].get_collision_point()
			var distance_to_wall = global_position.distance_to(collision_point)
			
			# If too close to wall, push away
			if distance_to_wall < wall_detection_distance:
				# Calculate push direction (away from wall)
				var push_direction = -ray_directions[i]
				var push_strength = wall_push_force * (1.0 - distance_to_wall/wall_detection_distance)
				var force = push_direction * push_strength
				apply_central_force(force)
