# Scripts/test/unit/test_building.gd
class_name TestBuilding
extends GdUnitTestSuite

## 测试建筑节点类

var _building: Building
var _building_data: BuildingData


func before_test() -> void:
	_building_data = BuildingData.new()
	_building_data.max_health = 500
	_building_data.shield_enabled = true
	_building_data.building_type = UnitEnums.BuildingType.BASE

	_building = auto_free(Building.new())
	# 手动创建必要的子节点用于测试
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	_building.add_child(collision)


func after_test() -> void:
	_building_data.free()


## 测试1：Building 继承自 Unit
func test_building_extends_unit() -> void:
	assert_that(_building is Unit).is_true()


## 测试2：Building 有 shield_active 属性
func test_building_has_shield_active_property() -> void:
	assert_that(_building.shield_active).is_true()


## 测试3：护盾激活时免疫伤害
func test_shield_active_blocks_damage() -> void:
	_building.data = _building_data
	_building.max_health = 500
	_building.current_health = 500
	_building.shield_active = true

	_building.take_damage(100, null)

	assert_that(_building.current_health).is_equal(500)


## 测试4：护盾关闭后正常受伤
func test_shield_inactive_allows_damage() -> void:
	_building.data = _building_data
	_building.max_health = 500
	_building.current_health = 500
	_building.shield_active = false

	_building.take_damage(100, null)

	assert_that(_building.current_health).is_equal(400)


## 测试5：非护盾建筑正常受伤
func test_non_shield_building_takes_damage() -> void:
	var tower_data := auto_free(BuildingData.new())
	tower_data.max_health = 500
	tower_data.shield_enabled = false

	_building.data = tower_data
	_building.max_health = 500
	_building.current_health = 500
	_building.shield_active = true  # 即使 shield_active 为 true

	_building.take_damage(100, null)

	# 因为 data.shield_enabled = false，所以仍然受伤
	assert_that(_building.current_health).is_equal(400)


## 测试6：get_building_type 返回正确类型
func test_get_building_type() -> void:
	_building.data = _building_data
	assert_that(_building.get_building_type()).is_equal(UnitEnums.BuildingType.BASE)


## 测试7：无数据时 get_building_type 返回 TOWER
func test_get_building_type_default() -> void:
	_building.data = null
	assert_that(_building.get_building_type()).is_equal(UnitEnums.BuildingType.TOWER)
