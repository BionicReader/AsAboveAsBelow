extends State
class_name AState

func _ready():
	atk()

func atk():
	# Play the animations for attack
	animation.play("Shoot")
	animation.play("ShootBody")

func exit():
	print("Exit attack state")

