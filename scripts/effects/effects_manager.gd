extends Node2D

#Player reference
var player = null

#State tracking
var emit_bullet_trail = false
var shot_start = null
var shot_end = null
var emit_timer = 0

func _enter_tree():
	set_process(true)
	player = global.player
	player.connect("shot_fired", self, "on_player_shot_fired")

func _process(delta):
	update()

func _draw():
	if (emit_bullet_trail):
		emit_bullet_trail = false
		emit_timer = 10

	if (emit_timer > 0):
		emit_timer = emit_timer - 1
		draw_line(shot_start, shot_end, Color(255, 255, 255), 2)

func on_player_shot_fired(start, end, victim):
	emit_bullet_trail = true
	shot_start = start
	shot_end = end