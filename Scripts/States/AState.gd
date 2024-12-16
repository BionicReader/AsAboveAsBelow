extends State
class_name AState

@onready var boss = $"."
@onready var coll2d = $CollisionShape2D
@onready var playerD = $PlayerDetect
@onready var meleeD = $MeleePlayerDetect
@onready var shootD = $ShootPlayerDetector

func _ready():
	atk()

func atk():
	# Play the animations for attack
	animation.play("Shoot")
	animation.play("ShootBody")

func exit():
	print("Exit attack state")

