extends Node2D

var cena_bomba = preload("res://Bomba.tscn")
var cena_tiro = preload("res://Tiro.tscn")

# --- REFERÊNCIAS AOS NÓS NA CENA ---
@onready var vilao = $Vilao 
@onready var player = $Player       
@onready var timer = $Timer
@onready var video = $VideoBoss

# Interface (UI)
@onready var label_score = $CanvasLayer/LabelScore
@onready var tela_game_over = $CanvasLayer/GrupoGameOver
@onready var label_vencedor = $CanvasLayer/LabelVencedor

# Caixas (Vidas e Munição)
@onready var container_vidas = $CanvasLayer/BoxContainer 
@onready var container_municao = $CanvasLayer/BoxContainer2 

# --- VARIÁVEIS DE CONTROLE ---
var modo_boss = false 
var esperando_enter_boss = false 
var municao = 10  
var jogo_acabou_final = false 

# --- CONFIGURAÇÃO INICIAL (Roda 1 vez ao abrir) ---
func _ready():
	# Garante que as balas, o vídeo e o texto final comecem INVISÍVEIS
	container_municao.visible = false
	label_vencedor.visible = false
	video.visible = false
	tela_game_over.visible = false

# --- LOOP DO JOGO (Roda a cada frame) ---
func _process(_delta):
	# 1. TRAVAS GERAIS (Pausa ou Cutscene)
	if get_tree().paused == true: return
	if video.visible == true: return
	if jogo_acabou_final: return

	# 2. MOVIMENTO DO VILÃO
	if is_instance_valid(vilao):
		# Movimento de vai-e-vem (Senoide)
		var novo_x = 320 + sin(Time.get_ticks_msec() * 0.002) * 280
		vilao.position.x = novo_x

	# 3. ATUALIZAÇÕES VISUAIS (Score e Interface)
	label_score.text = str(Global.score)
	
	# --- Lógica Visual das Balas (Só roda se a caixa estiver visível) ---
	if container_municao.visible:
		for i in range(container_municao.get_child_count()):
			# Mostra ou esconde cada bala baseado na quantidade restante
			container_municao.get_child(i).visible = (i < municao)
	
	# --- Lógica Visual das Vidas (Só roda se a caixa estiver visível) ---
	if container_vidas.visible:
		if container_vidas.has_node("Coracao1"):
			container_vidas.get_node("Coracao1").visible = (Global.vidas >= 1)
		if container_vidas.has_node("Coracao2"):
			container_vidas.get_node("Coracao2").visible = (Global.vidas >= 2)
		if container_vidas.has_node("Coracao3"):
			container_vidas.get_node("Coracao3").visible = (Global.vidas >= 3)
	
	# 4. GAME OVER (Perdeu as vidas)
	if Global.vidas <= 0:
		game_over()
		
	# 5. SISTEMA DE FASES (Normal)
	if modo_boss == false and esperando_enter_boss == false:
		# Dificuldade progressiva
		if Global.score < 100: timer.wait_time = 1.0
		elif Global.score < 200: timer.wait_time = 0.8
		elif Global.score < 300: timer.wait_time = 0.6
		
		# Gatilho para iniciar o Boss
		if Global.score >= 300:
			iniciar_cutscene_boss()

# --- ENTRADA DE COMANDOS (Teclado) ---
func _input(event):
	# CASO 1: REINICIAR JOGO (Se estiver pausado ou acabou)
	if get_tree().paused == true or jogo_acabou_final == true:
		if event.is_action_pressed("ui_accept"): # Enter/Espaço
			Global.resetar()
			get_tree().paused = false
			get_tree().reload_current_scene()
		return

	# CASO 2: SAIR DA CUTSCENE (Apertar Enter após o vídeo)
	if esperando_enter_boss == true:
		if event.is_action_pressed("ui_accept"):
			comecar_luta_real()
		return

	# CASO 3: ATIRAR (Apenas no Modo Boss)
	if modo_boss == true and event.is_action_pressed("ui_accept"):
		if municao > 0:
			var novo_tiro = cena_tiro.instantiate()
			novo_tiro.position = player.position
			novo_tiro.position.y -= 40 # Sai um pouco acima do player
			add_child(novo_tiro)
			
			municao -= 1 # Gasta visualmente uma bala
		else:
			print("SEM MUNIÇÃO!")

# --- FUNÇÕES DE AUXÍLIO E LÓGICA ---

# Chamado quando o Timer apita (Cria Bomba)
func _on_timer_timeout():
	var nova_bomba = cena_bomba.instantiate()
	if is_instance_valid(vilao):
		nova_bomba.position = vilao.position
		add_child(nova_bomba)

# Ativa a tela de Game Over (Explosão)
func game_over():
	tela_game_over.visible = true 
	get_tree().paused = true      

# --- SISTEMA DE BOSS ---

func iniciar_cutscene_boss():
	timer.stop() # Para de gerar bombas
	get_tree().call_group("bombas", "queue_free") # Limpa a tela
	
	# Esconde o HUD normal
	label_score.visible = false
	container_vidas.visible = false
	
	# Toca o vídeo
	video.visible = true
	video.play()

# Chamado automaticamente quando o vídeo termina (Sinal Conectado)
func _on_video_boss_finished():
	esperando_enter_boss = true
	# O vídeo continua na tela (congelado) até apertar Enter

func comecar_luta_real():
	esperando_enter_boss = false 
	modo_boss = true             
	video.visible = false        
	
	# TROCA DE HUD: Sai Vidas, Entra Munição
	container_municao.visible = true  
	container_vidas.visible = false
	label_score.visible = false 
	
	# TRANSFORMAÇÃO DO PLAYER
	var roupa_nova = load("res://heroi.png")
	var sprite_player = player.get_node("Sprite2D")
	sprite_player.texture = roupa_nova
	
	# Ajuste de altura para não cortar o pé
	sprite_player.position.y = -30 
	player.position.x = 320
	
	municao = 10 

# --- FINAIS DO JOGO ---

# Chamado pelo Script do TIRO quando sai da tela
func bala_errou():
	if municao <= 0:
		# Espera meio segundo para dar drama
		await get_tree().create_timer(0.5).timeout
		if jogo_acabou_final == false:
			vitoria_bolsonaro()

# Chamado pelo Script do TIRO quando acerta o Vilão
func vitoria_lula():
	jogo_acabou_final = true
	vilao.queue_free() # Remove vilão
	
	label_vencedor.text = "LULA\nWINS"
	label_vencedor.modulate = Color(1, 0, 0) # Vermelho
	label_vencedor.visible = true

# Chamado quando acabam as balas e não acertou
func vitoria_bolsonaro():
	jogo_acabou_final = true
	player.queue_free() # Remove herói
	
	label_vencedor.text = "BOLSONARO\nWINS"
	label_vencedor.modulate = Color(0.061, 0.361, 1.0, 1.0) # Azul
	label_vencedor.visible = true
