extends State
class_name AState

@onready var boss = $"."

func _ready():
	atk()

func atk():
	animation.play("Shoot")
	animation.play("ShootBody")
	get_tree().create_timer(0.5).timeout
	boss.position.x += 100

func exit():
	print ("Exit attack state")
