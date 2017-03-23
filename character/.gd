extends KinematicBody2D

# Locomotion variables
const GRAVITY = 500
const MAX_WALK_SPEED = 200
const WALK_ACCEL = 20
const JUMP_ACCEL = 275
const JUMP_TIME = 0.10
const SLIDE_ACCEL = 12

var animator = null
var velocity = Vector2()

# State tracking variables
var jumping = false
var air_time = 0.0
var facing = "right"
var sliding = false
var crosshair_pos = null
var shot_triggered = false

#Signals
signal shot_fired
signal attributes_updated

#Attributes
var health = 100
var ammo = 10
var special = 100

func _enter_tree():
	global.player = self
	animator = get_node("anim")

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	emit_signal("attributes_updated", health, ammo, special)

func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):
		var crosshair = get_node("crosshair").get_texture()
		crosshair_pos = Vector2(event.pos.x + (crosshair.get_width() / 2), event.pos.y + (crosshair.get_height() / 2))

	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.button_index == 1 && event.pressed):
			shot_triggered = true

func _fixed_process(delta):
	var moving_left = Input.is_action_pressed("ui_left")
	var moving_right = Input.is_action_pressed("ui_right")
	var jump_triggered = Input.is_action_pressed("ui_accept") && !jumping

	######################
	#    MOVING LOGIC    #
	######################
	if (moving_left):
		face_left()
		sliding = false
		if (velocity.x > -MAX_WALK_SPEED):
			velocity.x -= WALK_ACCEL
		if(!animator.is_playing()):
			animator.play("run")
	elif (moving_right):
		face_right()
		sliding = false
		if (velocity.x < MAX_WALK_SPEED):
			velocity.x += WALK_ACCEL
		if(!animator.is_playing()):
			animator.play("run")

	######################
	#   JUMPING LOGIC    #
	######################
	if (jump_triggered):
		jumping = true
		update_attributes(health, ammo, special - 1)

	if (jumping):
		animator.play("jump")
		air_time += delta
		if (air_time <= JUMP_TIME):
			velocity.y = -JUMP_ACCEL
		else:
			if (velocity.y == 0):
				jumping = false
				air_time = 0
				animator.play("rest")

	######################
	#   SLIDING LOGIC    #
	######################
	if (!jumping && !moving_left && !moving_right && abs(velocity.x) > 1):
		sliding = true
		show_dust()

	if (sliding):
		animator.play("slide")
		var direction = sign(velocity.x)
		if (direction < 0):
			velocity.x += SLIDE_ACCEL
			if (velocity.x >= 0):
				velocity.x = 0
				sliding = false
				animator.play("rest")
		if (direction > 0):
			velocity.x -= SLIDE_ACCEL
			if (velocity.x <= 0):
				velocity.x = 0
				sliding = false
				animator.play("rest")
	else:
		hide_dust()

	#Apply gravity force
	velocity.y += delta * GRAVITY

	#Convert the total force to motion
	var motion = velocity * delta
	move(motion)
	
	#Prevent from going inside collision nodes
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

	######################
	#    WEAPON LOGIC    #
	######################
	if (shot_triggered):
		var space_state = get_world_2d().get_direct_space_state()
		var shot_result = space_state.intersect_ray(get_global_pos(), crosshair_pos, [ self ])
		emit_signal("shot_fired", get_global_pos(), crosshair_pos, shot_result)
		shot_triggered = false

######################
#  HELPER FUNCTIONS  #
######################
func face_right():
	face(self, "right")

func face_left():
	face(self, "left")

func face(node, direction):
	facing = "right"
	if (direction == "right"):
		set_scale(Vector2(1,1))
	if (direction == "left"):
		facing = "left"
		set_scale(Vector2(-1,1))

func show_dust():
	get_node("slide_dust_r").set_hidden(false)
	get_node("slide_dust_l").set_hidden(false)

func hide_dust():
	get_node("slide_dust_r").set_hidden(true)
	get_node("slide_dust_l").set_hidden(true)
	
func stop_animation():
	animator.stop(true)
	animator.seek(0.0, true)

func update_attributes(new_health, new_ammo, new_special):
	health = new_health
	ammo = new_ammo
	special = new_special
	emit_signal("attributes_updated", health, ammo, special)