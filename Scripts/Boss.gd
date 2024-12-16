extends CharacterBody2D

const SPEED = 10

@onready var attackAni = $Attack
@onready var die = $Die
@onready var main_body = $MainBody
@onready var shootAni = $Shoot
@onready var shoot_body = $ShootBody

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var state
var state_factory

var chase = false
var defense = false
var attack = false

var dead = false

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
	if shootAni != null:
		if attack == false:
			shootAni.visible = false
			shoot_body.visible = false
			main_body.visible = true
		elif attack == true:
			shootAni.visible = true
			shoot_body.visible = true
			main_body.visible = false

func _on_player_detect_body_entered(body):
	if body.name == "Hero" and ! dead:
		chase = true
		attack = false
		defense = false
		change_state("chase")
		
func _on_player_detect_body_exited(body):
	if body.name == "Hero" and !dead:
		chase = false
		attack = false
		defense = false
		change_state("idle")


func _on_melee_player_detect_body_entered(body):
	if body.name == "Hero" and !dead:
		defense = true
		main_body.visible = false
		attackAni.visible = true
		chase = false
		attack = false
		change_state("defense")


func _on_melee_player_detect_body_exited(body):
	if body.name == "Hero" and !dead:
		$Shoot/Bullet/bullet.disabled = true
		defense = false
		main_body.visible = true
		attackAni.visible = false
		chase = false
		attack = false
		change_state("idle")


func _on_shoot_player_detector_body_entered(body):
	if body.name == "Hero" and !dead:
		$AnimationPlayer.play("Bullet")
		defense = false
		chase = false
		attack = true
		change_state("attack")


func _on_shoot_player_detector_body_exited(body):
	if body.name == "Hero" and !dead:
		$AnimationPlayer.stop()
		defense = false
		chase = true
		attack = false
		change_state("chase")
		$Shoot/Bullet/bullet.disabled = true


func flip():
	$AnimationPlayer.play("Flip")

func reset():
	$AnimationPlayer.play("RESET")

func _on_melee_player_detect_area_entered(area):
	if area.name == "Sword":
		change_state("die")
		shootAni.stop()
		$MainBody.visible = false
		$Shoot.visible = false
		$Attack.visible = false
		dead = true
		die.visible = true
		die.play("Die")
		var death_timer = get_tree().create_timer(2.0)  # Adjust duration as needed
		death_timer.timeout.connect(func():
			self.queue_free()
		)
