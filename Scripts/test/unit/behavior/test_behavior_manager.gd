# Scripts/test/unit/behavior/test_behavior_manager.gd
class_name TestBehaviorManager
extends GdUnitTestSuite

## 测试行为管理器


## 辅助方法
func _create_manager() -> BehaviorManager:
	var manager := BehaviorManager.new()
	add_child(manager)
	auto_free(manager)
	return manager


func _create_mock_unit() -> Unit:
	var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
	var data := UnitData.new()
	data.max_health = 100
	add_child(unit)
	unit.initialize(data, 0)
	auto_free(unit)
	return unit


## 测试1：BehaviorManager 是 Node
func test_is_node() -> void:
	var manager := _create_manager()
	assert_that(manager).is_instanceof(Node)


## 测试2：初始化设置 owner_unit
func test_initialize_sets_owner() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()

	manager.initialize(unit)

	assert_that(manager.owner_unit).is_equal(unit)


## 测试3：默认搜索间隔为 0.5 秒
func test_default_search_interval() -> void:
	var manager := _create_manager()
	assert_that(manager.search_interval).is_equal_approx(0.5, 0.01)


## 测试4：默认无目标
func test_default_no_target() -> void:
	var manager := _create_manager()
	assert_that(manager.current_target).is_null()


## 测试5：初始化时 null 单位报错
func test_initialize_with_null_unit_reports_error() -> void:
	var manager := _create_manager()

	manager.initialize(null)

	assert_that(manager.owner_unit).is_null()


## 测试6：设置新目标
func test_set_target() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var target := _create_mock_unit()
	target.team = 1

	manager.initialize(unit)
	manager.set_target(target)

	assert_that(manager.current_target).is_equal(target)


## 测试7：清除目标
func test_clear_target() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var target := _create_mock_unit()
	target.team = 1

	manager.initialize(unit)
	manager.set_target(target)
	manager.clear_target()

	assert_that(manager.current_target).is_null()


## 测试8：has_valid_target 当无目标时返回 false
func test_has_valid_target_no_target() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()

	manager.initialize(unit)

	assert_that(manager.has_valid_target()).is_false()


## 测试9：has_valid_target 当有存活目标时返回 true
func test_has_valid_target_with_alive_target() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var target := _create_mock_unit()
	target.team = 1

	manager.initialize(unit)
	manager.set_target(target)

	assert_that(manager.has_valid_target()).is_true()


## 测试10：has_valid_target 当目标死亡时返回 false
func test_has_valid_target_with_dead_target() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var target := _create_mock_unit()
	target.team = 1

	manager.initialize(unit)
	manager.set_target(target)
	target.take_damage(1000, unit)  # 杀死目标

	assert_that(manager.has_valid_target()).is_false()


## 测试11：启用/禁用行为
func test_enable_disable() -> void:
	var manager := _create_manager()

	assert_that(manager.enabled).is_true()

	manager.enabled = false

	assert_that(manager.enabled).is_false()


## 测试12：get_distance_to_target 返回到目标的距离
func test_get_distance_to_target() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var target := _create_mock_unit()
	target.team = 1

	unit.global_position = Vector2(0, 0)
	target.global_position = Vector2(100, 0)

	manager.initialize(unit)
	manager.set_target(target)

	assert_that(manager.get_distance_to_target()).is_equal_approx(100.0, 1.0)


## 测试13：get_distance_to_target 无目标时返回 INF
func test_get_distance_to_target_no_target() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()

	manager.initialize(unit)

	assert_that(manager.get_distance_to_target()).is_equal(INF)
