# Scripts/test/unit/test_unit_enums.gd
class_name TestUnitEnums
extends GdUnitTestSuite

## 测试单位枚举定义


## 测试1：UnitMode 枚举包含6种模式
func test_unit_mode_has_six_types() -> void:
	assert_that(UnitEnums.UnitMode.size()).is_equal(6)


## 测试2：UnitSize 枚举包含4种体型
func test_unit_size_has_four_types() -> void:
	assert_that(UnitEnums.UnitSize.size()).is_equal(4)


## 测试3：ElementTag 枚举包含8种元素
func test_element_tag_has_eight_types() -> void:
	assert_that(UnitEnums.ElementTag.size()).is_equal(8)


## 测试4：MoveType 枚举包含2种移动类型
func test_move_type_has_two_types() -> void:
	assert_that(UnitEnums.MoveType.size()).is_equal(2)


## 测试5：AbilityTrigger 枚举包含所有触发类型
func test_ability_trigger_types() -> void:
	assert_that(UnitEnums.AbilityTrigger.AUTO).is_equal(0)
	assert_that(UnitEnums.AbilityTrigger.ON_COMBAT_START).is_equal(1)
	assert_that(UnitEnums.AbilityTrigger.PERIODIC).is_equal(2)


## 测试6：TargetPriority 枚举定义正确
func test_target_priority_types() -> void:
	assert_that(UnitEnums.TargetPriority.NEAREST).is_equal(0)
	assert_that(UnitEnums.TargetPriority.BUILDING_FIRST).is_equal(3)
