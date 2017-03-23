extends Node2D

func _ready():
	#background music
	var background_music = get_node("background_music")
	background_music.play(6)
	background_music.set_loop(true)