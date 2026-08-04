extends CharacterBody2D

signal hit
const GRAVITY : int = 1000
const MAX_VEL : int = 600
const FLAP_SPEED : int = -350
const START_POS = Vector2(100, 400)

var flying: bool = false
var falling: bool = false

func _ready():
	reset()

func  reset():
	falling = true
	flying = false
	position = START_POS
	set_rotation(0)
	velocity = Vector2.ZERO


func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not flying:
			flying = true
			flap()
			
	if flying or falling:
		velocity.y += GRAVITY * delta
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
					
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
		
		move_and_slide()
	if get_slide_collision_count() > 0: die()
	if position.y>get_viewport_rect().size.y:
		die()
func flap():
	velocity.y = FLAP_SPEED
				

func die():
	emit_signal("hit")
	get_tree().paused = true
