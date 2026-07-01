extends BeyAbility

@export var strength = 1.5

@rpc("any_peer", "call_local")
func activate():
	if Master.is_host:
		var force = beyblade.get_center_pull_force()*Vector3(strength,0,strength)
		beyblade.apply_central_impulse(force)
