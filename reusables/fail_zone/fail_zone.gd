extends Area3D
# Just put onto an Area3D with a child collisionshape and it should work
# to zero out the health of any player or enemy that enters the area

func _ready() -> void:
	self.area_entered.connect(_fail_entered)

func _fail_entered(area: Area3D) -> void:
	if area.is_in_group("player") or area.is_in_group("enemy"):
		(area.get_parent_node_3d().health as HealthEntity).current_health = 0
