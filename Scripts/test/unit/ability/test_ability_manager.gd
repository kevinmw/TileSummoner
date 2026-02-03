# Scripts/test/unit/ability/test_ability_manager.gd
class_name TestAbilityManager
extends GdUnitTestSuite

## 测试能力管理器


## 辅助方法
func _create_manager() -> AbilityManager:
	var manager := AbilityManager.new()
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


## 测试1：AbilityManager 是 Node
func test_is_node() -> void:
	var manager := _create_manager()
	assert_that(manager).is_instanceof(Node)


## 测试2：初始化后 owner_unit 被设置
func test_initialize_sets_owner() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()

	manager.initialize(unit, [])

	assert_that(manager.owner_unit).is_equal(unit)


## 测试3：初始化创建能力实例子节点
func test_initialize_creates_ability_instances() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var ability := MeleeAttackAbility.new()
	ability.id = &"melee"

	manager.initialize(unit, [ability])

	assert_that(manager.get_child_count()).is_equal(1)


## 测试4：auto_attack 被缓存
func test_auto_attack_cached() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var ability := MeleeAttackAbility.new()
	ability.trigger = UnitEnums.AbilityTrigger.AUTO

	manager.initialize(unit, [ability])

	assert_that(manager.auto_attack).is_not_null()


## 测试5：try_attack 调用 auto_attack
func test_try_attack() -> void:
	var manager := _create_manager()
	var attacker := _create_mock_unit()
	var target := _create_mock_unit()
	var ability := MeleeAttackAbility.new()
	ability.damage = 20
	ability.trigger = UnitEnums.AbilityTrigger.AUTO

	manager.initialize(attacker, [ability])
	manager.try_attack(target)

	assert_that(target.current_health).is_equal(80)


## 测试6：get_max_attack_range 返回最大攻击范围
func test_get_max_attack_range() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var ability := MeleeAttackAbility.new()
	ability.attack_range = 1.5

	manager.initialize(unit, [ability])

	assert_that(manager.get_max_attack_range()).is_equal(1.5)


## 测试7：get_ability_by_type 返回指定类型能力
func test_get_ability_by_type() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var ability := MeleeAttackAbility.new()
	ability.id = &"melee"

	manager.initialize(unit, [ability])
	var result := manager.get_ability_by_type(MeleeAttackAbility)

	assert_that(result).is_not_null()
	assert_that(result.data).is_instanceof(MeleeAttackAbility)


## 测试8：get_abilities_by_trigger 返回指定触发类型的能力
func test_get_abilities_by_trigger() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var ability1 := MeleeAttackAbility.new()
	ability1.trigger = UnitEnums.AbilityTrigger.AUTO
	var ability2 := MeleeAttackAbility.new()
	ability2.trigger = UnitEnums.AbilityTrigger.ON_DEATH

	manager.initialize(unit, [ability1, ability2])
	var result := manager.get_abilities_by_trigger(UnitEnums.AbilityTrigger.AUTO)

	assert_that(result.size()).is_equal(1)


## 测试9：多个能力实例正确创建
func test_multiple_abilities() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var ability1 := MeleeAttackAbility.new()
	ability1.id = &"melee1"
	var ability2 := MeleeAttackAbility.new()
	ability2.id = &"melee2"

	manager.initialize(unit, [ability1, ability2])

	assert_that(manager.get_child_count()).is_equal(2)


## 测试10：非 AUTO 触发类型不缓存为 auto_attack
func test_non_auto_trigger_not_cached() -> void:
	var manager := _create_manager()
	var unit := _create_mock_unit()
	var ability := MeleeAttackAbility.new()
	ability.trigger = UnitEnums.AbilityTrigger.ON_DEATH

	manager.initialize(unit, [ability])

	assert_that(manager.auto_attack).is_null()
