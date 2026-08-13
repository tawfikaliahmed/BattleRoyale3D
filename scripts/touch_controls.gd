extends CanvasLayer

signal move_input(vector: Vector2)
signal look_input(vector: Vector2)
signal shoot_pressed(pressed: bool)
signal jump_pressed(pressed: bool)
signal reload_pressed(pressed: bool)
signal sprint_pressed(pressed: bool)

@onready var left_stick_base: Control = $LeftStickBase
@onready var left_stick_knob: Control = $LeftStickBase/Knob
@onready var right_pad: Control = $RightPad
@onready var btn_shoot: TouchScreenButton = $Buttons/Shoot
@onready var btn_jump: TouchScreenButton = $Buttons/Jump
@onready var btn_reload: TouchScreenButton = $Buttons/Reload
@onready var btn_sprint: TouchScreenButton = $Buttons/Sprint

var left_touch_index: int = -1
var right_touch_index: int = -1
var left_origin: Vector2 = Vector2.ZERO
var max_stick_distance: float = 80.0

func _ready() -> void:
	btn_shoot.pressed.connect(func(): shoot_pressed.emit(true))
	btn_shoot.released.connect(func(): shoot_pressed.emit(false))
	btn_jump.pressed.connect(func(): jump_pressed.emit(true))
	btn_jump.released.connect(func(): jump_pressed.emit(false))
	btn_reload.pressed.connect(func(): reload_pressed.emit(true))
	btn_reload.released.connect(func(): reload_pressed.emit(false))
	btn_sprint.pressed.connect(func(): sprint_pressed.emit(true))
	btn_sprint.released.connect(func(): sprint_pressed.emit(false))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	var pos = event.position
	if event.pressed:
		# Left half = move stick
		if pos.x < get_viewport().size.x * 0.45 and left_touch_index == -1:
			left_touch_index = event.index
			left_origin = left_stick_base.global_position + left_stick_base.size / 2
			left_stick_base.visible = true
			left_stick_base.global_position = pos - left_stick_base.size / 2
			left_origin = pos
		# Right half = look
		elif pos.x > get_viewport().size.x * 0.55 and right_touch_index == -1:
			right_touch_index = event.index
	else:
		if event.index == left_touch_index:
			left_touch_index = -1
			left_stick_knob.position = left_stick_base.size / 2 - left_stick_knob.size / 2
			move_input.emit(Vector2.ZERO)
		if event.index == right_touch_index:
			right_touch_index = -1
			look_input.emit(Vector2.ZERO)

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == left_touch_index:
		var delta = event.position - left_origin
		var clamped = delta.limit_length(max_stick_distance)
		left_stick_knob.position = left_stick_base.size / 2 - left_stick_knob.size / 2 + clamped
		var input_vec = clamped / max_stick_distance
		# Invert Y for forward
		move_input.emit(Vector2(input_vec.x, -input_vec.y))
	elif event.index == right_touch_index:
		var sensitivity = 0.4
		look_input.emit(event.relative * sensitivity)
