extends BeyAbility

@export var weight_mult = 0.75
@export var spin_gain = 0.35

@rpc("any_peer", "call_local")
func activate():
	if Master.is_host:
		beyblade.mass *= weight_mult
		beyblade.current_spin += beyblade.current_spin * spin_gain
	
	%Particles.emitting = true
	%Audio.play()
