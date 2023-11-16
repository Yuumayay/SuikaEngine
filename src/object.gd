extends RigidBody2D

signal obj_placed

var lvl := 1

enum {INIT, DROP}
var state := 0

const STOPED := 5.0
const HITBOX_SIZE_OFFSET := 3.0
const SCALE_MULTI := 0.025
const SCALE_OFFSET := 0.05
const LEVEL_MULTI := 0.125

func init(level = 1):
	lvl = level
	var scale_v = Vector2.ONE * (lvl * (lvl * LEVEL_MULTI)) * SCALE_MULTI + Vector2.ONE * SCALE_OFFSET
	freeze = true
	$shape.shape = CircleShape2D.new()
	$hitbox/shape.shape = CircleShape2D.new()
	$spr.scale = scale_v
	$spr.texture = load("res://asset/img/" + Game.skin_path + "/lv" + str(lvl) + ".png")
	$shape.shape.radius = ($spr.get_rect().size.x / 2.0) * $spr.scale.x
	$hitbox/shape.shape.radius = ($spr.get_rect().size.x / 2.0 + HITBOX_SIZE_OFFSET) * $spr.scale.x

func _ready():
	set_process(false)

func drop():
	print(timer)
	state = DROP
	set_process(true)
	set_deferred("freeze", false)

var timer = 0.5

func _process(delta):
	timer -= delta
	if abs(linear_velocity.x) + abs(linear_velocity.y) <= STOPED and timer <= 0.0:
		obj_placed.emit()
		set_process(false)
		if position.y <= 219 - ($spr.get_rect().size.x / 2.0) * $spr.scale.x:
			printerr("fail")

func _on_hitbox_body_entered(body):
	if "lvl" in body and lvl == body.lvl and body != self and state == DROP and body.state == DROP:
		obj_placed.emit()
		Game.merge(self, position, lvl)
