# Scripts/test/unit/ability/test_ranged_attack_ability.gd
class_name TestRangedAttackAbility
extends GdUnitTestSuite

## 测试 RangedAttackAbility 远程攻击能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
	var ability := RangedAttackAbility.new()
	assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认伤害值为 10
func test_default_damage() -> void:
	var ability := RangedAttackAbility.new()
	assert_that(ability.damage).is_equal(10)


## 测试3：默认攻击范围为 3.0
func test_default_attack_range() -> void:
	var ability := RangedAttackAbility.new()
	assert_that(ability.attack_range).is_equal_approx(3.0, 0.01)


## 测试4：默认弹道速度为 5.0
func test_default_projectile_speed() -> void:
	var ability := RangedAttackAbility.new()
	assert_that(ability.projectile_speed).is_equal_approx(5.0, 0.01)


## 测试5：默认攻击间隔为 1.0
func test_default_attack_interval() -> void:
	var ability := RangedAttackAbility.new()
	assert_that(ability.attack_interval).is_equal_approx(1.0, 0.01)


## 测试6：可以设置弹道速度
func test_can_set_projectile_speed() -> void:
	var ability := RangedAttackAbility.new()
	ability.projectile_speed = 10.0
	assert_that(ability.projectile_speed).is_equal_approx(10.0, 0.01)
