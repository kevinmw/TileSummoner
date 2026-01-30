class_name TestVoidTileEffect
extends GdUnitTestSuite

## VoidTileEffect 测试套件
## 测试范围：
## 1. 组件实例化
## 2. 动画播放
## 3. 颜色配置
## 4. 特效标识


# ============ 辅助方法 ============

## 创建测试用 VoidTileEffect 实例
func _create_void_effect() -> VoidTileEffect:
	var effect := VoidTileEffect.new()
	add_child(effect)
	auto_free(effect)
	return effect


# ============ 基础属性测试 ============

## 测试1：VoidTileEffect 可以实例化
func test_void_effect_instantiation() -> void:
	var effect := _create_void_effect()

	assert_that(effect).is_not_null()
	assert_that(effect).is_instanceof(VoidTileEffect)


## 测试2：默认虚空颜色
func test_default_void_color() -> void:
	var effect := _create_void_effect()

	# 预期紫色系
	assert_that(effect.void_color.r).is_greater(0.3)
	assert_that(effect.void_color.b).is_greater(0.3)


## 测试3：默认脉冲持续时间
func test_default_pulse_duration() -> void:
	var effect := _create_void_effect()

	assert_that(effect.pulse_duration).is_equal(2.0)


## 测试4：默认符文旋转速度
func test_default_rune_rotation_speed() -> void:
	var effect := _create_void_effect()

	# 约 0.628 rad/s (10秒一圈)
	assert_that(effect.rune_rotation_speed).is_greater(0.5)
	assert_that(effect.rune_rotation_speed).is_less(1.0)


# ============ 特效标识测试 ============

## 测试5：is_void_effect 方法返回 true
func test_is_void_effect_returns_true() -> void:
	var effect := _create_void_effect()

	assert_that(effect.is_void_effect()).is_true()


# ============ 颜色配置测试 ============

## 测试6：设置自定义虚空颜色
func test_set_custom_void_color() -> void:
	var effect := _create_void_effect()
	var custom_color := Color(0.8, 0.2, 0.5)

	effect.set_void_color(custom_color)

	assert_that(effect.void_color).is_equal(custom_color)


## 测试7：设置裂缝线颜色
func test_set_crack_line_color() -> void:
	var effect := _create_void_effect()
	var custom_color := Color(0.7, 0.5, 0.9, 0.8)

	effect.set_crack_color(custom_color)

	assert_that(effect.crack_line_color).is_equal(custom_color)


# ============ 动画测试 ============

## 测试8：播放入场动画
func test_play_intro_animation() -> void:
	var effect := _create_void_effect()

	# 不应抛出异常
	effect.play_intro()

	# 等待一帧确保动画开始
	await await_idle_frame()
	assert_that(effect.is_playing()).is_true()


## 测试9：停止动画
func test_stop_animation() -> void:
	var effect := _create_void_effect()
	effect.play_intro()
	await await_idle_frame()

	effect.stop()

	assert_that(effect.is_playing()).is_false()


## 测试10：播放退出动画
func test_play_outro_animation() -> void:
	var effect := _create_void_effect()

	effect.play_outro()
	await await_idle_frame()

	# 退出动画应该开始播放
	assert_that(effect.is_outro_playing()).is_true()


# ============ 组件检查测试 ============

## 测试11：符文环组件存在
func test_rune_ring_exists() -> void:
	var effect := _create_void_effect()

	assert_that(effect.has_node("RuneRing") or effect.get_rune_ring() != null).is_true()


## 测试12：裂缝线组件存在
func test_crack_lines_exists() -> void:
	var effect := _create_void_effect()

	assert_that(effect.has_node("CrackLines") or effect.get_crack_lines() != null).is_true()


## 测试13：脉冲光晕组件存在
func test_pulse_glow_exists() -> void:
	var effect := _create_void_effect()

	assert_that(effect.has_node("PulseGlow") or effect.get_pulse_glow() != null).is_true()


# ============ 尺寸配置测试 ============

## 测试14：设置特效尺寸
func test_set_effect_size() -> void:
	var effect := _create_void_effect()
	var custom_size := Vector2(100, 100)

	effect.set_size(custom_size)

	assert_that(effect.effect_size).is_equal(custom_size)


## 测试15：默认尺寸为 80x80
func test_default_size() -> void:
	var effect := _create_void_effect()

	assert_that(effect.effect_size).is_equal(Vector2(80, 80))
