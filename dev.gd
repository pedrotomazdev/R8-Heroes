extends CharacterBody2D

@export var velocidade: float = 500.0
@export var forca_pulo: float = 420.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var aterrissando: bool = false


func _ready() -> void:
	sprite.animation_finished.connect(_ao_terminar_animacao)
	sprite.play("idle")


func _physics_process(delta: float) -> void:
	var estava_no_chao := is_on_floor()

	if not estava_no_chao:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("pular") and estava_no_chao:
		velocity.y = -forca_pulo
		aterrissando = false

	var direcao := Input.get_axis("mover_esquerda", "mover_direita")
	velocity.x = direcao * velocidade

	if direcao != 0:
		sprite.flip_h = direcao < 0

	move_and_slide()

	if global_position.y > 900:
		global_position = Vector2(200, 200)
		velocity = Vector2.ZERO
		aterrissando = false
		sprite.play("idle")
		return

	if not is_on_floor():
		aterrissando = false

		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")

	elif not estava_no_chao:
		aterrissando = true
		sprite.play("land")

	elif not aterrissando:
		if direcao != 0:
			sprite.play("run")
		else:
			sprite.play("idle")


func _ao_terminar_animacao() -> void:
	if sprite.animation == "land":
		aterrissando = false
