extends SceneTree

func _initialize() -> void:
	call_deferred("testar")

func testar() -> void:
	var fase = load("res://fase01.tscn").instantiate()
	root.add_child(fase)
	current_scene = fase
	var musica: AudioStreamPlayer = fase.get_node("Musica")
	assert(musica.playing)
	var faixa := musica.stream as AudioStreamWAV
	assert(faixa != null and faixa.loop_mode == AudioStreamWAV.LOOP_FORWARD)
	assert(absf(faixa.get_length()-49.7685)<0.01)
	assert(faixa.loop_begin == 0 and faixa.loop_end == 2194792)
	await create_timer(0.9).timeout
	assert(is_equal_approx(musica.volume_db,-14.0))
	# Força o final para verificar a repetição sem esperar cinquenta segundos.
	musica.seek(faixa.get_length()-0.15)
	await create_timer(0.5).timeout
	assert(musica.playing and musica.get_playback_position()<2.0)
	var antes := musica.get_playback_position()
	fase.reiniciar_no_checkpoint()
	await create_timer(0.2).timeout
	assert(musica.playing and musica.get_playback_position()>=antes)
	print("PASSOU: remix carregado, volume, loop e continuidade no checkpoint.")
	quit()
