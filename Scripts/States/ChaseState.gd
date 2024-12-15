extends State
class_name ChaseState

func _ready():
	# Ensure the parent State setup is called before accessing main_body
	if not main_body:
		return

func idle():
	if main_body:
		main_body.play("Run")
	else:
		print("null")
