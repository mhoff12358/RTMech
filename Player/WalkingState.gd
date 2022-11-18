extends Node
class_name WalkingState

@export var m_throttle: float = 0
@export var m_throttle_dead_zone: float = 0.1
@export var m_throttle_adjust_speed: float = 0.5

@export var m_desired_heading_offset: float = 0
@export var m_desired_heading_offset_adjust_speed: float = 180
@export var m_heading_offset_max: float = 45

@export_enum("Left", "Right") var m_placed_foot = 0

@onready var m_context: DIContext = DIContext.get_nearest(self)

@onready var m_character_body: CharacterBody2D = m_context.get_registered_node("CharacterBody2D")

@onready var m_animation_tree: AnimationTree = m_context.get_registered_node("AnimationTree")
var m_step_playback: AnimationNodeStateMachinePlayback
var m_turn_waist_playback: AnimationNodeStateMachinePlayback

@onready var m_footsteps: Footsteps = m_context.get_registered_node("Footsteps")

@onready var m_waist: Node2D = m_context.get_registered_node_with_id("Node2D", "Waist")
@onready var m_torso: Node2D = m_context.get_registered_node_with_id("Node2D", "Torso")
@onready var m_right_foot: Node2D = m_context.get_registered_node_with_id("Node2D", "RightFoot")
@onready var m_left_foot: Node2D = m_context.get_registered_node_with_id("Node2D", "LeftFoot")

var m_grounded_foot_position: Vector2 = Vector2.ZERO

func start_step():
    m_animation_tree.set("parameters/AddWalk/add_amount", get_clipped_throttle())

    apply_waist_rotation_to_body()
    var heading_delta = min(m_heading_offset_max, max(-m_heading_offset_max, m_desired_heading_offset))
    m_desired_heading_offset -= heading_delta

    print("delta ", heading_delta)
    if heading_delta > 0:
        m_turn_waist_playback.travel("TurnWaistRight")
    elif heading_delta < 0:
        m_turn_waist_playback.travel("TurnWaistLeft")
    print("amt", abs(heading_delta) / 45.0)
#    m_animation_tree.set("parameters/AddTurnWaist/add_amount", abs(heading_delta) / 45.0)

#    m_left_foot.rotation = heading_delta * PI / 180
#    m_right_foot.rotation = heading_delta * PI / 180
#    m_waist.rotation = heading_delta * PI / 180

#    m_animation_tree.set("parameters/TurnWaistScale/scale", heading_delta / 360.0)
#    m_animation_tree.set("parameters/TurnWaistSeek/seek", 0)
#
#    if heading_delta < 0:
#        m_animation_tree.set("parameters/TurnWaistBlend/blend_amount", 0)
#    else:
#        m_animation_tree.set("parameters/TurnWaistBlend/blend_amount", 1)

func place_right():
    m_placed_foot = 1
    m_grounded_foot_position = m_right_foot.global_position

#    m_animation_tree.set("parameters/TurnWaistScale/scale", 0)

func place_left():
    m_placed_foot = 0
    m_grounded_foot_position = m_left_foot.global_position

#    m_animation_tree.set("parameters/TurnWaistScale/scale", 0)

func _ready():
    m_step_playback = m_animation_tree.get("parameters/Step/playback")
    m_turn_waist_playback = m_animation_tree.get("parameters/TurnWaist/playback")

func _di_name():
    return "WalkingState"

func internal_process(delta: float):
    if Input.is_action_pressed("WalkDirectionDown"):
        m_throttle -= m_throttle_adjust_speed * delta
    if Input.is_action_pressed("WalkDirectionUp"):
        m_throttle += m_throttle_adjust_speed * delta
    m_throttle = max(-1, min(1, m_throttle))

#    if Input.is_action_pressed("WalkDirectionLeft"):
#        m_desired_heading_offset -= m_desired_heading_offset_adjust_speed * delta
#    if Input.is_action_pressed("WalkDirectionRight"):
#        m_desired_heading_offset += m_desired_heading_offset_adjust_speed * delta
    if Input.is_action_just_pressed("WalkDirectionLeft"):
        m_desired_heading_offset -= 45.0
    if Input.is_action_just_pressed("WalkDirectionRight"):
        m_desired_heading_offset += 45.0

    var clipped_throttle = get_clipped_throttle()
    var current_walking_node = m_step_playback.get_current_node()
    var currently_walking = (current_walking_node != "Nothing")
    if (!currently_walking) and (clipped_throttle != 0):
        m_step_playback.travel("StepRight")
    elif currently_walking and (clipped_throttle == 0):
        m_step_playback.travel("Nothing")

    var current_grounded_foot_position: Vector2
    if m_placed_foot == 1:
        current_grounded_foot_position = m_right_foot.global_position
    else:
        current_grounded_foot_position = m_left_foot.global_position
    # Need to move the body such that the current grounded foot position is at m_grounded_foot_position
    # Solve for X s.t. body.global_transform * X * (body.global_transform.inv() * current_grounded_foot_position) = m_grounded_foot_position
    # body.global_transform.inv() * m_grounded_foot_position * (body.global_transform.inv() * current_grounded_foot_position).inv()
    # For now just do position rather than any rotation
    var body_offset = -m_character_body.global_position + m_grounded_foot_position - (-m_character_body.global_position + current_grounded_foot_position)
    m_character_body.move_and_collide(body_offset)

func apply_waist_rotation_to_body():
    var waist_position = m_waist.global_position
    var left_foot_position = m_left_foot.global_position
    var right_foot_position = m_right_foot.global_position

    var waist_rotation = m_waist.global_rotation
    m_character_body.rotation = waist_rotation
    m_waist.rotation = waist_rotation

#    var waist_rotation = m_waist.rotation
#    m_waist.rotation = 0
#    m_character_body.rotation += waist_rotation

    #m_waist.global_position = waist_position
    #m_left_foot.rotation = 0
    #m_left_foot.global_position = left_foot_position
    #m_right_foot.rotation = 0
    #m_right_foot.global_position = right_foot_position

func get_clipped_throttle():
    if abs(m_throttle) < m_throttle_dead_zone:
        return 0
    return m_throttle