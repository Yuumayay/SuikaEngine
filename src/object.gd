extends RigidBody2D

signal obj_placed

var lvl := 1

enum {INIT, DROP}
var state := 0

const STOPED := 5.0
const HITBOX_SIZE_OFFSET := 3.0
const SCALE_MULTI := 0.025
const SCALE_OFFSET := 0.05
const LEVEL_MULTI := 0.1

func init(level = 1):
	Game.fail.connect(failed)
	lvl = level
	var scale_v = Vector2.ONE * (lvl * (lvl * LEVEL_MULTI)) * SCALE_MULTI + Vector2.ONE * SCALE_OFFSET
	freeze = true
	$shape.shape = CircleShape2D.new()
	$hitbox/shape.shape = CircleShape2D.new()
	$spr.scale = scale_v
	$spr.texture = Game.load_asset("img", "lv" + str(lvl))
	$shape.shape.radius = ($spr.get_rect().size.x / 2.0) * scale_v.x
	$hitbox/shape.shape.radius = ($spr.get_rect().size.x / 2.0 + HITBOX_SIZE_OFFSET) * scale_v.x

func _ready():
	set_process(false)

func drop():
	state = DROP
	set_process(true)
	set_deferred("freeze", false)

var timer = 1.0
var placed := false

const FAIL_LINE_POS := Vector2(0, 219)

func _process(delta):
	timer -= delta
	if timer <= 0.0: # abs(linear_velocity.x) + abs(linear_velocity.y) <= STOPED
		if position.y <= FAIL_LINE_POS.y - ($spr.get_rect().size.x / 2.0) * $spr.scale.x:
			printerr("fail")
			Game.fail.emit()
			set_process(false)
			return
		if !placed:
			obj_placed.emit()
			placed = true

func _on_hitbox_body_entered(body):
	if "lvl" in body and lvl == body.lvl and body != self and state == DROP and body.state == DROP and lvl != Game.MAX_LVL:
		obj_placed.emit()
		Game.merge(self, position, lvl)

func failed():
	set_deferred("freeze", true)
	set_process(false)
