extends Node
class_name PlayerController

var m_animation_tree: AnimationTree
var m_move_anim_node: AnimationNodeStateMachine
var m_move_playback: AnimationNodeStateMachinePlayback
var m_attack_anim_node: AnimationNodeStateMachine
var m_attack_playback: AnimationNodeStateMachinePlayback

# Called when the node enters the scene tree for the first time.
func _ready():
	var context = DIContext.get_nearest(self)
	m_animation_tree = context.get_registered_node("AnimationTree")
	var root = m_animation_tree.tree_root
	m_move_anim_node = root.get_node("Move").get("parameters/playback")
	m_move_playback = m_animation_tree.get("parameters/Move/playback")
	m_attack_anim_node = root.get_node("Attack").get("parameters/playback")
	m_attack_playback = m_animation_tree.get("parameters/Attack/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("Attack"):
		print("ATT")
		#m_attack_anim_node.travel("Punch")
		m_attack_playback.travel("Punch")
	if Input.is_action_just_pressed("Walk"):
		m_move_playback.travel("Walk")
	elif Input.is_action_just_released("Walk"):
		m_move_playback.travel("RESET")
