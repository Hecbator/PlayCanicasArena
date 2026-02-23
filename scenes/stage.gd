extends Node3D

@onready var goalA = $Stadium.goalA
@onready var goalB = $Stadium.goalB

var _player = preload("res://player/player.tscn")

var field_size := Vector3(68.0, 0.0, 105.0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	goalA.goal_score.connect(celebarate_goalA)
	goalB.goal_score.connect(celebarate_goalB)
	
	#build_team('TeamA', 'Pocholos', [2, 4, 2])
	#build_team('TeamB', 'Rojillos', [3, 5, 1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func celebarate_goalA():
	print('CELEBRATE TEAM A')
	var players = get_tree().get_nodes_in_group('TeamA')
	for player in players:
		if not player is Player:
			continue
		player.celebrate_goal()
	#get_tree().call_group('TeamA', 'celebrate_goal')
	
	
func celebarate_goalB():
	print('CELEBRATE TEAM B')
	var players = get_tree().get_nodes_in_group('TeamB')
	for player in players:
		if not player is Player:
			continue
		player.celebrate_goal()
	#get_tree().call_group('TeamB', 'celebrate_goal')


func build_team(group: String, team: String, formation: Array, shirt:= Color(0.0, 0.37, 0.19, 1.0), pants:= Color(0.0, 0.09, 0.08, 1.0), shocks:= Color(0.93, 0.95, 0.94, 1.0), shoes:= Color(0.0, 0.0, 0.0, 1.0)):
	'''
	Formation: lista con el numero de jugadores por fila. Ej: [2, 4, 3] 
	'''
	
	match group:
		'TeamA': $Stadium.teamA = team
		'TeamB': $Stadium.teamB = team
	
	var rows = formation.size() 
	for row in rows:
		var columns = formation[row]
		for column in columns:
			var player :Player = _player.instantiate()
			add_child(player)
			player.add_to_group(group)
			match group:
				'TeamA': 
					player.rotation.y = 90.0
					player.position.x = -(field_size.x / 2.0) + (column + 1) * (field_size.x / (columns + 1))
					player.position.z = (row + 1) * (field_size.z / 2.0) / (rows + 1)
					player.field_area = $Stadium/Area3D_F
				'TeamB':
					player.rotation.y = 0.0
					player.position.x = (field_size.x / 2.0) - (column + 1) * (field_size.x / (columns + 1))
					player.position.z = -(row + 1) * (field_size.z / 2.0) / (rows + 1)
					player.field_area = $Stadium/Area3D_B
					
			if shirt:
				player.color_shirt = shirt
			if pants:
				player.color_pants = pants
			if shocks:
				player.color_shocks = shocks
			if shoes:
				player.color_shoes = shoes
		
	
