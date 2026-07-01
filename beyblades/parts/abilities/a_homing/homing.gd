extends BeyAbility

@export var strength := 5.0

@rpc("any_peer", "call_local")
func activate():
	if _get_alive_beys(false).is_empty(): return
	
	if Master.is_host:
		var direction = beyblade.global_position.direction_to(_get_nearest_bey().global_position)
		var impulse = Vector3(direction.x, 0, direction.z).normalized() * strength
		beyblade.linear_velocity *= 0.01
		beyblade.apply_central_impulse(impulse)
		
		var visual_rot = atan2(impulse.x, impulse.z)
		rotate_arrow.rpc(visual_rot)
	%ArrowAnim.play("arrow")

@rpc("any_peer", "call_local")
func rotate_arrow(angle : float):
	%ArrowPivot.global_rotation.y = angle
