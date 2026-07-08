extends BeyAbility

@export var speed_add := 20.0
@export var ref_speed := 16.0
@export var min_boost := 0.4

@rpc("any_peer", "call_local")
func activate():
	if Master.is_host:
		var bey_speed = beyblade.linear_velocity.length()
		var boost_scale = clampf(bey_speed / (ref_speed + bey_speed), min_boost, 1.0)
		
		var angle := beyblade.linear_velocity.normalized() * Vector3(1,0,1)
		beyblade.linear_velocity += speed_add * boost_scale * angle
	%Particles.emitting = true
	%Audio.play()
