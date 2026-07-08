extends BeyAbility

var active := false
@export var damage := 30.0

func _ready() -> void:
	active = false
	%SwordArea.monitoring = false
	%SwordPivot.visible = false

@rpc("any_peer", "call_local")
func activate():
	%SwordPivot.visible = true
	%SwordArea.monitoring = true
	
	%ArrowAnim.play("swing")
	%Sound.play()
	active = true
	await %ArrowAnim.animation_finished
	active = false
	
	%SwordPivot.visible = false
	%SwordArea.monitoring = false

func _process(_delta: float) -> void:
	if !beyblade: return
	if _get_alive_beys().is_empty(): return
	if Master.is_host:
		rotate_sword.rpc(_get_nearest_bey().global_position)

@rpc("any_peer", "call_local")
func rotate_sword(angle : Vector3):
	%SwordPivot.look_at(angle)


func _on_damage_area_entered(body: Node3D) -> void:
	if !Master.is_host: return
	if body is BeyBlade:
		if body != beyblade:
			var direction = beyblade.global_position.direction_to(_get_nearest_bey().global_position)
			var impulse = Vector3(direction.x, 0, direction.z).normalized() * 1.1
			body.apply_central_impulse(impulse)
			
			body.burst_damage += damage
			%Clash.play()
