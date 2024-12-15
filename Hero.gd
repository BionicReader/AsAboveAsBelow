extends CharacterBody2D

# Movement constants
var SPEED = 400.0  # Increased base speed
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
@onready var ground_ray = $groundRay
@onready var change_timer = $ChangeAwait

func _ready():
	# Initialize any startup logic if needed
	pass

func _physics_process(delta):
	# Reset state flags at start of frame
	is_moving = false
	is_performing_action = false

	# Handle gravity for all forms when not grounded
	if not ground_ray.is_colliding():
		velocity.y += GRAVITY * delta
	
	# Get input
	var input_vector = get_input_vector()
	
	# Apply movement
	if ground_ray.is_colliding():
		is_jumping = false
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
		is_jumping = true
		perform_jump()
 
func update_movement_animation(direction: float):
	if current_form != PlayerForm.BEAST:
		SPEED = 600.0
		player_normal.play("Run")
		player_normal.scale.x = sign(direction)
	else:
		SPEED = 200.0
		player_beast.play("WalkState")
		is_moving = true
		player_beast.scale.x = 0.7 * sign(direction)
		$TailDown.scale.x = 0.7 * sign(direction)
		
func perform_jump():
	is_jumping = true
	if ground_ray.is_colliding():
		print("Jump")
		player_normal.play("Jump")
		velocity.y = -JUMP_FORCE

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
	
# Declare the tail timer
@onready var tail_cooldown_timer = $TailDelay
func handle_beast_actions():
	# Prioritize attack/hit actions
	if !is_moving:
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
			handle_tail()

# Separate function to handle tail logic and start cooldown timer
func handle_tail():
	if tail_cooldown_timer.is_stopped():
		tail_cooldown_timer.start() # Start the cooldown timer
		$TailDown/tailD.disabled = true
# Handle the release of the button outside of the timer logic
func _process(delta):
	if Input.is_action_just_released("hitD"):
		$TailDown/tailD.disabled = true
		tail_cooldown_timer.stop()
		
func _on_tail_delay_timeout():
	$TailDown/tailD.disabled = false
	handle_tail()
	
func handle_normal_actions():
	if Input.is_action_just_pressed("attack"):
		# Stop if already performing an action
		if is_performing_action:
			return
		
		attack_anim.visible = true
		player_normal.visible = false
		print("attack")
		attack_anim.play("Attack")
		
		# Flip based on the last direction of the normal player
		attack_anim.scale.x = -player_normal.scale.x
		
		# Adjust position based on facing direction
		if player_normal.scale.x > 0:  # Facing right
			attack_anim.position.x = 38
		else:  # Facing left
			attack_anim.position.x = -38
		
		is_performing_action = true
		
		# Create a timer to handle attack duration and reset
		var attack_timer = get_tree().create_timer(0.5)  # Adjust duration as needed
		attack_timer.timeout.connect(func():
			attack_anim.visible = false
			player_normal.visible = true
			is_performing_action = false
			# Reset position after attack
			attack_anim.position.x = 0
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




# Break Tile Logic
func _on_tail_down_body_entered(body: Node):
	if body is BreakableTile:
		body.break_tile()

