# Scripts/test/unit/visual/test_shape_renderer.gd
class_name TestShapeRenderer
extends GdUnitTestSuite

## 测试几何形状渲染器


## 辅助方法：创建渲染器
func _create_renderer() -> ShapeRenderer:
	var renderer := ShapeRenderer.new()
	add_child(renderer)
	auto_free(renderer)
	return renderer


## 测试1：ShapeRenderer 可实例化
func test_shape_renderer_instantiation() -> void:
	var renderer := _create_renderer()
	assert_that(renderer).is_not_null()
	assert_that(renderer).is_instanceof(Node2D)


## 测试2：默认模式为 WARRIOR
func test_default_mode() -> void:
	var renderer := _create_renderer()
	assert_that(renderer.unit_mode).is_equal(UnitEnums.UnitMode.WARRIOR)


## 测试3：默认体型为 MEDIUM
func test_default_size() -> void:
	var renderer := _create_renderer()
	assert_that(renderer.unit_size).is_equal(UnitEnums.UnitSize.MEDIUM)


## 测试4：默认填充颜色为白色
func test_default_fill_color() -> void:
	var renderer := _create_renderer()
	assert_that(renderer.fill_color).is_equal(Color.WHITE)


## 测试5：默认边框颜色为蓝色（己方）
func test_default_border_color() -> void:
	var renderer := _create_renderer()
	assert_that(renderer.border_color).is_equal(Color.DODGER_BLUE)


## 测试6：默认血量百分比为 1.0
func test_default_health_percent() -> void:
	var renderer := _create_renderer()
	assert_that(renderer.health_percent).is_equal_approx(1.0, 0.01)


## 测试7：设置模式后更新属性
func test_set_mode_updates_property() -> void:
	var renderer := _create_renderer()
	renderer.unit_mode = UnitEnums.UnitMode.TANK
	assert_that(renderer.unit_mode).is_equal(UnitEnums.UnitMode.TANK)


## 测试8：设置血量百分比
func test_set_health_percent() -> void:
	var renderer := _create_renderer()
	renderer.health_percent = 0.5
	assert_that(renderer.health_percent).is_equal_approx(0.5, 0.01)


## 测试9：血量百分比被限制在0-1范围内
func test_health_percent_clamped() -> void:
	var renderer := _create_renderer()
	renderer.health_percent = 1.5
	assert_that(renderer.health_percent).is_equal_approx(1.0, 0.01)
	renderer.health_percent = -0.5
	assert_that(renderer.health_percent).is_equal_approx(0.0, 0.01)


## 测试10：获取半径 - MEDIUM 体型
func test_get_radius_medium() -> void:
	var renderer := _create_renderer()
	renderer.unit_size = UnitEnums.UnitSize.MEDIUM
	var radius := renderer.get_radius()
	# 0.5格 * 80像素/格 = 40像素
	assert_that(radius).is_equal_approx(40.0, 0.1)


## 测试11：获取半径 - LARGE 体型
func test_get_radius_large() -> void:
	var renderer := _create_renderer()
	renderer.unit_size = UnitEnums.UnitSize.LARGE
	var radius := renderer.get_radius()
	# 0.8格 * 80像素/格 = 64像素
	assert_that(radius).is_equal_approx(64.0, 0.1)


## 测试12：获取半径 - SMALL 体型
func test_get_radius_small() -> void:
	var renderer := _create_renderer()
	renderer.unit_size = UnitEnums.UnitSize.SMALL
	var radius := renderer.get_radius()
	# 0.2格 * 80像素/格 = 16像素
	assert_that(radius).is_equal_approx(16.0, 0.1)


## 测试13：获取形状点集 - 八边形（WARRIOR）
func test_get_shape_points_warrior() -> void:
	var renderer := _create_renderer()
	renderer.unit_mode = UnitEnums.UnitMode.WARRIOR
	var points := renderer.get_shape_points()
	assert_that(points.size()).is_equal(8)


## 测试14：获取形状点集 - 六边形（TANK）
func test_get_shape_points_tank() -> void:
	var renderer := _create_renderer()
	renderer.unit_mode = UnitEnums.UnitMode.TANK
	var points := renderer.get_shape_points()
	assert_that(points.size()).is_equal(6)


## 测试15：获取形状点集 - 三角形（ASSASSIN）
func test_get_shape_points_assassin() -> void:
	var renderer := _create_renderer()
	renderer.unit_mode = UnitEnums.UnitMode.ASSASSIN
	var points := renderer.get_shape_points()
	assert_that(points.size()).is_equal(3)


## 测试16：获取形状点集 - 圆形（MAGE）
func test_get_shape_points_mage() -> void:
	var renderer := _create_renderer()
	renderer.unit_mode = UnitEnums.UnitMode.MAGE
	var points := renderer.get_shape_points()
	# 圆形用32段多边形近似
	assert_that(points.size()).is_equal(32)


## 测试17：获取形状点集 - 菱形（SUPPORT）
func test_get_shape_points_support() -> void:
	var renderer := _create_renderer()
	renderer.unit_mode = UnitEnums.UnitMode.SUPPORT
	var points := renderer.get_shape_points()
	assert_that(points.size()).is_equal(4)


## 测试18：获取形状点集 - 正方形（BUILDING）
func test_get_shape_points_building() -> void:
	var renderer := _create_renderer()
	renderer.unit_mode = UnitEnums.UnitMode.BUILDING
	var points := renderer.get_shape_points()
	assert_that(points.size()).is_equal(4)


## 测试19：设置体型后更新属性
func test_set_size_updates_property() -> void:
	var renderer := _create_renderer()
	renderer.unit_size = UnitEnums.UnitSize.HUGE
	assert_that(renderer.unit_size).is_equal(UnitEnums.UnitSize.HUGE)


## 测试20：设置填充颜色
func test_set_fill_color() -> void:
	var renderer := _create_renderer()
	renderer.fill_color = Color.RED
	assert_that(renderer.fill_color).is_equal(Color.RED)


## 测试21：设置边框颜色
func test_set_border_color() -> void:
	var renderer := _create_renderer()
	renderer.border_color = Color.INDIAN_RED
	assert_that(renderer.border_color).is_equal(Color.INDIAN_RED)
