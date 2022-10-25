
@export var num_missiles: int
var fire_right_side_next: bool 

func fire_missile(playback: AnimationNodeStateMachinePlayback):
    print("Fire missile ",  num_missiles)
    num_missiles -= 1
    #playback.travel("FireRightMissilePrep")
    #playback.travel("End")
    if num_missiles == 0:
        playback.travel("End")
    else:
        playback.travel("FireRightMissilePrep")