extends State
class_name AState

func _ready():
	# Ensure the parent State setup is called before accessing main_body
	if not main_body:
		return

func idle():
	if main_body:
		main_body.play("Attack1")
	else:
		print("null")
