extends State
class_name DefenseState

@onready var boss = $"."

func _ready():
	print("defend")
	atk()

func atk():
	animation.play("Attack")

func exit():
	print ("Exit defense state")
