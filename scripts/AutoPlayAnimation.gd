extends Node3D

# Busca el AnimationPlayer que Godot genera automáticamente al importar
# el FBX (viene con el esqueleto, la malla y el clip "Idle" adentro) y
# reproduce la primera animación que encuentra en loop.

func _ready() -> void:
	var player := _find_animation_player(self)
	if player == null:
		push_warning("No se encontró AnimationPlayer dentro del modelo importado.")
		return
	var anims := player.get_animation_list()
	if anims.size() == 0:
		push_warning("El modelo no trae animaciones.")
		return
	var anim_name := anims[0]
	var anim := player.get_animation(anim_name)
	anim.loop_mode = Animation.LOOP_LINEAR
	player.play(anim_name)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
