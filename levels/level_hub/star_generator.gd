@tool
extends Node3D
class_name StarGenerator

# This should be put on a Node3D with a child Area3D (named StarArea) with a valid CollisionShape3D child on that.
# Stars go in that shape.

@export var star_number: int = 100
@onready var star_shape: CollisionShape3D = $StarArea/CollisionShape3D
var star_area: BoxShape3D

func _ready() -> void:
	_generate_stars()
	
func _generate_stars() -> void:
	star_area = star_shape.shape
	var star_mat: StandardMaterial3D = StandardMaterial3D.new()
	star_mat.emission = Color.WHITE
	star_mat.emission_enabled = true
	
	var star_mesh: SphereMesh = SphereMesh.new()
	star_mesh.material = star_mat
	for i in range(star_number):
		var star: MeshInstance3D = MeshInstance3D.new()
		star_shape.add_child(star)
		star.position = Vector3(randf_range(-star_area.size.x/2, star_area.size.x/2), randf_range(-star_area.size.y/2, star_area.size.y/2), randf_range(-star_area.size.z/2, star_area.size.z/2))
		star.mesh = star_mesh

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		for star in star_shape.get_children():
			if star is MeshInstance3D:
				star.queue_free()
	elif  what == NOTIFICATION_EDITOR_POST_SAVE:
		_generate_stars()
