extends Node2D

class_name Footsteps

@export var k_number_of_steps: int = 10
@export var m_texture: Texture
@export var m_locations: Array

func _ready():
    m_locations = []

func add_step(location: Vector2):
    #m_locations.push_back(global_transform.inverse() * location)
    m_locations.push_back(location)
    while m_locations.size() > k_number_of_steps:
        m_locations.remove_at(0)

    queue_redraw()

func _draw():
    for location in m_locations:
        var trans = Transform2D(0, Vector2.ONE, 0, location) * \
            Transform2D(0, Vector2(0.1, 0.1), 0, Vector2.ZERO) * \
            Transform2D(0, Vector2.ONE, 0, -m_texture.get_size() / 2)
        draw_set_transform_matrix(trans)
        draw_texture(m_texture, Vector2.ZERO)