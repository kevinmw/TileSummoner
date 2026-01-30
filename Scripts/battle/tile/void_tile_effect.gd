extends Node2D
class_name VoidTileEffect

## 虚空地块特效
## 显示虚空地块的视觉效果：旋转符文环、裂缝线条、脉冲光晕


# ============ 信号 ============

## 入场动画完成
signal intro_completed()

## 退出动画完成
signal outro_completed()


# ============ 导出变量 ============

## 虚空颜色
@export var void_color: Color = Color(0.42, 0.30, 0.60)

## 脉冲持续时间（秒）
@export var pulse_duration: float = 2.0

## 符文旋转速度（弧度/秒）
@export var rune_rotation_speed: float = 0.628  # 约10秒一圈

## 裂缝线颜色
@export var crack_line_color: Color = Color(0.58, 0.44, 0.86, 0.6)

## 特效尺寸
@export var effect_size: Vector2 = Vector2(80, 80)


# ============ 内部状态 ============

## 是否正在播放动画
var _is_playing: bool = false

## 是否正在播放退出动画
var _is_outro_playing: bool = false

## Tween 引用
var _tween: Tween = null

## 脉冲 Tween
var _pulse_tween: Tween = null

## 旋转 Tween
var _rotation_tween: Tween = null


# ============ 子节点引用 ============

## 符文环
var _rune_ring: Sprite2D = null

## 裂缝线条
var _crack_lines: Line2D = null

## 脉冲光晕
var _pulse_glow: PointLight2D = null

## 虚空图标
var _void_icon: Sprite2D = null


# ============ 生命周期 ============

func _ready() -> void:
	_setup_components()
	_apply_colors()


func _exit_tree() -> void:
	_stop_all_tweens()


func _process(delta: float) -> void:
	if _is_playing and _rune_ring:
		_rune_ring.rotation += rune_rotation_speed * delta


# ============ 初始化 ============

## 设置组件
func _setup_components() -> void:
	# 尝试获取现有子节点
	if has_node("RuneRing"):
		_rune_ring = $RuneRing
	if has_node("CrackLines"):
		_crack_lines = $CrackLines
	if has_node("PulseGlow"):
		_pulse_glow = $PulseGlow
	if has_node("VoidIcon"):
		_void_icon = $VoidIcon

	# 如果没有子节点，创建程序化组件
	if not _rune_ring:
		_create_rune_ring()
	if not _crack_lines:
		_create_crack_lines()
	if not _pulse_glow:
		_create_pulse_glow()


## 创建符文环
func _create_rune_ring() -> void:
	_rune_ring = Sprite2D.new()
	_rune_ring.name = "RuneRing"
	add_child(_rune_ring)

	# 创建程序化纹理
	var image := _create_ring_image()
	_rune_ring.texture = ImageTexture.create_from_image(image)
	_rune_ring.modulate = void_color


## 创建裂缝线条
func _create_crack_lines() -> void:
	_crack_lines = Line2D.new()
	_crack_lines.name = "CrackLines"
	add_child(_crack_lines)

	# 创建随机裂缝图案
	var half_size := effect_size / 2
	var points: PackedVector2Array = []

	# 从中心向四个角延伸的裂缝
	points.append(Vector2.ZERO)
	points.append(Vector2(-half_size.x * 0.7, -half_size.y * 0.5))
	points.append(Vector2.ZERO)
	points.append(Vector2(half_size.x * 0.6, -half_size.y * 0.7))
	points.append(Vector2.ZERO)
	points.append(Vector2(half_size.x * 0.8, half_size.y * 0.4))
	points.append(Vector2.ZERO)
	points.append(Vector2(-half_size.x * 0.5, half_size.y * 0.8))

	_crack_lines.points = points
	_crack_lines.width = 2.0
	_crack_lines.default_color = crack_line_color


