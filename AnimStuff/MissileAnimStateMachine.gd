extends AnimationNodeStateMachine

func _get_parameter_list():
    var params = super._get_parameter_list()
    params.append({
        "name": "fire_missiles",
        "type": 24
    })
    print("Adding fire missiles")
    return params