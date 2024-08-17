extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var camera_2d = $Camera2D
var GRAVITY = 1000
const SPEED = 300
@export var speed :int = 300

@export var jump = -300

@export var jump_horizontal = 100
@export var dash_speed = 1000
@export var dash_duration = 0.2 # Duration of the dash in seconds
@export var dash_cooldown = 1.0 # Cooldown period in seconds
var is_dashing = false
var dash_timer = 0
var dash_direction = 0


enum State { Idle, Run, Jump, Dash }

var current_state : State

func _ready():
	current_state = State.Idle

func _physics_process(delta:float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	player_dodge(delta)
	
	move_and_slide()
	player_animations()
	print("State: ", State.keys()[current_state])

func player_falling(delta:float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

@warning_ignore("unused_parameter")
func player_idle(delta):
	if is_on_floor():
		current_state = State.Idle

		
@warning_ignore("unused_parameter")
func player_run(delta:float):
	if is_on_floor():
		var direction = Input.get_axis("move_left", "move_right")

		if direction:
			velocity.x = direction * speed
			current_state = State.Run
			animated_sprite_2d.flip_h = false if direction > 0 else true
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			if current_state != State.Jump:
				current_state = State.Idle
				
func player_jump(delta:float):
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump
		current_state = State.Jump
		
	if !is_on_floor() and current_state == State.Jump:
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x += direction * jump_horizontal * delta
		
func player_dodge(delta:float):
	if Input.is_action_just_pressed("dash") and !is_dashing:
		dash_direction = Input.get_axis("move_left", "move_right")
		if dash_direction != 0:
			is_dashing = true
			dash_timer = dash_duration

	if is_dashing:
		velocity.y = 0
		if dash_direction > 0:
			velocity.x = dash_speed
		elif dash_direction <= 0:
			velocity.x = -dash_speed

		dash_timer -= delta

		# Check if the dash has ended
		if dash_timer <= 0:
			if dash_direction > 0:
				velocity.x = 100
		
			elif dash_direction <= 0:
				velocity.x = -100
				
			is_dashing = false
			#velocity.x = 0 # Remove this line if you want the character to keep its momentum



		
func player_animations():
	if current_state == State.Idle:
		animated_sprite_2d.play("Idle")
		
	elif current_state == State.Run and !is_dashing:
		animated_sprite_2d.play("Run")
		
	elif current_state == State.Jump:
		animated_sprite_2d.play("Jump")
		
	elif is_dashing:
		animated_sprite_2d.play("Dodge")
