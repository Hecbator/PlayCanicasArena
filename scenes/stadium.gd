@tool

extends Node3D

@export var goalA : Node3D = null
@export var goalB : Node3D = null

@onready var teamALabel = $Structure/Wall_B/TeamLabel3D
@onready var teamBLabel = $Structure/Wall_F/TeamLabel3D

@export var teamA : String:
	set(value):
		teamA = value
		if teamALabel:
			teamALabel.text = value
@export var teamB : String:
	set(value):
		teamB = value
		if teamBLabel:
			teamBLabel.text = value
