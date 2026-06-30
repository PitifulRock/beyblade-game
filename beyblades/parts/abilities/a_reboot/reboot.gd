extends BeyAbility

@export var speed_mult := 2.0

@rpc("any_peer", "call_local")
func activate():
	if Master.is_host:
		beyblade.linear_velocity *= speed_mult * Vector3(1,0,1)
	%Particles.emitting = true
	%Audio.play()
