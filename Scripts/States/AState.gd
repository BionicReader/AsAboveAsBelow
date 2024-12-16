extends State
class_name AState

func _ready():
	pass

func Shoot():
	animation.play("shoot")
	#animation.play

func exit():
	print ("Exit Attack State")
