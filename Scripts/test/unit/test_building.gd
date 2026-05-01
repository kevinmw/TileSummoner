# Scripts/test/unit/test_building.gd
class_name TestBuilding
extends GdUnitTestSuite

## 测试建筑节点类


func before_test() -> void:
	# Building expects child nodes from its scene:
	# ShapeRenderer (ShapeRenderer2D), CollisionShape2D, AbilityManager, BehaviorManager
	# We create them manually since we instantiate with Building.new()
	pass


func after_test() -> void:
	# Resources created in tests will be auto-freed by the test framework
	pass


## 测试1：Building 继承自 Unit
func test_building_extends_unit() -> void:
	var building: Building = auto_free(Building.new())
	assert_that(building is Unit).is_true()


## 测试2：Building 有 shield_active 属性
func test_building_has_shield_active_property() -> void:
	var building: Building = auto_free(Building.new())
	assert_that(building.shield_active).is_true()


## 测试3：护盾激活时免疫伤害
func test_shield_active_blocks_damage() -> void:
	var building_data: BuildingData = auto_free(BuildingData.new())
	building_data.max_health = 500
	building_data.shield_enabled = true
	building_data.building_type = UnitEnums.BuildingType.BASE

	var building: Building = auto_free(Building.new())
	building.data = building_data
	building.max_health = 500
	building.current_health = 500
	building.shield_active = true

	building.take_damage(100, null)

	assert_that(building.current_health).is_equal(500)


## 测试4：护盾关闭后正常受伤
func test_shield_inactive_allows_damage() -> void:
	var building_data: BuildingData = auto_free(BuildingData.new())
	building_data.max_health = 500
	building_data.shield_enabled = true
	building_data.building_type = UnitEnums.BuildingType.BASE

	var building: Building = auto_free(Building.new())
	building.data = building_data
	building.max_health = 500
	building.current_health = 500
	building.shield_active = false

	building.take_damage(100, null)

	assert_that(building.current_health).is_equal(400)


## 测试5：非护盾建筑正常受伤
func test_non_shield_building_takes_damage() -> void:
	var tower_data: BuildingData = auto_free(BuildingData.new())
	tower_data.max_health = 500
	tower_data.shield_enabled = false

	var building: Building = auto_free(Building.new())
	building.data = tower_data
	building.max_health = 500
	building.current_health = 500
	building.shield_active = true  # 即使 shield_active 为 true

	building.take_damage(100, null)

	# 因为 data.shield_enabled = false，所以仍然受伤
	assert_that(building.current_health).is_equal(400)


## 测试6：get_building_type 返回正确类型
func test_get_building_type() -> void:
	var building_data: BuildingData = auto_free(BuildingData.new())
	building_data.building_type = UnitEnums.BuildingType.BASE

	var building: Building = auto_free(Building.new())
	building.data = building_data
	assert_that(building.get_building_type()).is_equal(UnitEnums.BuildingType.BASE)


## 测试7：无数据时 get_building_type 返回 TOWER
func test_get_building_type_default() -> void:
	var building: Building = auto_free(Building.new())
	building.data = null
	assert_that(building.get_building_type()).is_equal(UnitEnums.BuildingType.TOWER)
