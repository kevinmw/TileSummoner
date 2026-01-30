class_name TestBattleBackground
extends GdUnitTestSuite

## BattleBackground 测试套件
## 测试范围：
## 1. 背景层级配置
## 2. 星空粒子生成
## 3. 网格线绘制
## 4. 颜色配置


# ============ 辅助方法 ============

## 创建测试用 BattleBackground 实例
func _create_background() -> BattleBackground:
	var bg := BattleBackground.new()
	add_child(bg)
	auto_free(bg)
	return bg


# ============ 基础属性测试 ============

## 测试1：BattleBackground 可以实例化
func test_background_instantiation() -> void:
	var bg := _create_background()

	assert_that(bg).is_not_null()
	assert_that(bg).is_instanceof(BattleBackground)


## 测试2：背景为 CanvasLayer 类型
func test_background_is_canvas_layer() -> void:
	var bg := _create_background()

	assert_that(bg).is_instanceof(CanvasLayer)


## 测试3：背景层级为 -1
func test_background_layer_is_negative() -> void:
	var bg := _create_background()

	assert_that(bg.layer).is_less(0)


# ============ 颜色配置测试 ============

## 测试4：默认背景颜色配置
func test_default_background_colors() -> void:
	var bg := _create_background()

	assert_that(bg.bg_color_top).is_not_null()
	assert_that(bg.bg_color_mid).is_not_null()
	assert_that(bg.bg_color_bottom).is_not_null()


## 测试5：设置自定义背景颜色
func test_set_custom_background_colors() -> void:
	var bg := _create_background()
	var custom_top := Color(0.1, 0.1, 0.2)
	var custom_mid := Color(0.15, 0.1, 0.15)
	var custom_bottom := Color(0.1, 0.1, 0.15)

	bg.set_background_colors(custom_top, custom_mid, custom_bottom)

	assert_that(bg.bg_color_top).is_equal(custom_top)
	assert_that(bg.bg_color_mid).is_equal(custom_mid)
	assert_that(bg.bg_color_bottom).is_equal(custom_bottom)


## 测试6：默认光晕颜色配置
func test_default_glow_colors() -> void:
	var bg := _create_background()

	assert_that(bg.glow_void).is_not_null()
	assert_that(bg.glow_mana).is_not_null()
	assert_that(bg.glow_gold).is_not_null()


# ============ 网格线测试 ============

## 测试7：默认网格线颜色
func test_default_grid_line_color() -> void:
	var bg := _create_background()

	assert_that(bg.grid_line_color).is_not_null()
	# 应该是低透明度的金色
	assert_that(bg.grid_line_color.a).is_less(0.1)


## 测试8：默认网格线间距
func test_default_grid_line_spacing() -> void:
	var bg := _create_background()

	assert_that(bg.grid_line_spacing).is_equal(50)


## 测试9：设置网格线参数
func test_set_grid_line_params() -> void:
	var bg := _create_background()
	var custom_color := Color(0.5, 0.5, 0.5, 0.1)
	var custom_spacing := 100

	bg.set_grid_line_params(custom_color, custom_spacing)

	assert_that(bg.grid_line_color).is_equal(custom_color)
	assert_that(bg.grid_line_spacing).is_equal(custom_spacing)


# ============ 星空粒子测试 ============

## 测试10：默认星点数量
func test_default_star_count() -> void:
	var bg := _create_background()

	assert_that(bg.star_count).is_equal(100)


## 测试11：星点尺寸范围
func test_star_size_range() -> void:
	var bg := _create_background()

	assert_that(bg.star_size_min).is_less(bg.star_size_max)
	assert_that(bg.star_size_min).is_greater(0)


## 测试12：星点闪烁范围
func test_star_twinkle_range() -> void:
	var bg := _create_background()

	assert_that(bg.star_twinkle_min).is_less(bg.star_twinkle_max)
	assert_that(bg.star_twinkle_min).is_greater(0)


## 测试13：设置星点参数
func test_set_star_params() -> void:
	var bg := _create_background()

	bg.set_star_params(200, 0.5, 4.0, 1.0, 5.0)

	assert_that(bg.star_count).is_equal(200)
	assert_that(bg.star_size_min).is_equal(0.5)
	assert_that(bg.star_size_max).is_equal(4.0)


# ============ 组件存在测试 ============

## 测试14：背景渐变组件存在
func test_cosmic_background_exists() -> void:
	var bg := _create_background()
	await await_idle_frame()

	var cosmic_bg := bg.get_cosmic_background()
	assert_that(cosmic_bg != null or bg.has_node("CosmicBackground")).is_true()


## 测试15：星空粒子组件存在
func test_starfield_exists() -> void:
	var bg := _create_background()
	await await_idle_frame()

	var starfield := bg.get_starfield()
	assert_that(starfield != null or bg.has_node("Starfield")).is_true()


## 测试16：网格线覆盖层存在
func test_grid_overlay_exists() -> void:
	var bg := _create_background()
	await await_idle_frame()

	var grid_overlay := bg.get_grid_overlay()
	assert_that(grid_overlay != null or bg.has_node("GridLinesOverlay")).is_true()


# ============ 尺寸配置测试 ============

## 测试17：设置视口尺寸
func test_set_viewport_size() -> void:
	var bg := _create_background()
	var custom_size := Vector2(1920, 1080)

	bg.set_viewport_size(custom_size)
	await await_idle_frame()

	assert_that(bg.viewport_size).is_equal(custom_size)


## 测试18：默认视口尺寸
func test_default_viewport_size() -> void:
	var bg := _create_background()

	# 默认应为项目设置的窗口尺寸或合理默认值
	assert_that(bg.viewport_size.x).is_greater(0)
	assert_that(bg.viewport_size.y).is_greater(0)


# ============ 动画控制测试 ============

## 测试19：开始星空动画
func test_start_starfield_animation() -> void:
	var bg := _create_background()
	await await_idle_frame()

	bg.start_animations()

	assert_that(bg.is_animating()).is_true()


## 测试20：停止星空动画
func test_stop_starfield_animation() -> void:
	var bg := _create_background()
	await await_idle_frame()
	bg.start_animations()

	bg.stop_animations()

	assert_that(bg.is_animating()).is_false()
