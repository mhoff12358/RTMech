extends Node
class_name PlayerController

const FireMissiles = preload("res://AnimStuff/FireMissiles.gd")

const k_missile_scene: PackedScene = preload("res://Player/Missile.tscn")

var m_character_body: CharacterBody2D

var m_waist: Node2D
var m_torso: Node2D
var m_right_launcher: Node2D
var m_left_launcher: Node2D
var m_right_foot: Node2D
var m_left_foot: Node2D

var m_context: DIContext
var m_game_content: Node2D
var m_animation_tree: AnimationTree
var m_move_anim_node: AnimationNodeStateMachine
var m_move_playback: AnimationNodeStateMachinePlayback
var m_attack_anim_node: AnimationNodeStateMachine
var m_attack_playback: AnimationNodeStateMachinePlayback
var m_fire_missiles_playback: AnimationNodeStateMachinePlayback

var m_walk_playback: AnimationNodeStateMachinePlayback
var m_walk_playback_step_right: AnimationNodeAnimation
var m_walk_playback_step_left: AnimationNodeAnimation

var m_spinny_anim: AnimationNodeAnimation

var m_walk_anim_node: AnimationNode
var m_walk_add: AnimationNodeAdd2

var m_missiles: FireMissiles

var m_footsteps: Footsteps

@export var k_walk_deadzone_sq = 0.1 * 0.1
@export var k_walk_speed = 50
@export var k_waist_turn_speed_deg = 360
@export var k_torso_turn_speed_deg = 360
@export var k_walk_while_turning_angle_deg = 15

@export var m_add_amount: float = 1.0

@export var m_grounded_foot_position: Vector2
@export var m_grounded_foot_is_right = false

var m_was_walking_last_frame = false

# Called when the node enters the scene tree for the first time.
func _ready():
	m_context = DIContext.get_nearest(self)

	m_game_content = m_context.get_registered_node("GameContent")

	m_footsteps = m_context.get_registered_node("Footsteps")

	m_character_body = m_context.get_registered_node("CharacterBody2D")
	m_waist = m_context.get_registered_node_with_id("Node2D", "Waist")
	m_torso = m_context.get_registered_node_with_id("Node2D", "Torso")
	m_right_launcher = m_context.get_registered_node_with_id("Node2D", "RightLauncher")
	m_left_launcher = m_context.get_registered_node_with_id("Node2D", "LeftLauncher")
	m_right_foot = m_context.get_registered_node_with_id("Node2D", "RightFoot")
	m_left_foot = m_context.get_registered_node_with_id("Node2D", "LeftFoot")

	m_animation_tree = m_context.get_registered_node("AnimationTree")
	m_animation_tree.active = true
	var root = m_animation_tree.tree_root
	m_move_anim_node = root.get_node("Move")
	m_move_playback = m_animation_tree.get("parameters/Move/playback")
	m_attack_anim_node = root.get_node("Attack")
	m_attack_playback = m_animation_tree.get("parameters/Attack/playback")
	m_fire_missiles_playback = m_animation_tree.get("parameters/Attack/FireMissiles/playback")
	m_walk_playback = m_animation_tree.get("parameters/Walk/playback")
	m_walk_playback_step_right = root.get_node("Walk").get_node("StepRight")
	m_walk_playback_step_left = root.get_node("Walk").get_node("StepLeft")
	m_spinny_anim = root.get_node("Spinny")

	m_missiles = FireMissiles.new()

	m_walk_anim_node = root.get_node("Walk")
	m_walk_add = root.get_node("AddWalk")

	if m_grounded_foot_is_right:
		m_grounded_foot_position = m_right_foot.global_position
	else:
		m_grounded_foot_position = m_left_foot.global_position

var first = true

func fire_right_missile():
	fire_missile(true)

func fire_left_missile():
	fire_missile(false)

func fire_missile(right_launcher: bool):
	var missile_trans: Transform2D
	if right_launcher:
		missile_trans = m_game_content.global_transform.inverse() * m_right_launcher.global_transform
	else:
		missile_trans = m_game_content.global_transform.inverse() * m_left_launcher.global_transform
	m_missiles.fire_missile(m_fire_missiles_playback, m_game_content, k_missile_scene, missile_trans)

func lift_right_foot():
	place_left_foot()

func place_right_foot():
	m_grounded_foot_is_right = true
	m_grounded_foot_position = m_right_foot.global_position
	m_footsteps.add_step(m_right_foot.global_position)

func lift_left_foot():
	place_right_foot()

func place_left_foot():
	m_grounded_foot_is_right = false
	m_grounded_foot_position = m_left_foot.global_position
	m_footsteps.add_step(m_left_foot.global_position)

