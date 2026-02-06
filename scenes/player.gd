extends CharacterBody2D

# Set the movement speed in pixels per second
const SPEED = 400
var gravity = 9800
func _physics_process(delta):
	# Get a vector representing the directional input from the actions defined earlier
	var direction = Input.get_vector("a", "d", "w", "s")

	# Set the character's velocity based on the input direction and speed
	velocity = direction * SPEED
	
	velocity.y += gravity * delta
	# Move the character and handle collisions
	move_and_slide()
