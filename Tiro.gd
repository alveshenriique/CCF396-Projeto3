extends Area2D

var velocidade = 600

func _process(delta):
	# Tiro sobe
	position.y -= velocidade * delta
	
	# SE O TIRO SAIR DA TELA (ERROU)
	if position.y < -50:
		# --- AQUI ESTÁ O SEGREDO ---
		# Avisa a Main que essa bala foi perdida antes de sumir
		if get_parent().has_method("bala_errou"):
			get_parent().bala_errou()
		# ---------------------------
		
		queue_free()

func _on_area_entered(area):
	if area.name == "VilaoArea":
		# Avisa a Main que ACERTOU
		if get_parent().has_method("vitoria_lula"):
			get_parent().vitoria_lula()
		
		queue_free()
