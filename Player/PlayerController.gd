extends Node
class_name PlayerController

var m_character_body: CharacterBody2D

var m_waist: Node2D
var m_torso: Node2D

var m_animation_tree: AnimationTree
var m_move_anim_node: AnimationNodeStateMachine
var m_move_playback: AnimationNodeStateMachinePlayback
var m_attack_anim_node: AnimationNodeStateMachine
var m_attack_playback: AnimationNodeStateMachinePlayback

@export var k_walk_deadzone_sq = 0.1 * 0.1
@export var k_walk_speed = 50
@export var k_waist_turn_speed_deg = 360
@export var k_torso_turn_speed_deg = 360
@export var k_walk_while_turning_angle_deg = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	var context = DIContext.get_nearest(self)

	m_character_body = context.get_registered_node("CharacterBody2D")
	m_waist = context.get_registered_node_with_id("Node2D", "Waist")
	m_torso = context.get_registered_node_with_id("Node2D", "Torso")

	m_animation_tree = context.get_registered_node("AnimationTree")
	m_animation_tree.active = true
	var root = m_animation_tree.tree_root
	m_move_anim_node = root.get_node("Move").get("parameters/playback")
	m_move_playback = m_animation_tree.get("parameters/Move/playback")
	m_attack_anim_node = root.get_node("Attack").get("parameters/playback")
	m_attack_playback = m_animation_tree.get("parameters/Attack/playback")

func _process(delta):
	if Input.is_action_pressed("Attack"):
		print("ATT")
		m_attack_playback.travel("Punch")
	var walk_direction = compute_walk_direction()
	if walk_direction.length_squared() > k_walk_deadzone_sq:
		rotate_towards(m_waist, walk_direction, deg_to_rad(k_waist_turn_speed_deg) * delta)

		if abs(walk_direction.angle_to(Vector2.from_angle(m_waist.rotation))) < deg_to_rad(k_walk_while_turning_angle_deg):
			m_character_body.move_and_collide(walk_direction * k_walk_speed * delta)
			m_move_playback.travel("Walk")
	else:
		m_move_playback.travel("RESET")

	var facing_direction = compute_facing_direction()
	if facing_direction.length_squared() > k_walk_deadzone_sq:
		rotate_towards(m_torso, facing_direction, deg_to_rad(k_torso_turn_speed_deg) * delta)

func rotate_towards(node: Node2D, desired_direction: Vector2, max_turn: float):
	var facing = Vector2.from_angle(node.rotation)
	var desired_angle_change = facing.angle_to(desired_direction)

	var actual_angle_change = min(max_turn, abs(desired_angle_change)) * sign(desired_angle_change)
	node.rotation += actual_angle_change

#	if Input.is_action_just_pressed("Walk"):
#		m_move_playback.travel("Walk")
#	elif Input.is_action_just_released("Walk"):
#		m_move_playback.travel("RESET")

func compute_facing_direction():
	var direction = Vector2.ZERO
	if Input.is_action_pressed("FacingDirectionDown"):
		direction += Vector2.DOWN
	if Input.is_action_pressed("FacingDirectionUp"):
		direction += Vector2.UP
	if Input.is_action_pressed("FacingDirectionLeft"):
		direction += Vector2.LEFT
	if Input.is_action_pressed("FacingDirectionRight"):
		direction += Vector2.RIGHT
	direction = direction.normalized()
	return direction


func compute_walk_direction():
	var direction = Vector2.ZERO
	if Input.is_action_pressed("WalkDirectionDown"):
		direction += Vector2.DOWN
	if Input.is_action_pressed("WalkDirectionUp"):
		direction += Vector2.UP
	if Input.is_action_pressed("WalkDirectionLeft"):
		direction += Vector2.LEFT
	if Input.is_action_pressed("WalkDirectionRight"):
		direction += Vector2.RIGHT
	direction = direction.normalized()
	return direction
