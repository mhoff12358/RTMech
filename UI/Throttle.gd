extends DIContext
class_name Throttle

@onready var m_top_position: Control = get_registered_node_with_id("Control", "TopPosition")
@onready var m_bottom_position: Control = get_registered_node_with_id("Control", "BottomPosition")
@onready var m_handle: Control = get_registered_node_with_id("Control", "Handle")

func _ready():
    var game_context: DIContext = get_registered_node_with_id("DIContext", "GameContext")
    print("gc: ", game_context)
    game_context.get_registered_node("WalkingState").throttle_changed.connect(apply_throttle)

func apply_throttle(value: float):
    print("lerping: ", value)
    var top_position = m_top_position.global_position
    var bottom_position = m_bottom_position.global_position
    m_handle.global_position = bottom_position + (top_position - bottom_position) * value 