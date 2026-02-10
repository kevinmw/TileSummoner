# Scripts/test/unit/ability/test_heal_ability.gd
class_name TestHealAbility
extends GdUnitTestSuite

## 测试 HealAbility 治疗能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
	var ability := HealAbility.new()
	assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认治疗量为 20
func test_default_heal_amount() -> void:
	var ability := HealAbility.new()
	assert_that(ability.heal_amount).is_equal(20)


## 测试3：默认治疗范围为 2.0
func test_default_heal_range() -> void:
	var ability := HealAbility.new()
	assert_that(ability.heal_range).is_equal_approx(2.0, 0.01)


## 测试4：默认治疗间隔为 3.0
func test_default_interval() -> void:
	var ability := HealAbility.new()
	assert_that(ability.interval).is_equal_approx(3.0, 0.01)


## 测试5：默认可以治疗友军
func test_default_target_allies() -> void:
	var ability := HealAbility.new()
	assert_that(ability.target_allies).is_true()


## 测试6：默认不能治疗自己
func test_default_not_target_self() -> void:
	var ability := HealAbility.new()
	assert_that(ability.target_self).is_false()


## 测试7：可以设置治疗量
func test_can_set_heal_amount() -> void:
	var ability := HealAbility.new()
	ability.heal_amount = 50
	assert_that(ability.heal_amount).is_equal(50)


## 测试8：可以设置自我治疗
func test_can_set_target_self() -> void:
	var ability := HealAbility.new()
	ability.target_self = true
	assert_that(ability.target_self).is_true()
