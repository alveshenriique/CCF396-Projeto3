extends Area2D

func _process(delta):
	var velocidade = 300 # Velocidade Padrão (Fase 1)
	
	# --- SISTEMA DE FASES (VELOCIDADE DE QUEDA) ---
	if Global.score >= 100 and Global.score < 200:
		velocidade = 400 # Fase 2: Um pouco mais rápido
	elif Global.score >= 200:
		velocidade = 500 # Fase 3: Rápido!

	# Aplica o movimento
	position.y += velocidade * delta

	# Regra de perder vida (Mantém igual)
	if position.y > 500:
		Global.vidas -= 1
		queue_free()
