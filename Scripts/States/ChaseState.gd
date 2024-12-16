extends State
class_name ChaseState

const SPEED = 500.0

func _ready():
	print("chase")
	chase_H()

func _physics_process(delta):
	# Use get_tree().get_root() to search from the root of the scene
	var hero = get_tree().get_root().find_child("Hero", true, false)
	var Boss = get_parent()
	
	if hero and Boss.chase == true:
		var direction = (hero.position - Boss.position).normalized()
		
		# Flip sprites using scale
		if direction.x > 0:
			Boss.reset()
		else:
			Boss.flip()
				
		Boss.velocity.x = direction.x * SPEED
	
	elif Boss.attack == true:
		Boss.velocity.x = 0
		Boss.change_state("attack")
		print("must find")
	else:
		print("where are you!?!")
		Boss.velocity.x = 0
		Boss.change_state("idle")

func chase_H():
	animation.play("Run")

func exit():
	print ("Exit Chase State")
