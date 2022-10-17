#Taken from https://gist.github.com/cgbeutler/9d4134e7937b211927f969c0ad3b01f0 but updated for godot 4

@tool
class_name ShapePolygon2D
extends Polygon2D

func _get_configuration_warning() -> String:
	if shape == null:
		return "Shape resource is null"
	if shape is ConvexPolygonShape2D and len(shape.points) <= 1:
		return "ConvexPolygonShape2D has too few points to draw"
	if shape is ConcavePolygonShape2D:
		if len(shape.segments) <= 1:
			return "ConcavePolygonShape2D has too few points to draw"
		if len(shape.segments) > 2:
			for i in range(2, len(shape.segments), 2):
				if shape.segments[i].distance_squared_to(shape.segments[i-1]) > 0.01:
					return "ConcavePolygonShape2D segments are disconnected. It will not be displayed properly."
	return ""

@export var shape: Shape2D:
	set(value):
		set_shape(value)
	get:
		return m_shape
var m_shape: Shape2D = null 

func set_shape( value :Shape2D ):
	if shape == value:
		queue_redraw()
		return
	if shape != null:
		shape.changed.disconnect(self.__on_shape_changed)
		#shape.disconnect("changed", self, "__on_shape_changed")
	m_shape = value
	if shape != null:
		shape.changed.connect(self.__on_shape_changed)
		#shape.connect("changed", self, "__on_shape_changed")
	__on_shape_changed()

func __on_shape_changed():
	update_configuration_warnings()
	polygon = PackedVector2Array()
	if shape == null:  return
	elif shape is CapsuleShape2D:  polygon = capsule(shape.radius, shape.height)
	elif shape is ConvexPolygonShape2D:  polygon = shape.points
	elif shape is SeparationRayShape2D:  polygon = arrow(shape.length)
	elif shape is CircleShape2D:  polygon = circle(shape.radius)
	elif shape is RectangleShape2D:  polygon = rectangle(shape.extents)
	elif shape is ConcavePolygonShape2D:  polygon = concave_to_polygons(shape.segments)
	elif shape is SegmentShape2D:  polygon = segment(shape.a, shape.b)
	#elif shape is LineShape2D:  polygon = line_to_polygon(shape.normal, shape.d)
	else:  push_error("Unknown shape")
	queue_redraw()


#### Helper functions ####

static func circle( radius :float = 1.0, center :Vector2 = Vector2.ZERO ) -> PackedVector2Array:
	var segments :int = int(4*floor(radius/32.0)+16)
	var points = [];  points.resize(segments+1)
	var segment_size = TAU / segments
	for i in range(segments):
		points[i] = Vector2( cos(i * segment_size) * radius + center.x, sin(i * segment_size) * radius + center.y )
	points[segments] = points[0]
	print("Points: " + len(points))
	return PackedVector2Array(points)


static func rectangle( extents :Vector2 ) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-extents.x,-extents.y), Vector2(extents.x,-extents.y),
		Vector2(extents.x,extents.y), Vector2(-extents.x,extents.y),
	])


static func capsule( radius :float, height :float ) -> PackedVector2Array:
	radius = clamp(radius, 0.5, INF)
	height = clamp(height, 0.0, INF)
	var hheight = clamp( height / 2.0, 0, INF )
	var cap_circle :PackedVector2Array = circle( radius )
	
	var points := [];  points.resize(len(cap_circle) + 2)
	
	var arch_count = int((len(cap_circle) / 2.0) + 1)
	for i in range( arch_count ):
		points[i] = cap_circle[i] + Vector2(0,hheight)
	
	for i in range( arch_count - 1, len(cap_circle) ):
		points[i + 1] = cap_circle[i] + Vector2(0,-hheight)
	points[-1] = points[0]
	return PackedVector2Array(points)


static func arrow( length :float ):
	length = 1.0  if is_zero_approx(length) else  clamp(abs(length),1.0,INF) *sign(length)
	var tip := Vector2.DOWN * length
	var head_dw = clamp(length * 0.1, 1, 4)
	var head_dh = clamp(length * 0.2, 2, 8)
	return PackedVector2Array([
		tip + Vector2(-0.51, -head_dh), Vector2(-0.51,0.0), Vector2(0.51,0.0), tip + Vector2(0.51, -head_dh), # stem
		tip + Vector2(head_dw, -head_dh), tip, tip + Vector2(-head_dw, -head_dh), # head
	])

# NOTE: This ignores holes and disconnected areas and just renders the first string of connected segments one polygon
static func concave_to_polygons( p_segments :PackedVector2Array ) -> PackedVector2Array:
	if not len(p_segments):  return PackedVector2Array()
	var result := PackedVector2Array([p_segments[0]])
	for i in range(1, len(p_segments)):
		if (i%2):  #segment tail
			result.push_back(p_segments[i])
		else:  #segment head
			if p_segments[i].distance_squared_to(p_segments[i-1]) > 0.01:
				result.push_back(p_segments[i])  # disjoint segment started
	return result

static func segment( a :Vector2, b :Vector2 ):
	var hthick := (a-b).rotated(PI / 2.0).normalized() * 0.51
	return PackedVector2Array([
		a + hthick, b + hthick, b - hthick, a - hthick
	])

static func line_to_polygon( normal :Vector2, d :float ) -> PackedVector2Array:
	normal = normal.normalized()
	var tangent := normal.rotated(PI / 2.0) * 2048.0
	return PackedVector2Array([
		tangent + (normal*d), -tangent + (normal*d),
		-tangent + (normal*(d-1.01)), tangent + (normal*(d-1.01)),
	])
