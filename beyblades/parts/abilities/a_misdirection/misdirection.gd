extends BeyAbility

@export var strength := 4.0

@rpc("any_peer", "call_local")
func activate():
	if Master.is_host:
		var angle = randf_range(0, TAU)
		var impulse = Vector3(cos(angle), 0, sin(angle)) * strength
		beyblade.linear_velocity *= 0.5
		beyblade.apply_central_impulse(impulse)
		
		var visual_rot = atan2(impulse.x, impulse.z)
		rotate_arrow.rpc(visual_rot)
	%ArrowAnim.play("arrow")

@rpc("any_peer", "call_local")
func rotate_arrow(angle : float):
	%ArrowPivot.global_rotation.y = angle
