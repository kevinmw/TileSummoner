class_name TestBattleGridContainer
extends GdUnitTestSuite

## BattleGridContainer 测试套件
## 测试范围：
## 1. 实例化
## 2. 尺寸计算
## 3. 绘制调用


# ============ 辅助方法 ============

## 创建测试用容器实例
func _create_container() -> BattleGridContainer:
	var container := BattleGridContainer.new()
	add_child(container)
	auto_free(container)
	return container


# ============ 基础属性测试 ============

## 测试1：BattleGridContainer 可以实例化
func test_container_instantiation() -> void:
	var container := _create_container()

	assert_that(container).is_not_null()
	assert_that(container).is_instanceof(BattleGridContainer)


## 测试2：验证常量值
func test_container_constants() -> void:
	var container := _create_container()

	assert_that(container.COLS).is_equal(7)
	assert_that(container.ROWS).is_equal(9)
	assert_that(container.TILE_SIZE).is_equal(Vector2(80, 80))


## 测试3：验证默认配置
func test_container_defaults() -> void:
	var container := _create_container()

	assert_that(container.TILE_GAP).is_greater(0.0)
	assert_that(container.PADDING).is_greater(0.0)
	assert_that(container.corner_radius).is_greater(0.0)


# ============ 尺寸计算测试 ============

## 测试4：计算总尺寸
func test_calculate_total_size() -> void:
	var container := _create_container()

	var size := container.get_total_size()

	# 宽度 = COLS * TILE_SIZE.x + (COLS - 1) * TILE_GAP + 2 * PADDING
	# 高度 = ROWS * TILE_SIZE.y + (ROWS - 1) * TILE_GAP + 2 * PADDING
	var expected_width := 7 * 80.0 + 6 * container.TILE_GAP + 2 * container.PADDING
	var expected_height := 9 * 80.0 + 8 * container.TILE_GAP + 2 * container.PADDING

	assert_that(size.x).is_equal_approx(expected_width, 0.1)
	assert_that(size.y).is_equal_approx(expected_height, 0.1)


## 测试5：获取地块位置
func test_get_tile_position() -> void:
	var container := _create_container()

	# 第一个地块位置（左上角）
	var pos_0_0 := container.get_tile_position(0, 0)
	assert_that(pos_0_0.x).is_equal_approx(container.PADDING + 40.0, 0.1)
	assert_that(pos_0_0.y).is_equal_approx(container.PADDING + 40.0, 0.1)

	# 第二列第一行
	var pos_1_0 := container.get_tile_position(1, 0)
	var expected_x := container.PADDING + 40.0 + (80.0 + container.TILE_GAP)
	assert_that(pos_1_0.x).is_equal_approx(expected_x, 0.1)


## 测试6：获取居中偏移
func test_get_center_offset() -> void:
	var container := _create_container()

	var offset := container.get_center_offset()
	var size := container.get_total_size()

	assert_that(offset.x).is_equal_approx(-size.x / 2, 0.1)
	assert_that(offset.y).is_equal_approx(-size.y / 2, 0.1)


# ============ 绘制测试 ============

## 测试7：_draw 方法存在
func test_draw_method_exists() -> void:
	var container := _create_container()

	assert_that(container.has_method("_draw")).is_true()


## 测试8：queue_redraw 可调用
func test_queue_redraw() -> void:
	var container := _create_container()

	# 应该不会抛出错误
	container.queue_redraw()
	await await_idle_frame()

	assert_that(container).is_not_null()


## 测试9：背景颜色可配置
func test_background_color_configurable() -> void:
	var container := _create_container()
	var new_color := Color(0.5, 0.5, 0.5, 0.8)

	container.bg_color = new_color

	assert_that(container.bg_color).is_equal(new_color)


## 测试10：边框颜色可配置
func test_border_color_configurable() -> void:
	var container := _create_container()
	var new_color := Color(0.7, 0.7, 0.7, 1.0)

	container.border_color = new_color

	assert_that(container.border_color).is_equal(new_color)
