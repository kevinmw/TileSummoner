# Scripts/test/unit/test_unit_factory.gd
class_name TestUnitFactory
extends GdUnitTestSuite

## 测试单位工厂


## 辅助方法：创建测试用 UnitData
func _create_test_data() -> UnitData:
	var data := UnitData.new()
	data.id = &"test_unit"
	data.display_name = "Test Unit"
	data.max_health = 100
	data.move_speed = 2.0
	data.spawn_count = 1
	return data


## 测试1：create 返回 Unit 实例
func test_create_returns_unit() -> void:
	var data := _create_test_data()

	var unit := UnitFactory.create(data, Vector2(100, 100), 0)

	if unit:
		add_child(unit)
		auto_free(unit)

	assert_that(unit).is_not_null()
	assert_that(unit).is_instanceof(Unit)


## 测试2：create 设置位置
func test_create_sets_position() -> void:
	var data := _create_test_data()
	var pos := Vector2(200, 150)

	var unit := UnitFactory.create(data, pos, 0)

	if unit:
		add_child(unit)
		auto_free(unit)

	assert_that(unit.global_position).is_equal(pos)


## 测试3：create 设置阵营
func test_create_sets_team() -> void:
	var data := _create_test_data()

	var unit := UnitFactory.create(data, Vector2.ZERO, 1)

	if unit:
		add_child(unit)
		auto_free(unit)

	assert_that(unit.team).is_equal(1)


## 测试4：null 数据返回 null
func test_create_null_data_returns_null() -> void:
	var unit := UnitFactory.create(null, Vector2.ZERO, 0)
	assert_that(unit).is_null()


## 测试5：create_group 返回正确数量
func test_create_group_returns_correct_count() -> void:
	var data := _create_test_data()
	data.spawn_count = 3

	var units := UnitFactory.create_group(data, Vector2(100, 100), 0)

	for unit in units:
		add_child(unit)
		auto_free(unit)

	assert_that(units.size()).is_equal(3)


## 测试6：create_group 所有单位都是 Unit 类型
func test_create_group_all_units_valid() -> void:
	var data := _create_test_data()
	data.spawn_count = 2

	var units := UnitFactory.create_group(data, Vector2(100, 100), 0)

	for unit in units:
		add_child(unit)
		auto_free(unit)

	for unit in units:
		assert_that(unit).is_instanceof(Unit)


## 测试7：create_group null 数据返回空数组
func test_create_group_null_data_returns_empty() -> void:
	var units := UnitFactory.create_group(null, Vector2.ZERO, 0)
	assert_that(units.size()).is_equal(0)


## 测试8：create_group spawn_count 为 1 时也正常工作
func test_create_group_single_spawn() -> void:
	var data := _create_test_data()
	data.spawn_count = 1

	var units := UnitFactory.create_group(data, Vector2(100, 100), 0)

	for unit in units:
		add_child(unit)
		auto_free(unit)

	assert_that(units.size()).is_equal(1)


## 测试9：create_group 所有单位设置正确阵营
func test_create_group_sets_team() -> void:
	var data := _create_test_data()
	data.spawn_count = 3

	var units := UnitFactory.create_group(data, Vector2(100, 100), 1)

	for unit in units:
		add_child(unit)
		auto_free(unit)

	for unit in units:
		assert_that(unit.team).is_equal(1)


## 测试10：create 初始化单位数据
func test_create_initializes_unit_data() -> void:
	var data := _create_test_data()
	data.max_health = 150

	var unit := UnitFactory.create(data, Vector2.ZERO, 0)

	if unit:
		add_child(unit)
		auto_free(unit)

	assert_that(unit.data).is_equal(data)
	assert_that(unit.max_health).is_equal(150)
	assert_that(unit.current_health).is_equal(150)
