extends Node

signal fail_restart

var obj_pr = preload("res://tscn/object.tscn")
var title_pr = preload("res://tscn/title.tscn")

@onready var obj_group = $objects

var fail_f := false

func _ready():
	Game.fail.connect(failed)
	var title = title_pr.instantiate()
	add_child(title)
	await title.start
	evo_set()
	info_set()
	$bgm.play()
	await get_tree().create_timer(0.05).timeout
	start()

func start():
	Game.game_index += 1
	while true:
		var new_obj = obj_pr.instantiate()
		new_obj.init(Game.next_obj)
		Game.next_obj = randi_range(1, clamp(Game.high_lvl, 1, 6))
		next_set()
		obj_group.add_child(new_obj)
		while !Input.is_action_just_pressed("ui_accept"):
			if !new_obj:
				break
			if fail_f:
				return
			new_obj.position = $chr.position
			await get_tree().create_timer(0).timeout
		new_obj.position = $chr.position
		$drop.play()
		if !new_obj:
			pass
		else:
			new_obj.drop()
			await new_obj.obj_placed or fail_restart
			if fail_f:
				return
		await get_tree().create_timer(0).timeout

func evo_set():
	var evo = $ui/evo
	var rect = $ui/evo/TextureRect
	for i in range(Game.MAX_LVL):
		var new_rect = TextureRect.new()
		var path = "res://asset/img/" + Game.skin_path + "/lv" + str(i + 1) + ".png"
		var tex
		if FileAccess.file_exists(path):
			tex = load(path)
		else:
			tex = load("res://asset/img/" + Game.skin_path + "/placeholder.png")
		var size = rect.size / 2.0
		var center = rect.position + size
		var distance = 75
		var rect_size = 30
		var offset = 0.5
		
		new_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		new_rect.size = Vector2.ONE * rect_size
		new_rect.texture = tex
		new_rect.position = center - new_rect.size / 2.0 + Vector2.UP.rotated(lerp(offset, TAU, float(i) / float(Game.MAX_LVL))) * distance
		
		evo.add_child(new_rect)

func info_set():
	var game_ind = $ui/info/cur
	var version_text = $ui/info/ver
	game_ind.text = str(Game.game_index) + "ゲーム目"
	version_text.text = Game.engine_info.name + " v" + Game.engine_info.version + "\n" + Game.mod_info.name + " v" + Game.mod_info.version

func next_set():
	var rect = $ui/next/TextureRect/MarginContainer/TextureRect
	var path = "res://asset/img/" + Game.skin_path + "/lv" + str(Game.next_obj) + ".png"
	var tex
	if FileAccess.file_exists(path):
		tex = load(path)
	else:
		tex = load("res://asset/img/" + Game.skin_path + "/placeholder.png")
	rect.texture = tex

func _process(delta):
	$chr.position.x = get_viewport().get_mouse_position().x
	$chr.position.x = clamp($chr.position.x, $clamp1.position.x, $clamp2.position.x)
	if Input.is_action_just_pressed("game_reset"):
		Game.fail.emit()
		set_process(false)

var fail_pr = preload("res://tscn/fail.tscn")

func failed():
	$fail.play()
	$shader3/grayscale.material.set("shader_parameter/strength", 1.0)
	fail_f = true
	await get_tree().create_timer(2).timeout
	var fail = fail_pr.instantiate()
	add_child(fail)
	await fail.start
	Game.reset()
	for i in obj_group.get_children():
		i.queue_free()
	$shader3/grayscale.material.set("shader_parameter/strength", 0.0)
	fail_restart.emit()
	await get_tree().create_timer(0.05).timeout
	fail_f = false
	start()
	set_process(true)
