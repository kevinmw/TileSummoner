# Scripts/test/unit/test_unit_data.gd
class_name TestUnitData
extends GdUnitTestSuite

## 测试单位数据资源


## 测试1：UnitData 可实例化
func test_unit_data_instantiation() -> void:
	var data := UnitData.new()
	assert_that(data).is_not_null()
	assert_that(data).is_instanceof(Resource)


## 测试2：默认 id 为空
func test_default_id_empty() -> void:
	var data := UnitData.new()
	assert_that(data.id).is_equal(&"")


## 测试3：默认模式为 WARRIOR
func test_default_mode_warrior() -> void:
	var data := UnitData.new()
	assert_that(data.unit_mode).is_equal(UnitEnums.UnitMode.WARRIOR)


## 测试4：默认体型为 MEDIUM
func test_default_size_medium() -> void:
	var data := UnitData.new()
	assert_that(data.unit_size).is_equal(UnitEnums.UnitSize.MEDIUM)


## 测试5：默认最大生命为 100
func test_default_max_health() -> void:
	var data := UnitData.new()
	assert_that(data.max_health).is_equal(100)


## 测试6：默认移动速度为 2.0
func test_default_move_speed() -> void:
	var data := UnitData.new()
	assert_that(data.move_speed).is_equal_approx(2.0, 0.01)


## 测试7：默认移动类型为地面
func test_default_move_type_ground() -> void:
	var data := UnitData.new()
	assert_that(data.move_type).is_equal(UnitEnums.MoveType.GROUND)


## 测试8：默认能力列表为空
func test_default_abilities_empty() -> void:
	var data := UnitData.new()
	assert_that(data.abilities).is_empty()


## 测试9：默认召唤数量为 1
func test_default_spawn_count() -> void:
	var data := UnitData.new()
	assert_that(data.spawn_count).is_equal(1)


## 测试10：设置能力列表
func test_set_abilities() -> void:
	var data := UnitData.new()
	var ability := MeleeAttackAbility.new()
	data.abilities.append(ability)
	assert_that(data.abilities.size()).is_equal(1)
