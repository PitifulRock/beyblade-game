extends BeyAbility

var base_orbit_speed := 3.0
var orbit_speed := 24.0

@rpc("any_peer", "call_local")
func activate():
	$OrbitTimer.start()
	%OrbitAnim.speed_scale = orbit_speed
	%Audio.play()

func _on_orbit_timer_timeout() -> void:
	%OrbitAnim.speed_scale = base_orbit_speed
	%Audio.stop()
