extends Node3D

# Mixamo suele exportar en centímetros; Godot trabaja en metros.
# Este script mide el tamaño real del modelo ya importado y:
#  1) lo reescala para que mida ~1.8 unidades de alto (una persona)
#  2) reubica la cámara para que siempre lo encuadre bien.

@onready var pirate: Node3D = $PirataBueno
@onready var camera: Camera3D = $Camera3D

const TARGET_HEIGHT := 1.8

func _ready() -> void:
	call_deferred("_fit_camera")

func _fit_camera() -> void:
	var aabb := _get_combined_aabb(pirate)
	if aabb.size.length() < 0.0001:
		push_warning("PiratePreview3D: no se encontró geometría visible dentro del modelo (revisá si el FBX importó bien).")
		return

	var height := aabb.size.y
	if height > 0.0001:
		var factor := TARGET_HEIGHT / height
		if factor < 0.95 or factor > 1.05:
			pirate.scale = Vector3.ONE * factor
			aabb = _get_combined_aabb(pirate)

	var center := aabb.position + aabb.size / 2.0
	var radius: float = max(aabb.size.x, max(aabb.size.y, aabb.size.z))
	camera.position = center + Vector3(0, aabb.size.y * 0.15, radius * 2.5 + 1.0)
	camera.look_at(center, Vector3.UP)

func _get_combined_aabb(node: Node) -> AABB:
	var acc := [AABB(), false]  # [aabb acumulada, tiene algo]
	_merge_aabb(node, acc)
	return acc[0]

func _merge_aabb(node: Node, acc: Array) -> void:
	if node is MeshInstance3D:
		var mesh_inst := node as MeshInstance3D
		var local_aabb: AABB = mesh_inst.get_aabb()
		var world_aabb: AABB = mesh_inst.global_transform * local_aabb
		if acc[1]:
			acc[0] = acc[0].merge(world_aabb)
		else:
			acc[0] = world_aabb
			acc[1] = true
	for child in node.get_children():
		_merge_aabb(child, acc)
