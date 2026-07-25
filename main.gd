extends Node

@export var pipe_scene : PackedScene

var game_running : bool = false
var game_over : bool = false
var scrool : int = 0
var score : int = 0
const SCROOL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200


func _ready():
	screen_size = get_window().size
	ground_height = 168
	new_game()

func new_game():
	get_tree().paused = false

	game_running = false
	game_over = false
	score = 0
	scrool = 0
	$ScoreLabel.text = "SCORE: " + str(score)
	$Gameover.hide()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()

	generate_pipes()
	$Bird.reset()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Bird.flying:
						$Bird.flap()
						check_top()
	elif event.is_action_pressed("ui_accept"):
		if game_running == false:
			start_game()
	else:
		if $Bird.flying:
			$Bird.flap()
			check_top()
			
func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()

func _process(_delta):
	if game_running:
		scrool += SCROOL_SPEED
	if scrool >= screen_size.x:
			scrool = 0

			$ground/Sprite2D.position.x = -scrool

	for pipe in pipes:
				pipe.position.x -= SCROOL_SPEED


func _on_pipe_timer_timeout() -> void:
	generate_pipes()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2.0 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child.call_deferred(pipe)
	pipes.append(pipe)
	
func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)

func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$Gameover.show()
	$Bird.flying = false
	game_running = false
	game_over = true
	get_tree().paused = true
	
func bird_hit():
	$Bird.falling = true
	stop_game()

func _on_ground_hit() -> void:
	$Bird.falling = false
	stop_game()


func _on_gameover_visibility_changed() -> void:
	new_game()
