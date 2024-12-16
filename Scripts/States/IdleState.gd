extends State
class_name IdleState

func _ready():
	pass

func idle():
	if main_body:
		main_body.play("Idle")
	else:
		print("null")
		
		
func exit():
	print ("Exit Idle State")
