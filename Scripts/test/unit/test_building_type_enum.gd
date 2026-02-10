# Scripts/test/unit/test_building_type_enum.gd
class_name TestBuildingTypeEnum
extends GdUnitTestSuite

## 测试建筑类型枚举


## 测试1：BuildingType 枚举存在且包含 TOWER
func test_building_type_has_tower() -> void:
	assert_that(UnitEnums.BuildingType.TOWER).is_equal(0)


## 测试2：BuildingType 枚举包含 BASE
func test_building_type_has_base() -> void:
	assert_that(UnitEnums.BuildingType.BASE).is_equal(1)


## 测试3：BuildingType 枚举只有2种类型
func test_building_type_has_two_types() -> void:
	assert_that(UnitEnums.BuildingType.size()).is_equal(2)
