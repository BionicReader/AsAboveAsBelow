extends State
class_name DefenseState

func _ready():
	print("defense")
	atk()

func atk():
	animation.stop()
	animation.play("Attack")

func exit():
	print ("Exit defense state")
