extends BeyPart
class_name BeyDisc

@export var right_spin : bool = true
@export_range(0.1, 4.0) var burst_resitance := 1.0
@export_range(0.5, 2.5) var burst_damage := 1.0
@export var physics_material : PhysicsMaterial
