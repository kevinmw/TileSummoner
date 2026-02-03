# Scripts/test/unit/test_unit_manager.gd
class_name TestUnitManager
extends GdUnitTestSuite

## 测试单位管理器


## 辅助方法：创建模拟单位
func _create_mock_unit(unit_team: int) -> Unit:
	var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
	var data := UnitData.new()
	data.max_health = 100
	add_child(unit)
	unit.initialize(data, unit_team)
	auto_free(unit)
	return unit


## 测试前重置
func before_test() -> void:
	UnitManager._units.clear()


## 测试1：register 添加单位
func test_register_adds_unit() -> void:
	var unit := _create_mock_unit(0)

	UnitManager.register(unit)

	assert_that(UnitManager._units.size()).is_equal(1)


## 测试2：unregister 移除单位
func test_unregister_removes_unit() -> void:
	var unit := _create_mock_unit(0)
	UnitManager.register(unit)

	UnitManager.unregister(unit)

	assert_that(UnitManager._units.size()).is_equal(0)


## 测试3：重复注册不会添加重复单位
func test_register_does_not_add_duplicates() -> void:
	var unit := _create_mock_unit(0)

	UnitManager.register(unit)
	UnitManager.register(unit)

	assert_that(UnitManager._units.size()).is_equal(1)


## 测试4：注销不存在的单位不会报错
func test_unregister_nonexistent_unit_is_safe() -> void:
	var unit := _create_mock_unit(0)
	# 不注册直接注销

	UnitManager.unregister(unit)

	assert_that(UnitManager._units.size()).is_equal(0)


## 测试5：get_enemies 返回敌方单位
func test_get_enemies() -> void:
	var ally := _create_mock_unit(0)
	var enemy := _create_mock_unit(1)
	UnitManager.register(ally)
	UnitManager.register(enemy)

	var enemies := UnitManager.get_enemies(0)

	assert_that(enemies.size()).is_equal(1)
	assert_that(enemies[0]).is_equal(enemy)


## 测试6：get_enemies 不返回死亡单位
func test_get_enemies_excludes_dead_units() -> void:
	var ally := _create_mock_unit(0)
	var enemy := _create_mock_unit(1)
	UnitManager.register(ally)
	UnitManager.register(enemy)

	# 让敌人死亡
	enemy.take_damage(1000, null)

	var enemies := UnitManager.get_enemies(0)

	assert_that(enemies.size()).is_equal(0)


## 测试7：get_allies 返回友方单位
func test_get_allies() -> void:
	var ally1 := _create_mock_unit(0)
	var ally2 := _create_mock_unit(0)
	var enemy := _create_mock_unit(1)
	UnitManager.register(ally1)
	UnitManager.register(ally2)
	UnitManager.register(enemy)

	var allies := UnitManager.get_allies(0)

	assert_that(allies.size()).is_equal(2)


## 测试8：get_allies 不返回死亡单位
func test_get_allies_excludes_dead_units() -> void:
	var ally1 := _create_mock_unit(0)
	var ally2 := _create_mock_unit(0)
	UnitManager.register(ally1)
	UnitManager.register(ally2)

	# 让 ally2 死亡
	ally2.take_damage(1000, null)

	var allies := UnitManager.get_allies(0)

	assert_that(allies.size()).is_equal(1)
	assert_that(allies[0]).is_equal(ally1)


## 测试9：get_units_in_range 返回范围内单位
func test_get_units_in_range() -> void:
	var unit1 := _create_mock_unit(0)
	var unit2 := _create_mock_unit(1)
	unit1.global_position = Vector2(0, 0)
	unit2.global_position = Vector2(50, 0)
	UnitManager.register(unit1)
	UnitManager.register(unit2)

	var units_in_range := UnitManager.get_units_in_range(Vector2(0, 0), 100.0)

	assert_that(units_in_range.size()).is_equal(2)


## 测试10：get_units_in_range 不返回范围外单位
func test_get_units_in_range_excludes_far_units() -> void:
	var unit1 := _create_mock_unit(0)
	var unit2 := _create_mock_unit(1)
	unit1.global_position = Vector2(0, 0)
	unit2.global_position = Vector2(200, 0)
	UnitManager.register(unit1)
	UnitManager.register(unit2)

	var units_in_range := UnitManager.get_units_in_range(Vector2(0, 0), 100.0)

	assert_that(units_in_range.size()).is_equal(1)
	assert_that(units_in_range[0]).is_equal(unit1)


## 测试11：get_units_in_range 不返回死亡单位
func test_get_units_in_range_excludes_dead_units() -> void:
	var unit1 := _create_mock_unit(0)
	var unit2 := _create_mock_unit(1)
	unit1.global_position = Vector2(0, 0)
	unit2.global_position = Vector2(50, 0)
	UnitManager.register(unit1)
	UnitManager.register(unit2)

	# 让 unit2 死亡
	unit2.take_damage(1000, null)

	var units_in_range := UnitManager.get_units_in_range(Vector2(0, 0), 100.0)

	assert_that(units_in_range.size()).is_equal(1)


## 测试12：clear 清空所有单位
func test_clear_removes_all_units() -> void:
	var unit1 := _create_mock_unit(0)
	var unit2 := _create_mock_unit(1)
	UnitManager.register(unit1)
	UnitManager.register(unit2)

	UnitManager.clear()

	assert_that(UnitManager._units.size()).is_equal(0)


## 测试13：get_all_units 返回所有注册的单位
func test_get_all_units() -> void:
	var unit1 := _create_mock_unit(0)
	var unit2 := _create_mock_unit(1)
	UnitManager.register(unit1)
	UnitManager.register(unit2)

	var all_units := UnitManager.get_all_units()

	assert_that(all_units.size()).is_equal(2)


## 测试14：get_unit_count 返回单位总数
func test_get_unit_count() -> void:
	var unit1 := _create_mock_unit(0)
	var unit2 := _create_mock_unit(1)
	UnitManager.register(unit1)
	UnitManager.register(unit2)

	var count := UnitManager.get_unit_count()

	assert_that(count).is_equal(2)


## 测试15：register null 单位不会添加
func test_register_null_unit_is_safe() -> void:
	UnitManager.register(null)

	assert_that(UnitManager._units.size()).is_equal(0)
