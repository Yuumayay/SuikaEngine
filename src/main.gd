extends Node

var obj_pr = preload("res://tscn/object.tscn")

func _ready():
	$bgm.play()
	while true:
		var new_obj = obj_pr.instantiate()
		new_obj.init(randi_range(1, clamp(Game.high_lvl, 1, 5)))
		add_child(new_obj)
		while !Input.is_action_just_pressed("ui_accept"):
			if !new_obj:
				break
			new_obj.position = $chr.position
			await get_tree().create_timer(0).timeout
		$drop.play()
		if !new_obj:
			pass
		else:
			new_obj.drop()
			await new_obj.obj_placed
		await get_tree().create_timer(0).timeout

func _process(delta):
	$chr.position.x = get_viewport().get_mouse_position().x
	$chr.position.x = clamp($chr.position.x, $clamp1.position.x, $clamp2.position.x)
