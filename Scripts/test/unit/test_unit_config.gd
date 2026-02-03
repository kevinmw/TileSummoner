# Scripts/test/unit/test_unit_config.gd
class_name TestUnitConfig
extends GdUnitTestSuite

## 测试单位配置


## 测试1：获取小型单位半径
func test_small_size_radius() -> void:
	var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.SMALL)
	assert_that(radius).is_equal_approx(0.2, 0.01)


## 测试2：获取中型单位半径
func test_medium_size_radius() -> void:
	var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.MEDIUM)
	assert_that(radius).is_equal_approx(0.5, 0.01)


## 测试3：获取大型单位半径
func test_large_size_radius() -> void:
	var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.LARGE)
	assert_that(radius).is_equal_approx(0.8, 0.01)


## 测试4：获取巨大型单位半径
func test_huge_size_radius() -> void:
	var radius := UnitConfig.get_size_radius(UnitEnums.UnitSize.HUGE)
	assert_that(radius).is_equal_approx(1.2, 0.01)


## 测试5：获取模式对应的形状边数
func test_tank_mode_sides() -> void:
	var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.TANK)
	assert_that(sides).is_equal(6)  # 六边形


## 测试6：建筑模式为4边（正方形）
func test_building_mode_sides() -> void:
	var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.BUILDING)
	assert_that(sides).is_equal(4)


## 测试7：法师模式边数为0（表示圆形）
func test_mage_mode_is_circle() -> void:
	var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.MAGE)
	assert_that(sides).is_equal(0)  # 0表示圆形


## 测试8：刺客模式为3边（三角形）
func test_assassin_mode_sides() -> void:
	var sides := UnitConfig.get_shape_sides(UnitEnums.UnitMode.ASSASSIN)
	assert_that(sides).is_equal(3)
