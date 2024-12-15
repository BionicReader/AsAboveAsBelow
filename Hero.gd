extends Node2D

@onready var move_area = $MoveArea
@onready var player_states = $PlayerStates
@onready var pa = $PlayerAttack
@onready var pd = $PlayerDash

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("walkR"):  # Check if the "1" key is pressed
		pd.play("Dash")    # Play the first animation
		move_area.play("DashArea")
	elif Input.is_action_just_pressed("walkL"):  # Check if the "2" key is pressed
		player_states.play("BreakDown")    # Play the second animation
	elif Input.is_action_just_pressed("jump"):  # Check if the "3" key is pressed
		player_states.play("BreakSide")    # Play the third animation
	elif Input.is_action_just_pressed("change"):  # Check if the "4" key is pressed
		player_states.play("Dash")   # Play the fourth animation
	elif Input.is_action_just_pressed("hitR"):  # Check if the "5" key is pressed
		player_states.play("Die")   # Play the fifth animation
	elif Input.is_action_just_pressed("hitL"):  # Check if the "6" key is pressed
		player_states.play("Hit")    # Play the sixth animation
	elif Input.is_action_just_pressed("hitD"):  # Check if the "7" key is pressed
		player_states.play("Idle")    # Play the seventh animation
	elif Input.is_action_just_pressed("dash"):  # Check if the "8" key is pressed
		player_states.play("IdleState")   # Play the eighth animation
	elif Input.is_action_just_pressed("attack"):  # Check if the "9" key is pressed
		player_states.play("Jump")    # Play the ninth animation
