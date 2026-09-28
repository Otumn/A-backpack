class_name Feedback
extends Node2D

@export_group("Base parameters")
@export var loop: bool = false;
@export var life_time: float = 1;

@export_group("Nodes")
## Can be left empty, the feedback won't have any VFX attached to it
@export var particle: Array[GPUParticles2D];
## Can be left empty, the feedback won't have any SFX attached to it
@export var sound: Array[AudioStreamPlayer2D];

var timer: Timer;

var available: bool = true

func setup_feedback():
	timer = $LifeTime
	timer.wait_time = life_time

func trigger_feedback(pos: Vector2, rot: float):
	scale = Vector2(1, 1) #to account for potential flips
	
	visible = true
	position = pos
	rotation = rot
	available = false
	timer.start()
	
	if not particle.is_empty():
		for i in particle:
			if loop :
				i.emitting = true
			else : 
				i.restart()

	if not sound.is_empty():
		for i in sound:
			if loop : 
				i.playing = true
			else :
				i.play()

func stop_feedback():
	visible = false
	
	if not particle.is_empty():
		for i in particle:
			i.emitting = false
	
		if not sound.is_empty():
			for i in sound:
				if loop :
					i.playing = false
				else :
					i.stop()
	
	available = true

func _on_life_time_timeout() -> void:
	stop_feedback()
