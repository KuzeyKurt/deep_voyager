extends KinematicBody
class_name KinematicAI


# contsant vars

# export vars
export(String, MULTILINE) var sub_state_anim = ''
export(NodePath) var detector_node
export(NodePath) var animator_node
export var speed_move = 1
export var speed_turn = 2 

# onready vars

# private vars
var _delta = 0
var _timer = 0
var _detector = null
var _animator = null
var _animations = {}
var _prev_state = ''
var _prev_sub_state = ''
var _detected = null

# public vars
var state = ''
var sub_state = ''


# system methods
func _ready() -> void:
	if detector_node:
		_detector = get_node(detector_node)
	if animator_node:
		_animator = get_node(animator_node)

	if sub_state_anim:
		var all = sub_state_anim.split('\n')
		for a in all:
			var s = a.split(':')
			_animations[s[0]] = s[1]

	ready()

func _physics_process(delta: float) -> void:
	_delta = delta
	_timer += delta
	if _detector:
		if _detector.is_colliding():
			_detected = _detector.get_collider()
		else:
			_detected = null
	call(state)
	process()



func set_state(s, sub=''):
	_timer = 0
	if state != s:
		_prev_state = state
		state = s
	if sub:
		set_sub_state(sub)


func set_sub_state(sub):
	if sub_state != sub:
		_prev_sub_state = sub_state
		if _animator: 
			_animator.play(_animations[sub], 0.2)
		sub_state = sub


func move_ai():
	move_angle()
	if _detected:
		set_state('tmp_rotate')


func move_angle(add_speed=0):
	move_and_slide(Vector3(0,-5, -(speed_move+add_speed)).rotated(Vector3.UP, rotation.y), Vector3.UP, true, 4, 1, false)

func rotate_to_node(n, add_speed=0):
	var a = global_transform
	var origin = n.global_transform.origin
	origin .y = a.origin.y
	var b = a.looking_at(origin, Vector3.UP)
	global_transform = global_transform.interpolate_with(b, add_speed+speed_turn * _delta)

func distance_to_node(n):
	return global_transform.origin.distance_to(n.global_transform.origin)


# states
func idle(): pass
func move(): pass

func tmp_rotate():
	rotate_y(speed_turn * _delta)
	if !_detected:
		set_state(_prev_state)

#custom methods
func ready(): pass
func process(): pass