## 创建脉冲光晕
func _create_pulse_glow() -> void:
	_pulse_glow = PointLight2D.new()
	_pulse_glow.name = "PulseGlow"
	add_child(_pulse_glow)

	_pulse_glow.color = void_color
	_pulse_glow.energy = 0.5
	_pulse_glow.texture_scale = effect_size.x / 128.0  # 假设默认纹理128x128


## 创建环形图像
func _create_ring_image() -> Image:
	var size := int(effect_size.x)
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	@warning_ignore("integer_division")
	var center := Vector2(size / 2, size / 2)
	@warning_ignore("integer_division")
	var outer_radius := size / 2 - 4
	var inner_radius := outer_radius - 8

	for y in range(size):
		for x in range(size):
			var pos := Vector2(x, y)
			var dist := pos.distance_to(center)

			if dist >= inner_radius and dist <= outer_radius:
				# 添加一些虚线效果
				var angle := pos.angle_to_point(center)
				var segment := int(angle * 8 / TAU)
				if segment % 2 == 0:
					image.set_pixel(x, y, Color.WHITE)
				else:
					image.set_pixel(x, y, Color(1, 1, 1, 0.3))
			else:
				image.set_pixel(x, y, Color.TRANSPARENT)

	return image


# ============ 颜色配置 ============

## 应用颜色
func _apply_colors() -> void:
	if _rune_ring:
		_rune_ring.modulate = void_color
	if _crack_lines:
		_crack_lines.default_color = crack_line_color
	if _pulse_glow:
		_pulse_glow.color = void_color


## 设置虚空颜色
func set_void_color(color: Color) -> void:
	void_color = color
	_apply_colors()


## 设置裂缝颜色
func set_crack_color(color: Color) -> void:
	crack_line_color = color
	if _crack_lines:
		_crack_lines.default_color = color


## 设置尺寸
func set_size(size: Vector2) -> void:
	effect_size = size
	# 重新创建组件以适应新尺寸
	_setup_components()


# ============ 动画控制 ============

## 播放入场动画
func play_intro() -> void:
	_stop_all_tweens()
	_is_playing = true
	_is_outro_playing = false

	# 淡入效果
	modulate.a = 0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.3)\
		.set_ease(Tween.EASE_OUT)
	_tween.tween_callback(func(): intro_completed.emit())

	# 开始脉冲动画
	_start_pulse_animation()


## 播放退出动画
func play_outro() -> void:
	_is_outro_playing = true

	_stop_all_tweens()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.3)\
		.set_ease(Tween.EASE_IN)
	_tween.tween_callback(func():
		_is_playing = false
		_is_outro_playing = false
		outro_completed.emit()
	)


## 停止动画
func stop() -> void:
	_stop_all_tweens()
	_is_playing = false
	_is_outro_playing = false


## 停止所有 Tween
func _stop_all_tweens() -> void:
	if _tween:
		_tween.kill()
		_tween = null
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	if _rotation_tween:
		_rotation_tween.kill()
		_rotation_tween = null


## 开始脉冲动画
func _start_pulse_animation() -> void:
	if not _pulse_glow:
		return

	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_property(_pulse_glow, "energy", 0.8, pulse_duration / 2)\
		.set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(_pulse_glow, "energy", 0.3, pulse_duration / 2)\
		.set_ease(Tween.EASE_IN_OUT)


# ============ 状态查询 ============

## 是否正在播放
func is_playing() -> bool:
	return _is_playing


## 是否正在播放退出动画
func is_outro_playing() -> bool:
	return _is_outro_playing


## 标识为虚空特效（用于识别和清理）
func is_void_effect() -> bool:
	return true


# ============ 组件访问器 ============

## 获取符文环
func get_rune_ring() -> Sprite2D:
	return _rune_ring


## 获取裂缝线条
func get_crack_lines() -> Line2D:
	return _crack_lines


## 获取脉冲光晕
func get_pulse_glow() -> PointLight2D:
	return _pulse_glow
