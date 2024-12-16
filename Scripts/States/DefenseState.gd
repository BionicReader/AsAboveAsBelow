extends State
class_name DefenseState

func _ready():
	atk()

func atk():
	animation.play("Attack 1")

func exit():
	print ("Exit defense state")
