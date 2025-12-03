extends Area2D

# Velocidade do movimento
var velocidade = 600

func _process(delta):
	var direcao = 0
	
	# Verifica se apertou DIREITA
	if Input.is_action_pressed("ui_right"):
		direcao = 1
	
	# Verifica se apertou ESQUERDA
	if Input.is_action_pressed("ui_left"):
		direcao = -1

	# Aqui usamos o DELTA! (Isso vai fazer o aviso sumir e o cesto andar)
	position.x += direcao * velocidade * delta
	
	# Não deixa sair da tela (limites entre 20 e 620)
	position.x = clamp(position.x, 20, 620)
	
	# Trava a altura (Se o cesto estiver sumindo, diminua esse valor para 400)
	position.y = 450

# Mantém a colisão funcionando
func _on_area_entered(area):
	if area.is_in_group("bombas"):
		area.queue_free()
		Global.score += 10
