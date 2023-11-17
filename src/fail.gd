extends CanvasLayer

signal start

var focus := false

func _ready():
	Game.save_()
	$ui/score.text = str(Game.score)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and !focus:
		queue_free()
		start.emit()


func _on_button_mouse_entered():
	focus = true


func _on_button_mouse_exited():
	focus = false


func _on_button_pressed():
	$ui.hide()
	$screen.show()
	$/root/main/shader3/grayscale.material.set("shader_parameter/strength", 0.0)


func _on_button_2_pressed():
	$ui.show()
	$screen.hide()
	$/root/main/shader3/grayscale.material.set("shader_parameter/strength", 1.0)
