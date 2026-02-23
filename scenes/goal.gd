@tool

extends Node3D

signal goal_score

@onready var goal_area : Area3D = $Area3D

@export var score_label: Label3D
@export var score: int = 0:
	set(value):
		score = value
		if score_label:
			score_label.text = '%s' % value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body):
	if body is RigidBody3D:
		print('SCORE!')
		score += 1
		
		goal_score.emit()
