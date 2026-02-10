# Scripts/test/unit/ability/test_melee_attack_ability.gd
class_name TestMeleeAttackAbility
extends GdUnitTestSuite

## 测试 MeleeAttackAbility 近战攻击能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
	var ability := MeleeAttackAbility.new()
	assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认伤害值为 10
func test_default_damage() -> void:
	var ability := MeleeAttackAbility.new()
	assert_that(ability.damage).is_equal(10)


## 测试3：默认攻击范围为 0.5
func test_default_attack_range() -> void:
	var ability := MeleeAttackAbility.new()
	assert_that(ability.attack_range).is_equal_approx(0.5, 0.01)


## 测试4：默认攻击间隔为 1.0
func test_default_attack_interval() -> void:
	var ability := MeleeAttackAbility.new()
	assert_that(ability.attack_interval).is_equal_approx(1.0, 0.01)


## 测试5：可以设置伤害值
func test_can_set_damage() -> void:
	var ability := MeleeAttackAbility.new()
	ability.damage = 25
	assert_that(ability.damage).is_equal(25)


## 测试6：可以设置攻击范围
func test_can_set_attack_range() -> void:
	var ability := MeleeAttackAbility.new()
	ability.attack_range = 1.0
	assert_that(ability.attack_range).is_equal_approx(1.0, 0.01)
