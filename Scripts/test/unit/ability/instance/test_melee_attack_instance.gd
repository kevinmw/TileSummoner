# Scripts/test/unit/ability/instance/test_melee_attack_instance.gd
class_name TestMeleeAttackInstance
extends GdUnitTestSuite

## 测试近战攻击能力实例


## 辅助方法
func _create_instance() -> MeleeAttackInstance:
	var instance := MeleeAttackInstance.new()
	add_child(instance)
	auto_free(instance)
	return instance


func _create_unit_with_data() -> Unit:
	var unit := preload("res://Scenes/unit/unit.tscn").instantiate()
	var data := UnitData.new()
	data.max_health = 100
	add_child(unit)
	unit.initialize(data, 0)
	auto_free(unit)
	return unit


## 测试1：继承自 AbilityInstance
func test_extends_ability_instance() -> void:
	var instance := _create_instance()
	assert_that(instance).is_instanceof(AbilityInstance)


## 测试2：获取攻击范围
func test_get_attack_range() -> void:
	var instance := _create_instance()
	var data := MeleeAttackAbility.new()
	data.attack_range = 0.8
	instance.initialize(data, null)

	assert_that(instance.get_attack_range()).is_equal_approx(0.8, 0.01)


## 测试3：执行后进入冷却
func test_execute_starts_cooldown() -> void:
	var instance := _create_instance()
	var data := MeleeAttackAbility.new()
	data.attack_interval = 1.5
	var attacker := _create_unit_with_data()
	var target := _create_unit_with_data()
	instance.initialize(data, attacker)

	instance.execute(target)

	assert_that(instance.is_ready).is_false()
	assert_that(instance.cooldown_timer).is_equal_approx(1.5, 0.01)


## 测试4：对目标造成伤害
func test_execute_deals_damage() -> void:
	var instance := _create_instance()
	var data := MeleeAttackAbility.new()
	data.damage = 25
	var attacker := _create_unit_with_data()
	var target := _create_unit_with_data()
	instance.initialize(data, attacker)

	instance.execute(target)

	assert_that(target.current_health).is_equal(75)


## 测试5：无目标不执行
func test_no_execute_without_target() -> void:
	var instance := _create_instance()
	var data := MeleeAttackAbility.new()
	var attacker := _create_unit_with_data()
	instance.initialize(data, attacker)

	instance.execute(null)

	assert_that(instance.is_ready).is_true()  # 未进入冷却
