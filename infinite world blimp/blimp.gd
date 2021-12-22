extends Spatial
func process_input(delta):
	if Input.is_action_pressed("movement_right"):
		$Player.queue_free 
