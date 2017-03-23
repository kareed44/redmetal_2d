extends VBoxContainer

#Player reference
var player = null

#Status label
var status_label = null

func _enter_tree():
	player = global.player
	player.connect("shot_fired", self, "on_player_shot_fired")

	status_label = get_node("status_label")

func on_player_shot_fired(start, end, victim):
	if (victim != null):
		status_label.set_text("Shot hit: " + str(victim))
	else:
		status_label.set_text("Shot missed!")