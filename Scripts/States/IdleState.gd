extends State
class_name IdleState

func _ready():
	print("idle")
	idle()

func idle():
	animation.play("Idle")
		
		
func exit():
	print ("Exit Idle State")
