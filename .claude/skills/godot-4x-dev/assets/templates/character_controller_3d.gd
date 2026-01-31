# 3D 第一人称角色控制器模板
# 使用方法：创建 CharacterBody3D 场景，附加此脚本
# 场景结构：CharacterBody3D > CollisionShape3D, Head(Node3D) > Camera3D
class_name FirstPersonCharacter3D
extends CharacterBody3D

## 信号
signal jumped
signal landed

## 移动参数
@export_group("Movement")
@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 10.0
@export var air_control: float = 0.3

## 跳跃参数
@export_group("Jump")
@export var jump_force: float = 4.5
@export var gravity: float = 9.8

## 相机参数
@export_group("Camera")
@export var mouse_sensitivity: float = 0.002
@export var max_look_angle: float = 89.0

## 内部变量
var _was_on_floor: bool = false

## 节点引用
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	_handle_mouse_look(event)
	_handle_escape(event)


func _handle_mouse_look(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# 水平旋转 - 旋转整个角色
		rotate_y(-event.relative.x * mouse_sensitivity)

		# 垂直旋转 - 只旋转头部
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(
			head.rotation.x,
			deg_to_rad(-max_look_angle),
			deg_to_rad(max_look_angle)
		)


func _handle_escape(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	move_and_slide()
	_check_landing()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		jumped.emit()


func _handle_movement(delta: float) -> void:
	# 获取输入方向
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# 相对于角色方向
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# 选择速度（冲刺或普通）
	var target_speed := sprint_speed if Input.is_action_pressed("sprint") else move_speed

	# 空中控制减弱
	var current_accel := acceleration
	if not is_on_floor():
		current_accel *= air_control

	# 应用移动
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * target_speed, current_accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * target_speed, current_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_accel * delta)
		velocity.z = move_toward(velocity.z, 0, current_accel * delta)


func _check_landing() -> void:
	if is_on_floor() and not _was_on_floor:
		landed.emit()
	_was_on_floor = is_on_floor()


## 公共方法

func get_look_direction() -> Vector3:
	return -camera.global_transform.basis.z


func get_movement_direction() -> Vector3:
	return velocity.normalized() if velocity.length() > 0.1 else Vector3.ZERO
