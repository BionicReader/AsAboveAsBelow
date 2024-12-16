extends CharacterBody2D

# Movement constants
var SPEED = 800.0  # Increased base speed
const JUMP_FORCE = 1000.0
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
const FRICTION = 0.1  # Add friction to stop sliding
const ACCELERATION = 0.25  # Smooth acceleration

# State tracking
enum PlayerForm { NORMAL, BEAST }
var current_form = PlayerForm.NORMAL

# Action tracking
var is_performing_action = false
var is_moving = false
var is_jumping = false

var hit = false
var is_input_blocked = false
var health

# Node references
@onready var sword = $Sword/sword
@onready var move_area = $MoveArea
@onready var player_normal = $PlayerNorm
@onready var player_beast = $Powered
@onready var change_anim = $Change
@onready var death_anim = $PlayerDeath
@onready var attack_anim = $PlayerAttack
@onready var ground_ray = $groundRay
@onready var change_timer = $ChangeAwait
@onready var healthbar = $HealthBar

func _ready():
	health = 100
	healthbar.init_health(health)

func _physics_process(delta):
	if is_input_blocked == false:
		# Check if just landed
		if is_jumping and ground_ray.is_colliding():
			is_jumping = false
			# Reset to idle or run animation based on movement
			if abs(velocity.x) < 10:  # Almost stationary
				player_normal.play("Idle")
			else:
				player_normal.play("Run")

		# Rest of the existing _physics_process remains the same
		# Handle gravity for all forms when not grounded
		if not ground_ray.is_colliding():
			velocity.y += GRAVITY * delta

		# Get input
		var input_vector = get_input_vector()

		# Always allow horizontal movement, even when jumping
		handle_ground_movement(input_vector, delta)

		# Handle jumping
		handle_jump(input_vector)

		# Handle actions
		handle_actions()

		# Determine if character should be idle
		update_animation_state()

		# Move the character
		move_and_slide()
	else:
		return

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
		if ground_ray.is_colliding() and not hit:
			player_normal.play("Idle")

func handle_jump(input_vector: Vector2):
	var jump_pressed = Input.is_action_just_pressed("jump")
	
	# Jumping logic with air control
	if jump_pressed and current_form != PlayerForm.BEAST:
		if ground_ray.is_colliding():
			perform_jump()

	# Air control (allow horizontal movement when jumping)
	if is_jumping and not ground_ray.is_colliding():
		# Reduce air control speed (optional)
		var air_control_speed = SPEED * 0.7
		velocity.x = input_vector.x * air_control_speed

func update_movement_animation(direction: float):
	if current_form != PlayerForm.BEAST:
		SPEED = 600.0
		if not is_jumping:
			player_normal.play("Run")
	else:
		SPEED = 200.0
		if not is_jumping:
			player_beast.play("WalkState")
		is_moving = true
	
	# Flip character and attached objects
	player_normal.scale.x = 1 * sign(direction)
	player_beast.scale.x = 0.7 * sign(direction)
	$TailDown.scale.x = 1 * sign(direction)
	$Sword.scale.x = 1 * sign(direction)

func perform_jump():
	is_jumping = true
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
@onready var tail_side_2_timer = $TailSide2
@onready var tailD = $TailDown/tailD
@onready var tailSide = $TailSide/tailSide

# Track active actions to prevent interference
var is_tail_down_active = false
var is_tail_side_active = false

func handle_beast_actions():
	if Input.is_action_pressed("hitR"):
		player_beast.play("BreakSide")
		player_beast.scale.x = 0.75
		$TailSide.scale.x = 1
		player_normal.scale.x = 1
		$Sword.scale.x = 1
		is_performing_action = true
		var tailD_timer = get_tree().create_timer(0.3) # Adjust duration as needed
		tailD_timer.timeout.connect(func():
			tailSide.disabled = false
			var power_timer = get_tree().create_timer(0.5) # Adjust duration as needed
			power_timer.timeout.connect(func():
				tailSide.disabled = true
			)
		)
	elif Input.is_action_pressed("hitL"):
		player_beast.play("BreakSide")
		player_beast.scale.x = -0.75
		$TailSide.scale.x = -1
		player_normal.scale.x = -1
		$Sword.scale.x = -1
		is_performing_action = true
		var tailD_timer = get_tree().create_timer(0.3) # Adjust duration as needed
		tailD_timer.timeout.connect(func():
			tailSide.disabled = false
			var power_timer = get_tree().create_timer(0.5) # Adjust duration as needed
			power_timer.timeout.connect(func():
				tailSide.disabled = true
			)
		)
	elif Input.is_action_pressed("hitD"):
		player_beast.play("BreakDown")
		is_performing_action = true
		var tailD_timer = get_tree().create_timer(0.3) # Adjust duration as needed
		tailD_timer.timeout.connect(func():
			tailD.disabled = false
			var power_timer = get_tree().create_timer(0.5) # Adjust duration as needed
			power_timer.timeout.connect(func():
				tailD.disabled = true
			)
		)


# Monitor input release for cleanup
func _process(delta):
	healthbar.health = health
	if healthbar.health == 0:
		die()
	
	if Input.is_action_just_released("hitD"):
		tailD.disabled = true
	elif Input.is_action_just_released("hitR") or Input.is_action_just_released("hitL"):
		print("done")
		tailSide.disabled = true
	return
	
func handle_normal_actions():
	if Input.is_action_just_pressed("attack"):
		# Stop if already performing an action
		
		attack_anim.visible = true
		player_normal.visible = false
		print("attack")
		attack_anim.play("Attack")
		sword.disabled = false
		
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
			sword.disabled = true
			# Reset position after attack
			attack_anim.position.x = 0
		)

func update_animation_state():
	# Only go to idle if no actions, no movement, and no jumping
	if not is_performing_action and not is_moving and not is_jumping and not hit:
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
		
func _on_tail_side_body_entered(body):
	if body is BreakableTile:
		body.break_tile()

func _on_core_area_entered(area):
	if health > 0:  # Ensure positive health
		if area.name == "Bullet":
			hit = true
			health -= 5  # More idiomatic way to reduce health
			player_normal.play("Hit")
			print("bullet")
		elif area.name == "Swish":
			hit = true
			health -= 10
			player_normal.play("Hit")
			print("swish")
		
		# Only die if health reaches 0
		if health <= 0:
			die()
	else:
		die()

func die():
	if current_form == PlayerForm.BEAST:
		player_beast.visible = false
	player_normal.visible = false
	$Core/core.disabled = true
	is_input_blocked = true
	var die_timer = get_tree().create_timer(0.01)  # Adjust duration as needed
	die_timer.timeout.connect(func():
		$PlayerDeath.visible = true
		$PlayerDeath.play("Death")
		var death_timer = get_tree().create_timer(0.9)  # Adjust duration as needed
		death_timer.timeout.connect(func():
			self.queue_free()
		)
	)

func _on_core_area_exited(area):
	hit = false
