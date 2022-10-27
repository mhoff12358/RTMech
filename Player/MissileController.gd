extends Node
class_name MissileController

var m_character_body: CharacterBody2D

@export var k_fly_speed = 75

func _ready():
	var context = DIContext.get_nearest(self)

	m_character_body = context.get_registered_node("CharacterBody2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	m_character_body.move_and_collide(Vector2.RIGHT.rotated(m_character_body.global_rotation) * k_fly_speed * delta)
