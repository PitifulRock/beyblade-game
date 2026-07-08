extends BeyAbility


@rpc("any_peer", "call_local")
func activate():
	beyblade.linear_velocity *= -0.5
	beyblade.current_spin *= -1
	%Audio.play()
	%Particles.rotation.z = 0.0 if beyblade.current_spin>0.0 else -180.0
	%Particles.emitting = true
