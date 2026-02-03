# Scripts/test/unit/test_unit.gd
class_name TestUnit
extends GdUnitTestSuite

## 测试 Unit 主类


## 辅助方法：创建单位
func _create_unit() -> Unit:
	var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
	add_child(unit)
	auto_free(unit)
	return unit


## 辅助方法：创建测试用 UnitData
func _create_test_data() -> UnitData:
	var data := UnitData.new()
	data.id = &"test_unit"
	data.display_name = "Test Unit"
	data.max_health = 100
	data.move_speed = 2.0
	return data


## 测试1：Unit 可实例化
func test_unit_instantiation() -> void:
	var unit := _create_unit()
	assert_that(unit).is_not_null()
	assert_that(unit).is_instanceof(CharacterBody2D)


## 测试2：初始化设置数据
func test_initialize_sets_data() -> void:
	var unit := _create_unit()
	var data := _create_test_data()

	unit.initialize(data, 0)

	assert_that(unit.data).is_equal(data)


## 测试3：初始化设置阵营
func test_initialize_sets_team() -> void:
	var unit := _create_unit()
	var data := _create_test_data()

	unit.initialize(data, 1)

	assert_that(unit.team).is_equal(1)


## 测试4：初始化设置当前血量
func test_initialize_sets_current_health() -> void:
	var unit := _create_unit()
	var data := _create_test_data()
	data.max_health = 150

	unit.initialize(data, 0)

	assert_that(unit.current_health).is_equal(150)


## 测试5：受伤减少血量
func test_take_damage_reduces_health() -> void:
	var unit := _create_unit()
	var data := _create_test_data()
	data.max_health = 100
	unit.initialize(data, 0)

	unit.take_damage(30, null)

	assert_that(unit.current_health).is_equal(70)


## 测试6：血量不会低于0
func test_health_cannot_go_below_zero() -> void:
	var unit := _create_unit()
	var data := _create_test_data()
	data.max_health = 100
	unit.initialize(data, 0)

	unit.take_damage(150, null)

	assert_that(unit.current_health).is_equal(0)


## 测试7：血量归零时死亡
func test_dies_when_health_zero() -> void:
	var unit := _create_unit()
	var data := _create_test_data()
	data.max_health = 100
	unit.initialize(data, 0)

	unit.take_damage(100, null)

	assert_that(unit.is_dead).is_true()


## 测试8：存活检查
func test_is_alive() -> void:
	var unit := _create_unit()
	var data := _create_test_data()
	unit.initialize(data, 0)

	assert_that(unit.is_alive()).is_true()

	unit.take_damage(1000, null)

	assert_that(unit.is_alive()).is_false()


## 测试9：获取攻击范围（无攻击能力返回0）
func test_get_attack_range_no_ability() -> void:
	var unit := _create_unit()
	var data := _create_test_data()
	unit.initialize(data, 0)

	var range_val := unit.get_attack_range()

	assert_that(range_val).is_equal(0.0)


## 测试10：shape_renderer 子节点存在
func test_has_shape_renderer() -> void:
	var unit := _create_unit()

	var renderer := unit.get_node_or_null("ShapeRenderer")

	assert_that(renderer).is_not_null()
	assert_that(renderer).is_instanceof(ShapeRenderer)
