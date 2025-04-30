#golfclub.gd
extends Node3D

@export var swing_speed: float = 5.0
@export var max_swing_angle: float = 120.0  # in degrees
@export var reset_speed: float = 5.0
@export var hit_force: float = 3.0  # Force applied to ball when hit
@export var putt_force: float = 1.0  # Half the force for putting
@export var drive_force: float = 6.0
@export var club_offset: Vector3 = Vector3(0.15, -0.1, 0)  # Adjust based on player width

var is_swinging: bool = false
var swing_complete: bool = false
var current_swing_angle: float = 0.0
var swing_basis: Basis  # Store the starting basis for the swing
var hit_this_swing: bool = false
var is_putting: bool = false  # New variable to track if we're putting
var is_driving: bool = false
var is_returning: bool = false

@onready var player = get_parent()
@onready var camera = player.get_node("CameraController/Camera3D")
@onready var club_head_area = $Area3D  # Reference to your existing Area3D node

func _ready():
	# Set up collision layer
	for child in get_children():
		if child is CollisionShape3D:
			child.collision_layer = 8  # Layer 4 for GolfClub
			child.collision_mask = 4   # Layer 3 for Ball
	
	rotate_object_local(Vector3(0, 1, 0), deg_to_rad(-90))
	
	# Connect the area signals from Area3D
	club_head_area.connect("area_entered", Callable(self, "_on_area_entered"))
	club_head_area.connect("body_entered", Callable(self, "_on_body_entered"))
	
func _process(delta):
	# Always align with camera direction when not swinging
	if !is_swinging:
		align_with_camera()
		
	if Input.is_action_just_pressed("swing") or Input.is_action_just_pressed("putt") or Input.is_action_just_pressed("drive"):
		if is_swinging:
			return
		# Start the swing
		is_swinging = true
		swing_complete = false
		hit_this_swing = false
		current_swing_angle = 0.0
		# Store current orientation as the base for our swing
		swing_basis = global_transform.basis
		# Check if we're putting
		is_putting = Input.is_action_just_pressed("putt")
		is_driving = Input.is_action_just_pressed("drive")
	
		var overlapping_areas = club_head_area.get_overlapping_areas()
		var overlapping_bodies = club_head_area.get_overlapping_bodies()
			
		for area in overlapping_areas:
			if area.is_in_group("golf_ball"):
				hit_ball(area)
				break  # Break after first hit to prevent multiple hits
			
		if !hit_this_swing:  # Only check bodies if we haven't hit an area yet
			for body in overlapping_bodies:
				if body.is_in_group("golf_ball"):
					hit_ball(body)
					break
	
	if is_swinging:
		if !swing_complete:
			is_returning = false
			# Forward swing
			current_swing_angle += swing_speed * delta * 75.0
			
			if current_swing_angle >= max_swing_angle:
				swing_complete = true
				
			# Apply rotation around local x-axis (adjust as needed)
			var swing_rotation = Basis(Vector3(0, 0, 1), deg_to_rad(-current_swing_angle))
			global_transform.basis = swing_basis * swing_rotation
		else:
			is_returning = true
			# Return to original position
			current_swing_angle -= reset_speed * delta * 75.0
			if current_swing_angle <= 0:
				current_swing_angle = 0
				is_swinging = false
				align_with_camera()
			else:
				var swing_rotation = Basis(Vector3(0, 0, 1), deg_to_rad(-current_swing_angle))
				global_transform.basis = swing_basis * swing_rotation

func align_with_camera():
	# Get camera forward direction (negative z)
	var camera_forward = -camera.global_transform.basis.z
	camera_forward.y = 0  # Keep club level with ground
	camera_forward = camera_forward.normalized()
	
	# Position club with offset based on camera direction
	var offset_rotated = camera.global_transform.basis * club_offset
	global_position = player.global_position + offset_rotated
	
	# Look in camera direction
	if camera_forward.length() > 0.1:  # Ensure we have a valid direction
		look_at(global_position + camera_forward, Vector3.UP)
		rotate_object_local(Vector3(0, 1, 0), deg_to_rad(-90)) # Rotate the paddle outward

func _on_area_entered(area):
	if is_swinging and !is_returning and !hit_this_swing and area.is_in_group("golf_ball"):
		hit_ball(area)

func _on_body_entered(body):
	if is_swinging and !is_returning and !hit_this_swing and body.is_in_group("golf_ball"):
		hit_ball(body)

func hit_ball(ball):
	print("hit ball @ ", ball.global_position)
	hit_this_swing = true
	StatsManager.record_stroke()
	CheckpointManager.set_checkpoint(ball.global_position)

	var direction = (ball.global_position - global_position).normalized()
	direction.y += 0.1  # Add loft
	direction = direction.normalized()
	
	# Apply force based on whether we're putting or swinging
	var force
	if is_putting:
		force = putt_force
	elif is_driving:
		force = drive_force
	else:
		force = hit_force
	# Apply force to the ball
	if ball.has_method("apply_central_impulse"):
		ball.apply_central_impulse(direction * force)
