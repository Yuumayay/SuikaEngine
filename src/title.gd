extends CanvasLayer

signal start

@onready var all_reset = $all_reset
@onready var reset = $reset

var dark_red = Color(0.5, 0, 0)
var red = Color(1, 0, 0)

var focus := false

func _ready():
	$mod_title.text = Game.mod_info.name
	$mod_ver.text = Game.mod_info.version
	$TextureRect.texture = Game.load_asset("img", "lv11")

func _process(delta):
	all_reset_timer -= delta
	reset_timer -= delta
	if all_reset_timer <= 0.0:
		all_reset.add_theme_color_override("font_color", dark_red)
		all_reset.text = all_reset_text
		all_reset_count = 0
	if reset_timer <= 0.0:
		reset.add_theme_color_override("font_color", dark_red)
		reset.text = reset_text
		reset_count = 0
	if Input.is_action_just_pressed("ui_accept") and !focus:
		queue_free()
		start.emit()

const TIMER_MAX := 2.0
var all_reset_timer := 0.
var reset_timer := 0.
var all_reset_count := 0:
	set(v):
		all_reset_count = v
		if v == 0:
			return
		if v >= caution.size() + 1:
			Game.all_data_reset()
			all_reset_count = 0
			all_reset.text = erased_text
		else:
			all_reset.text = caution[v - 1]
			all_reset.add_theme_color_override("font_color", red)
var reset_count := 0:
	set(v):
		reset_count = v
		if v == 0:
			return
		if v >= caution.size() + 1:
			Game.data_reset()
			reset_count = 0
			reset.text = erased_text
		else:
			reset.text = caution[v - 1]
			reset.add_theme_color_override("font_color", red)

var reset_text = "データリセット"
var all_reset_text = "全データリセット"
var erased_text = "削除完了！"

var caution := [
	"OK?", "いいの？", "まじで？", "けすよ？", "3", "2", "1"
]

func _on_all_reset_pressed():
	all_reset_timer = TIMER_MAX
	all_reset_count += 1


func _on_reset_pressed():
	reset_timer = TIMER_MAX
	reset_count += 1

func _on_reset_mouse_entered():
	focus = true


func _on_reset_mouse_exited():
	focus = false


func _on_all_reset_mouse_entered():
	focus = true


func _on_all_reset_mouse_exited():
	focus = false
