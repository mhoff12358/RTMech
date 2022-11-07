
func run_script(lib: AnimationLibrary):
    var animation_names = lib.get_animation_list()
    for name in animation_names:
        var right_name_str: String = String(name)
        if right_name_str.contains("Right"):
            print("Working on anim: ", right_name_str)
            var right_anim = lib.get_animation(name)
            var left_anim: Animation
            var left_name_str = right_name_str.replace("Right", "Left")
            var left_name = StringName(left_name_str)
            if lib.has_animation(left_name):
                left_anim = lib.get_animation(left_name)
            else:
                left_anim = Animation.new()
                lib.add_animation(left_name, left_anim)
            while left_anim.get_track_count() != 0:
                left_anim.remove_track(0)
            left_anim.length = right_anim.length
            left_anim.loop_mode = right_anim.loop_mode
            left_anim.step = right_anim.step
            for i in range(0, right_anim.get_track_count()):
                right_anim.copy_track(i, left_anim)
                var track_path = String(left_anim.track_get_path(i))
                left_anim.track_set_path(i, track_path.replace("Right", "Left"))
                var track_type = left_anim.track_get_type(i)
                if track_type == Animation.TYPE_VALUE:
                    if track_path.ends_with(":position"):
                        var key_indices = left_anim.value_track_get_key_indices(i, left_anim.length, left_anim.length)
                        for k in key_indices:
                            var position = left_anim.track_get_key_value(i, k)
                            position.y = -position.y
                            left_anim.track_set_key_value(i, k, position)

                elif track_type == Animation.TYPE_METHOD:
                    var key_indices = left_anim.method_track_get_key_indices(i, left_anim.length, left_anim.length)
                    var keys = []
                    for k in key_indices:
                        #var new_method_name = String(left_anim.method_track_get_name(i, k)).replace("right", "left")
                        var method_dict = left_anim.track_get_key_value(i, k)
                        method_dict["method"] = StringName(String(method_dict["method"]).replace("right", "left"))
                        print("method name change: ", method_dict["method"])
                        keys.push_back([left_anim.track_get_key_time(i, k), method_dict, left_anim.track_get_key_transition(i, k)])
                        
                    for k in key_indices:
                        left_anim.track_remove_key(i, k)
                        
                    for key in keys:
                        left_anim.track_insert_key(i, key[0], key[1], key[2])


    ResourceSaver.save(lib, lib.resource_path)