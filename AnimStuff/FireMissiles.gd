
@export var num_missiles: int
var fire_right_side_next: bool 

func fire_missile(
    playback: AnimationNodeStateMachinePlayback,
    game_content: Node2D,
    missile_scene: PackedScene,
    launcher_transform: Transform2D):
    print("Fire missile ",  num_missiles)
    num_missiles -= 1

    var new_missile: Node2D = missile_scene.instantiate()
    game_content.add_child(new_missile)
    new_missile.transform = launcher_transform

    if num_missiles == 0:
        playback.travel("End")
    else:
        if String(playback.get_current_node()).contains("Left"):
            playback.travel("FireRightMissilePrep")
        else:
            playback.travel("FireLeftMissilePrep")