func _process(delta):
	#m_animation_tree.set("parameters/AddWalk/add_amount", m_add_amount)

	if first:
		#m_animation_tree.set("parameters/Attack/FireMissiles/fire_missiles", m_missiles)
		#m_attack_anim_node.set_parameter("parameters/Attack/FireMissiles/fire_missiles", m_missiles)
		print("Setting missiles in player")
		first = false

	if Input.is_action_pressed("Attack"):
		m_missiles.num_missiles = 5
		m_attack_playback.travel("FireMissiles")

	var curr_node = m_walk_playback.get_current_node()
	if Input.is_action_pressed("WalkDirectionUp"):
		if curr_node == "StepRight" or curr_node == "StepLeft":
			pass
		else:
			m_walk_playback.travel("StepRight")
	else:
		if curr_node == "StepRight":
			m_walk_playback.start("UnStepRight")
			var reversed_position = m_walk_playback.get_current_length() - m_walk_playback.get_current_play_position()
			#m_animation_tree.set("parameters/Walk/UnStepRight/Animation/time", m_walk_playback.get_current_play_position())
			m_animation_tree.set("parameters/Walk/UnStepRight/Animation/time", 1)
			m_animation_tree.set("parameters/Walk/UnStepRight/Animation/active", true)
			m_animation_tree.set("parameters/Walk/UnStepRight/Animation/prev_active", true)
		elif curr_node == "StepLeft":
			m_walk_playback.start("UnStepLeft")
			var reversed_position = m_walk_playback.get_current_length() - m_walk_playback.get_current_play_position()
			m_animation_tree.set("parameters/Walk/UnStepLeft/Animation/time", m_walk_playback.get_current_play_position())
		elif curr_node == "UnStepRight":
			print(m_animation_tree.get("parameters/Walk/UnStepRight/Animation/time"))

#	if Input.is_action_pressed("WalkDirectionUp"):
#		if curr_node == "StepRight" or curr_node == "StepLeft":
#			pass
#		else:
#			if curr_node == "UnStepLeft":
#				m_walk_playback.travel("StepLeft")
#			else:
#				m_walk_playback.travel("StepRight")
#	else:
#		if curr_node == "StepRight":
#			m_walk_playback.travel("UnStepRight")
#		elif curr_node == "StepLeft":
#			m_walk_playback.travel("UnStepLeft")
	
	var current_grounded_foot_position: Vector2
	if m_grounded_foot_is_right:
		current_grounded_foot_position = m_right_foot.global_position
	else:
		current_grounded_foot_position = m_left_foot.global_position
	# Need to move the body such that the current grounded foot position is at m_grounded_foot_position
	# Solve for X s.t. body.global_transform * X * (body.global_transform.inv() * current_grounded_foot_position) = m_grounded_foot_position
	# body.global_transform.inv() * m_grounded_foot_position * (body.global_transform.inv() * current_grounded_foot_position).inv()
	# For now just do position rather than any rotation
	var body_offset = -m_character_body.global_position + m_grounded_foot_position - (-m_character_body.global_position + current_grounded_foot_position)
	m_character_body.move_and_collide(body_offset)
	

#	var throttle = 0.0
#	if Input.is_action_pressed("WalkDirectionUp"):
#		throttle += 1
#	if Input.is_action_pressed("WalkDirectionDown"):
#		throttle -= 0.5
	

#	var walk_direction = compute_walk_direction()
#	var walking_this_frame = false
#	if walk_direction.length_squared() > k_walk_deadzone_sq:
#		rotate_towards(m_waist, walk_direction, deg_to_rad(k_waist_turn_speed_deg) * delta)
#
#		walking_this_frame = true
#		if !m_was_walking_last_frame:
#			m_animation_tree.set("parameters/Walk/time", 0)
#			m_animation_tree.set("parameters/AddWalk/add_amount", 1)
#
#		if abs(walk_direction.angle_to(Vector2.from_angle(m_waist.rotation))) < deg_to_rad(k_walk_while_turning_angle_deg):
#			m_character_body.move_and_collide(walk_direction * k_walk_speed * delta)
#			m_move_playback.travel("Walk")
#	else:
#		m_move_playback.travel("RESET")
#		m_animation_tree.set("parameters/AddWalk/add_amount", 0)
#	m_was_walking_last_frame = walking_this_frame
#
#	var facing_direction = compute_facing_direction()
#	if facing_direction.length_squared() > k_walk_deadzone_sq:
#		rotate_towards(m_torso, facing_direction, deg_to_rad(k_torso_turn_speed_deg) * delta)

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
