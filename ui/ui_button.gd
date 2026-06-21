extends Control

@export var pivot := Vector2(0.5,0.5)
@export var grow_scale := Vector2(1.03,1.03)
var hover_tween: Tween

func _ready() -> void:
	if owner: await owner.ready
	pivot_offset = size * pivot
	mouse_entered.connect(_mouse_hovered)
	mouse_exited.connect(_mouse_unhovered)
	#add_theme_stylebox_override(&'hover_pressed',override_box)
	#add_theme_stylebox_override(&'focus',override_box)
	#add_theme_stylebox_override(&'hover',override_box)

func _mouse_hovered() -> void:
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_parallel().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	hover_tween.tween_property(self,^'scale',grow_scale,0.15)
	#hover_tween.tween_property(self,^'rotation',randf_range(-2.0,2.0) * deg_to_rad(1),0.15)
	Effects.play_ui(&"ButtonHover")

func _mouse_unhovered() -> void:
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	hover_tween.tween_property(self,^'scale',Vector2.ONE,0.15)
	hover_tween.tween_property(self,^'rotation',0.0,0.1)
	material = null
