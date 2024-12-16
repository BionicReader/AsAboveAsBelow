extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var shootAni = $Shoot
@onready var die = $Die

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var state
var state_factory

var chase = false
var defense = false
var attack = false

func _ready():
	state_factory = StateFactory.new()
	change_state("idle")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func change_state(new_state_name):
	if state != null:
		state.exit()
		state.queue_free()
	state = state_factory.get_state(new_state_name).new()
	state.setup("change_state", $MainBody, self)
	state.name = "current_state"
	add_child(state)
	
func _process(delta):
	if attack == false:
		shootAni.visible = false
	elif attack == true:
		shootAni.visible = true

func _on_player_detect_body_entered(body):
	if body.name == "Hero":
		chase = true
		attack = false
		defense = false
		change_state("chase")
		
func _on_player_detect_body_exited(body):
	if body.name == "Hero":
		chase = false
		attack = false
		defense = false
		change_state("idle")


func _on_melee_player_detect_body_entered(body):
	if body.name == "Hero":
		defense = true
		chase = false
		attack = false
		change_state("defense")

func _on_melee_player_detect_body_exited(body):
	if body.name == "Hero":
		defense = false
		chase = false
		attack = false
		change_state("idle")


func _on_shoot_player_detector_body_entered(body):
	if body.name == "Hero":
		defense = false
		chase = false
		attack = true
		change_state("attack")


func _on_shoot_player_detector_body_exited(body):
	if body.name == "Hero":
		defense = false
		chase = true
		attack = false
		change_state("chase")
