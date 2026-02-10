# Scripts/test/unit/test_building_data.gd
class_name TestBuildingData
extends GdUnitTestSuite

## 测试建筑数据资源类


## 测试1：BuildingData 继承自 UnitData
func test_building_data_extends_unit_data() -> void:
	var building_data := BuildingData.new()
	assert_that(building_data is UnitData).is_true()
	building_data.free()


## 测试2：默认 building_type 为 TOWER
func test_default_building_type_is_tower() -> void:
	var building_data := BuildingData.new()
	assert_that(building_data.building_type).is_equal(UnitEnums.BuildingType.TOWER)
	building_data.free()


## 测试3：默认 shield_enabled 为 false
func test_default_shield_enabled_is_false() -> void:
	var building_data := BuildingData.new()
	assert_that(building_data.shield_enabled).is_false()
	building_data.free()


## 测试4：默认 shield_requires_towers 为 1
func test_default_shield_requires_towers_is_one() -> void:
	var building_data := BuildingData.new()
	assert_that(building_data.shield_requires_towers).is_equal(1)
	building_data.free()


## 测试5：默认 attack_when_vulnerable 为 false
func test_default_attack_when_vulnerable_is_false() -> void:
	var building_data := BuildingData.new()
	assert_that(building_data.attack_when_vulnerable).is_false()
	building_data.free()


## 测试6：可以设置为 BASE 类型
func test_can_set_building_type_to_base() -> void:
	var building_data := BuildingData.new()
	building_data.building_type = UnitEnums.BuildingType.BASE
	assert_that(building_data.building_type).is_equal(UnitEnums.BuildingType.BASE)
	building_data.free()


## 测试7：可以启用护盾
func test_can_enable_shield() -> void:
	var building_data := BuildingData.new()
	building_data.shield_enabled = true
	assert_that(building_data.shield_enabled).is_true()
	building_data.free()
