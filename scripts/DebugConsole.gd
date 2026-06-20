extends Control

func _input(_event: InputEvent) -> void:
	#if !is_multiplayer_authority():
		#return
	if Input.is_action_just_pressed("debug"):
		visible = !visible

func _ready() -> void:
	$Text.text = ""
	visible = false

@rpc("any_peer", "call_local")
func _print(...args):
	var line = ""
	for arg in args:
		if line != "":
			line += " "
		line += str(arg)
	$Text.text += ("\n" + line)
