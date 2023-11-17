extends CanvasLayer

signal start

func _ready():
	$mod_title.text = Game.mod_info.name
	$mod_ver.text = Game.mod_info.version
	$TextureRect.texture = load("res://asset/img/" + Game.skin_path + "/lv11.png")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		queue_free()
		start.emit()
