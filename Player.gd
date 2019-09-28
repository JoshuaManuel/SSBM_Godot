extends KinematicBody2D

const DEADZONE = 0.2

const UP = Vector2(0,-1)
export var GRAVITY = 800
export var TOP_SPEED = 300
export var DASH_SPEED = 500

export var GROUND_LERP = 0.1
export var AIR_LERP = 0.02

export var JUMP_HEIGHT = 300
export var AIR_JUMPS = 1 # infinite double jumps!
export var SHIELD_THRESH = 0.7
export var AIRDODGE_SPEED = 300
export var FRICTION = 0.8


const FASTFALL_THRESH = 100
export var FASTFALL_SPEED = 400


var jump_counter = AIR_JUMPS
var motion = Vector2(0,0)

var apply_gravity = true
var cancel_motion = false


var input_queue = []
var INPUT_QUEUE_LENGTH = 20

# RELOAD IF INPUT MAP CHANGES!!!!
var actions = InputMap.get_actions()

func _ready():
	print(actions)
	print(" ")
	print(" ")
	

func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		print(input_queue)
	if Input.is_action_just_pressed("ui_accept"):
		input_queue = []
	
	if apply_gravity:
		motion.y += delta * GRAVITY
	
	# horizontal measurement of left stick
	var move_horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var move_vertical = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var move_direction = Vector2(move_horizontal, move_vertical).normalized()
	
	motion.x = lerp(motion.x, TOP_SPEED * move_direction.x, get_lerp_value())
	
	if is_on_floor():
		# Jumps
		jump_counter = AIR_JUMPS
		if Input.is_action_just_pressed("jump"):
			motion.y = -JUMP_HEIGHT
		 
		# Gravity
		apply_gravity = true
	else:
		if Input.is_action_just_pressed("jump") and jump_counter > 0:
			motion.y = -JUMP_HEIGHT
			jump_counter -= 1
			
		# Handle airdodges
		if Input.is_action_just_pressed("airdodge"):
			print("airdodge started")
			motion = move_direction * AIRDODGE_SPEED
			$Airdodge_Timer.start()
			apply_gravity = false
			$Sprite.modulate = Color(0, 0, 0)
		
		# Handle fastfall
		if abs(motion.y) <= FASTFALL_THRESH and Input.is_action_just_pressed("ui_down"):
			motion.y = FASTFALL_SPEED
		
	if Input.is_action_pressed("ui_left"):
		print("going left")
	if Input.is_action_pressed("ui_right"):
		print("going right")
	
	#motion.x = clamp(motion.x, -TOP_SPEED, TOP_SPEED)
	if cancel_motion:
		motion = Vector2(0,0)
		cancel_motion = false
	
	motion = move_and_slide(motion, UP)


#func _input(event):
#	# remove items from queue so it doesn't get too big
#	while input_queue.size() >= INPUT_QUEUE_LENGTH:
#		input_queue.pop_back()
#
#	#add if it's unique
#	if input_queue.size() > 0:
#		var x = Input.get_joy_axis(0, JOY_AXIS_0)
#		var y = Input.get_joy_axis(0, JOY_AXIS_1)
#
#		#print(x, " : ", y)
#		#print(abs(x) > DEADZONE)
#
#		if abs(x) > DEADZONE:
#			print("x is greater than deadzone")
#			if x > 0:
#				Input.action_press("ui_right", x)
#			if x < 0:
#				Input.action_press("ui_left", abs(x))
#		else:
#
#		if abs(y) > DEADZONE:
#			if input_queue[0] != "ui_up" and y -0.8:
#				print("ui_up")
#				input_queue.insert(0, "ui_up")
#			if input_queue[0] != "ui_down" and y > 0.8:
#				print("ui_down")
#				input_queue.insert(0, "ui_down")
#
#		else:
#			for action in actions:
#				if event.is_action(action):
#					input_queue.insert(0, action)
#	else:
#		input_queue.append("none")

		
func get_lerp_value():
	if is_on_floor():
		return GROUND_LERP
	else:
		return AIR_LERP

func end_airdodge():
	apply_gravity = true
	$Sprite.modulate = Color(1,1,1)
	if !is_on_floor():
		motion = Vector2(0,0)
	jump_counter = 0


func _on_Airdodge_Timer_timeout():
	end_airdodge()