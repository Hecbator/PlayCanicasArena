@tool

class_name Player
extends CharacterBody3D

@onready var name_label = $mesh/Skeleton3D/C_Chest_Attachment3D/NameLabel3D
@onready var number_label = $mesh/Skeleton3D/C_Chest_Attachment3D/NumberLabel3D
@onready var mesh_skin = $mesh/Skeleton3D/body_skin
@onready var mesh_hair = $mesh/Skeleton3D/body_hair
@onready var mesh_shirt = $mesh/Skeleton3D/body_shirt
@onready var mesh_pants = $mesh/Skeleton3D/body_pants
@onready var mesh_shocks = $mesh/Skeleton3D/body_shocks
@onready var mesh_shoes = $mesh/Skeleton3D/body_shoes

@export var team: String
@export var player_name: String = '':
	set(value):
		player_name = value
		name_set(value)
@export var player_number: String = '0':
	set(value):
		player_number = value
		set_number(value)

@export var color_skin: Color:
	set(value):
		color_skin = value
		set_skin(value)
@export var color_hair: Color:
	set(value):
		color_hair = value
		set_hair(value)
@export var color_shirt: Color:
	set(value):
		color_shirt = value
		set_shirt(value)
@export var color_pants: Color:
	set(value):
		color_pants = value
		set_pants(value)	
@export var color_shocks: Color:
	set(value):
		color_shocks = value
		set_shocks(value)
@export var color_shoes: Color:
	set(value):
		color_shoes = value
		set_shoes(value)

enum State {IDLE, RUN, KICK, VICTORY}

var state = State.IDLE
@export var target_ball : RigidBody3D = null
@export var field_area : Area3D 

var min_x := -33.0
var max_x := 33.0
var min_z := -51.5
var max_z := 51.5

@export var speed := 10.0
@export var pan := 0.2
@export var tilt := 0.2
@export var power := 40
var kick_dist := 1.5
var max_dist := 120.0

@onready var anim :AnimationPlayer = $AnimationPlayer

@onready var kick_physics = $mesh/Skeleton3D/R_Toe_Attachment3D/StaticBody3D.physics_material_override


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_player()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	await get_tree().process_frame
	
	if state == State.VICTORY:
		return
		
	# Vuelve a IDLE si target_ball está lejos
	if target_ball:
		if global_position.distance_to(target_ball.global_position) > max_dist:
			state = State.IDLE
			anim.play('RESET') # Vuelve a pose  por defecto
			target_ball = null
			return
		
	match state:
		State.IDLE:
			anim.play('moveset/idle')
			target_ball = get_closest_ball()
			
			kick_physics.friction = 1.0
			kick_physics.bounce = 0.0
			
			if target_ball:
				state = State.RUN
		
		State.RUN:
			if get_closest_ball() != target_ball:
				target_ball = get_closest_ball()
			
			if not is_instance_valid(target_ball):
				state = State.IDLE
				anim.play('RESET') # Vuelve a pose  por defecto
				return
				
			anim.play('moveset/run')
			
			# Calcula direccion hacia la pelota y avanza
			var dir = (target_ball.global_position - global_position)
			dir.y = 0
			dir = dir.normalized()
			
			# Velocidad del jugador
			velocity = dir * speed
			
			look_at(target_ball.global_position, Vector3.UP, true)

			move_and_slide()
			
			position.x = clamp(position.x, min_x, max_x)
			position.z = clamp(position.z, min_z, max_z)
			position.y = 0.0
			
			# Si la pelota está cerca se para y chuta
			if global_position.distance_to(target_ball.global_position) <= kick_dist:
				state = State.KICK
				velocity = Vector3.ZERO
				
		State.KICK:
			# Cambia fisica del rebote
			kick_physics.friction = 0.0
			kick_physics.bounce = 1.0
			
			# Obtener dirección del jugador
			var forward = transform.basis.z.normalized()
			
			# Desvio horizontal
			var horizontal_angle = randf_range(-pan, pan)
			var deviated_dir = forward.rotated(Vector3.UP, horizontal_angle)
			
			# Desvio vertical
			var right_axis = -transform.basis.x.normalized()
			var vertical_angle = randf_range(max(tilt - 0.2, 0.0), tilt + 0.2)
			deviated_dir = deviated_dir.rotated(right_axis, vertical_angle)
			
			deviated_dir = deviated_dir.normalized()
			
			# Potencia del chute
			var kick_power = power - randf_range(-10.0, 10.0)
			
			# Chutar
			anim.play('moveset/kick_pre')
			await anim.animation_finished
			
			anim.play('moveset/kick')
			target_ball.apply_central_force(deviated_dir * kick_power)
			await anim.animation_finished
			
			state = State.IDLE
			anim.play('RESET') # Vuelve a pose  por defecto
	
	
func setup_player():
	name_set(player_name)
	set_number(player_number)
	set_skin(color_skin)
	set_hair(color_hair)
	set_shirt(color_shirt)
	set_pants(color_pants)
	set_shocks(color_shocks)
	set_shoes(color_shoes)
	
	# Randomizar atributos para evitar tener que hacerlo a mano en cada jugador
	speed *= randf_range(0.9, 1.1)
	pan *=  randf_range(0.8, 1.2)
	tilt *= randf_range(0.8, 1.2)
	power *= randf_range(0.5, 1.5)
	
		
func name_set(value: String):
	if name_label:
		name_label.text = value
	
	
func set_number(value: String):
	if number_label:
		number_label.text = value
		
		
func set_skin(color: Color):
	if mesh_skin:
		var mat = mesh_skin.material_override
		mat.albedo_color = color
		
		
func set_hair(color: Color):
	if mesh_hair:
		var mat = mesh_hair.material_override
		mat.albedo_color = color
		
		
func set_shirt(color: Color):
	if mesh_shirt:
		var mat = mesh_shirt.material_override
		mat.albedo_color = color
		
		
func set_pants(color: Color):
	if mesh_pants:
		var mat = mesh_pants.material_override
		mat.albedo_color = color
		
		
func set_shocks(color: Color):
	if mesh_shocks:
		var mat = mesh_shocks.material_override
		mat.albedo_color = color
		
		
func set_shoes(color: Color):
	if mesh_shoes:
		var mat = mesh_shoes.material_override
		mat.albedo_color = color
	

func get_closest_ball():
	if not field_area:
		return
	
	var balls = field_area.get_overlapping_bodies()
	var closest_ball : RigidBody3D = null
	var min_dist = INF
	
	for ball in balls:
		if ball is RigidBody3D:
			var dist = global_position.distance_to(ball.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_ball = ball
				
	return closest_ball
	

func celebrate_goal():
	state = State.VICTORY
	velocity = Vector3.ZERO
	anim.play("moveset/win")
	
	await get_tree().create_timer(3.0).timeout
	
	state = State.IDLE
