extends Node3D
class_name BeyAbility

signal ability_charged
signal ability_used

@export var ability_data : AbilityData
@export var charge_multiplier := 1.0
@export var charge_over_time := false
@export var charge_time_speed := 1.0

var beyblade : BeyBlade
var current_charge := 0.0:
	set(value):
		current_charge = value
		if value >= 100.0 and !is_charged:
			ability_charged.emit()
			is_charged = true
var is_charged := false

func _input(_event: InputEvent) -> void:
	if !is_multiplayer_authority() or !beyblade: return
	if Input.is_action_just_pressed("ability") and current_charge >= 100.0:
		activate.rpc()
		
		is_charged = false
		ability_used.emit()
		current_charge = 0.0

func _setup():
	if beyblade:
		set_multiplayer_authority(beyblade.name.to_int())
		beyblade.ability_node = self

func _physics_process(delta: float) -> void:
	if charge_over_time:
		current_charge += charge_time_speed * delta

@rpc("any_peer", "call_remote")
func _charge_hit(amount):
	current_charge += amount * charge_multiplier
	
@rpc("any_peer", "call_local")
func activate():
	pass

func _get_alive_beys(include_self := false) -> Array[BeyBlade]:
	var bey_array := []
	for bey:BeyBlade in beyblade.game_world.beyblade_path.get_children():
		if !bey.dead:
			if include_self:
				bey_array.append(bey)
			else:
				if bey != beyblade:
					bey_array.append(bey)
	return bey_array

func _get_nearest_bey() -> BeyBlade:
	var bey_distances : Dictionary[BeyBlade, float]
	for bey in _get_alive_beys():
		bey_distances[bey] = beyblade.global_position.distance_to(bey.global_position)
	return bey_distances.find_key(bey_distances.values().min())
