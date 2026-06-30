extends BeyAbility

func _ready() -> void:
	_disable_shield()

@rpc("any_peer", "call_local")
func activate():
	$ShieldBody.visible = true
	%ShieldCollision.disabled = false
	
	$ShieldTimer.start()
	%Audio.play()
	%Particles.emitting = true


func _disable_shield() -> void:
	$ShieldBody.visible = false
	%ShieldCollision.disabled = true
