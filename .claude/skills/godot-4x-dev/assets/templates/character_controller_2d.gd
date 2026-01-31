# 2D 平台跳跃角色控制器模板
# 使用方法：创建 CharacterBody2D 场景，附加此脚本
class_name PlatformCharacter2D
extends CharacterBody2D

## 信号
signal jumped
signal landed
signal died

## 移动参数
@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
@export var air_acceleration: float = 800.0
@export var air_friction: float = 200.0

## 跳跃参数
@export_group("Jump")
@export var jump_force: float = -400.0
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.5
@export var max_fall_speed: float = 600.0
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

## 内部变量
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false

## 节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	_handle_jump()
	_handle_horizontal_movement(delta)
	move_and_slide()
	_update_animations()
	_check_landing()


func _update_timers(delta: float) -> void:
	# Coyote time - 离开平台后短暂允许跳跃
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	# Jump buffer - 落地前按跳跃会在落地时触发
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		# 下落时增加重力
		var gravity_scale := fall_gravity_multiplier if velocity.y > 0 else 1.0
		velocity.y += gravity * gravity_scale * delta
		velocity.y = minf(velocity.y, max_fall_speed)


func _handle_jump() -> void:
	var can_jump := is_on_floor() or _coyote_timer > 0
	var want_jump := Input.is_action_just_pressed("jump") or _jump_buffer_timer > 0

	if can_jump and want_jump:
		velocity.y = jump_force
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
		jumped.emit()

	# 可变跳跃高度 - 松开跳跃键减少上升
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5


func _handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	var current_accel := acceleration if is_on_floor() else air_acceleration
	var current_friction := friction if is_on_floor() else air_friction

	if direction:
		velocity.x = move_toward(velocity.x, direction * move_speed, current_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_friction * delta)


func _update_animations() -> void:
	# 翻转精灵
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

	# 播放动画
	if not is_on_floor():
		if velocity.y < 0:
			_play_animation("jump")
		else:
			_play_animation("fall")
	elif abs(velocity.x) > 10:
		_play_animation("run")
	else:
		_play_animation("idle")


func _play_animation(anim_name: String) -> void:
	if anim and anim.has_animation(anim_name):
		if anim.current_animation != anim_name:
			anim.play(anim_name)


func _check_landing() -> void:
	if is_on_floor() and not _was_on_floor:
		landed.emit()
	_was_on_floor = is_on_floor()


## 公共方法

func take_damage(amount: int) -> void:
	# 实现伤害逻辑
	pass


func die() -> void:
	died.emit()
	# 实现死亡逻辑


func set_input_enabled(enabled: bool) -> void:
	set_physics_process(enabled)
