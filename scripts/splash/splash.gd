extends TextureFrame

var loader
var time_max = 100 # msec
var current_scene

func _ready():
	#Connect "start" button to function
	get_node("start").connect("pressed",self,"_on_button_pressed")

	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)

func goto_scene(path):
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		show_error()
		return

	set_process(true)

func _process(delta):
	if loader == null:
		set_process(false)
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread

		# poll your loader
		var status = loader.poll()

		if status == ERR_FILE_EOF: # load finished
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif status == OK:
			update_progress()
		else: # error during loading
			show_error()
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()

func set_new_scene(scene_resource):
	current_scene.queue_free()
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)

func _on_button_pressed():
	goto_scene("res://root.tscn")