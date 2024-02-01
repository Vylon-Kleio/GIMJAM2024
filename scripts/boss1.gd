extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var wall_detector = $WallDetector
@onready var hitbox = $hitbox/CollisionShape2D

var key = preload("res://scene/key.tscn")
var enemy1 = preload("res://scene/enemy1.tscn")
var enemy2 = preload("res://scene/enemy2.tscn")

@export var normal_speed = -500
@export var normal_jump = -2000
@export var health = 10
@export var strength = 100
var speed = normal_speed
var jump = normal_jump
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_facing_right = false
var is_attacked = false
var is_death = false
var summon_ready = false

@export var enemy1_spawn_position: Vector2
@export var enemy2_spawn_position: Vector2
@export var enemy1_spawn_spread: int
@export var enemy2_spawn_spread: int


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	if wall_detector.is_colliding():
		flip()
	
	
	if is_attacked and !is_death:
		animated_sprite_2d.animation = 'hit'
		speed = 0
		jump = 0
		hitbox.disabled = true
	elif !is_death:
		animated_sprite_2d.animation = 'idle'
		speed = normal_speed
		jump = normal_jump
		if is_facing_right:
			speed = abs(speed)
			wall_detector.rotation_degrees = 270
		else:
			wall_detector.rotation_degrees = 90
			speed = abs(speed) * -1
	
	if is_on_floor():
		velocity.y = jump
	
	velocity.x = speed

	move_and_slide()
	
	if health % 300 == 0 and health != 0:
		summon()
		health -= 10
	
	if health <= 0:
		is_death = true
		die()

func flip():
	is_facing_right = !is_facing_right
	
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h
	if is_facing_right:
		speed = abs(speed)
		wall_detector.rotation_degrees = 270
	else:
		wall_detector.rotation_degrees = 90
		speed = abs(speed) * -1

func attacked():
	is_attacked = true
	print(health)

func die():
	hitbox.disabled = true
	animated_sprite_2d.animation = 'death'

func _on_animated_sprite_2d_animation_looped():
	if animated_sprite_2d.animation == 'hit':
		is_attacked = false
		hitbox.disabled = false
	if animated_sprite_2d.animation == 'death':
		var key_drop = key.instantiate()
		key_drop.position = position
		get_parent().add_child(key_drop)
		queue_free()


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.attacked()
		body.health -= strength

func summon():
	for i in range(randi_range(2, 6)):
		var enemy1_spawn = enemy1.instantiate()
		enemy1_spawn.position = enemy1_spawn_position
		enemy1_spawn.position.x = enemy1_spawn_position.x + (enemy1_spawn_spread * i)
		get_parent().add_child(enemy1_spawn)
	
	for i in range(randi_range(1,3)):
		var enemy2_spawn = enemy2.instantiate()
		enemy2_spawn.position = enemy2_spawn_position
		enemy2_spawn.position.x = enemy2_spawn_position.x + (enemy2_spawn_spread * i)
		get_parent().add_child(enemy2_spawn)