# Scripts/test/unit/ability/instance/test_ability_instance.gd
class_name TestAbilityInstance
extends GdUnitTestSuite

## 测试能力实例基类


## 辅助方法
func _create_instance() -> AbilityInstance:
	var instance := AbilityInstance.new()
	add_child(instance)
	auto_free(instance)
	return instance


func _create_mock_unit() -> Unit:
	var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
	add_child(unit)
	auto_free(unit)
	return unit


## 测试1：AbilityInstance 是 Node
func test_is_node() -> void:
	var instance := _create_instance()
	assert_that(instance).is_instanceof(Node)


## 测试2：初始化设置数据和所有者
func test_initialize() -> void:
	var instance := _create_instance()
	var data := MeleeAttackAbility.new()
	var unit := _create_mock_unit()

	instance.initialize(data, unit)

	assert_that(instance.data).is_equal(data)
	assert_that(instance.owner_unit).is_equal(unit)


## 测试3：默认 is_ready 为 true
func test_default_is_ready() -> void:
	var instance := _create_instance()
	assert_that(instance.is_ready).is_true()


## 测试4：默认 cooldown_timer 为 0
func test_default_cooldown_timer() -> void:
	var instance := _create_instance()
	assert_that(instance.cooldown_timer).is_equal(0.0)


## 测试5：can_execute 返回 is_ready
func test_can_execute() -> void:
	var instance := _create_instance()
	assert_that(instance.can_execute()).is_true()

	instance.is_ready = false
	assert_that(instance.can_execute()).is_false()
