extends CharacterBody2D

# Movement constants
const SPEED = 300.0  # Increased base speed
const JUMP_FORCE = 800.0
const GRAVITY = 2000.0
const FRICTION = 0.1  # Add friction to stop sliding
const ACCELERATION = 0.25  # Smooth acceleration

# State tracking
enum PlayerForm { NORMAL, BEAST }
var current_form = PlayerForm.NORMAL

# Action tracking
var is_performing_action = false
var is_moving = false
var is_jumping = false

# Node references
@onready var move_area = $MoveArea
@onready var player_normal = $PlayerNorm
@onready var player_beast = $Powered
@onready var change_anim = $Change
@onready var death_anim = $PlayerDeath
@onready var attack_anim = $PlayerAttack
@onready var dash_anim = $PlayerDash
@onready var ground_ray = $groundRay
@onready var change_timer = $ChangeAwait

func _ready():
	# Initialize any startup logic if needed
	pass

func _physics_process(delta):
	# Reset state flags at start of frame
	is_moving = false
	is_performing_action = false
	is_jumping = false

	# Handle gravity
	if current_form != PlayerForm.BEAST and not ground_ray.is_colliding():
		velocity.y += GRAVITY * delta
	
	# Get input
	var input_vector = get_input_vector()
	
	# Apply movement
	if ground_ray.is_colliding():
		handle_ground_movement(input_vector, delta)
	
	# Handle actions
	handle_actions()
	
	# Determine if character should be idle
	update_animation_state()
	
	# Move the character
	move_and_slide()

func get_input_vector() -> Vector2:
	# Gather input as a vector for more flexible movement
	return Vector2(
		Input.get_axis("walkL", "walkR"),  # Horizontal movement
		0  # Vertical movement (jump handled separately)
	)

func handle_ground_movement(input_vector: Vector2, delta: float):
	# Smooth acceleration and deceleration
	if input_vector.x != 0:
		# Accelerate when moving
		velocity.x = move_toward(
			velocity.x, 
			input_vector.x * SPEED, 
			SPEED * ACCELERATION
		)
		
		# Mark as moving
		is_moving = true
		
		# Update animations and direction
		update_movement_animation(input_vector.x)
	else:
		# Apply friction to stop sliding
		velocity.x = move_toward(velocity.x, 0, SPEED * FRICTION)
	
	# Handle jumping
	if Input.is_action_just_pressed("jump") and current_form != PlayerForm.BEAST:
		perform_jump()

func update_movement_animation(direction: float):
	if current_form != PlayerForm.BEAST:
		player_normal.play("Run")
		player_normal.scale.x = sign(direction)
	else:
		player_beast.play("WalkState")
		player_beast.scale.x = 0.7 * sign(direction)

func perform_jump():
	print("Jump")
	is_jumping = true
	if ground_ray.is_colliding():
		player_normal.play("Jump")
		velocity.y = -JUMP_FORCE
		is_jumping = true

func handle_actions():
	# Form change
	if Input.is_action_just_pressed("change"):
		initiate_form_change()
		return
	
	# Prioritize action animations based on current form
	if current_form == PlayerForm.BEAST:
		handle_beast_actions()
	else:
		handle_normal_actions()

func initiate_form_change():
	change_anim.play("Change")
	print("Form change initiated")
	change_timer.start()
	is_performing_action = true

func handle_beast_actions():
	# Prioritize attack/hit actions
	if Input.is_action_pressed("hitR"):
		player_beast.play("BreakSide")
		player_beast.scale.x = 0.75
		is_performing_action = true
	elif Input.is_action_pressed("hitL"):
		player_beast.play("BreakSide")
		player_beast.scale.x = -0.75
		is_performing_action = true
	elif Input.is_action_pressed("hitD"):
		player_beast.play("BreakDown")
		is_performing_action = true

func handle_normal_actions():
	if Input.is_action_just_pressed("dash"):
		handle_dash()
	elif Input.is_action_pressed("attack"):
		attack_anim.play("Attack")
		is_performing_action = true

func handle_dash():
	# Stop if already dashing
	if is_performing_action:
		return
	
	dash_anim.visible = true
	player_normal.visible = false
	print("dash")
	dash_anim.play("Dash")
	is_performing_action = true
	
	# Create a timer to handle dash duration and reset
	var dash_timer = get_tree().create_timer(0.5)  # Adjust duration as needed
	dash_timer.timeout.connect(func():
		dash_anim.visible = false
		player_normal.visible = true
		is_performing_action = false
	)

func update_animation_state():
	# Only go to idle if no actions, no movement, and no jumping
	if not is_performing_action and not is_moving and not is_jumping:
		if current_form != PlayerForm.BEAST:
			player_normal.play("Idle")
		else:
			player_beast.play("IdleState")

func _on_change_await_timeout():
	# Toggle form
	current_form = PlayerForm.NORMAL if current_form == PlayerForm.BEAST else PlayerForm.BEAST
	
	# Update visibility and animations
	if current_form == PlayerForm.BEAST:
		player_normal.visible = false
		player_beast.visible = true
		player_beast.play("IdleState")
		print("Switched to Beast form")
	else:
		player_beast.visible = false
		player_normal.visible = true
		player_normal.play("Idle")
		print("Switched to Original form")
