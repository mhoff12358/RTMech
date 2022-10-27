
static func run_script(lib: AnimationLibrary):
    var animation_names = lib.get_animation_list()
    for name in animation_names:
        var right_name_str: String = String(name)
        if right_name_str.contains("Right"):
            var right_anim = lib.get_animation(name)
            var left_anim: Animation
            var left_name_str = right_name_str.replace("Right", "Left")
            var left_name = StringName(left_name_str)
            if lib.has_animation(left_name):
                left_anim = lib.get_animation(left_name)
            else:
                left_anim = Animation.new()
            for property in right_anim._get_property_list():
                left_anim._set(property.name, right_anim._get(property.name))
            lib.add_animation(left_name, left_anim)