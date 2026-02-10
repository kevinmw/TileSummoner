# Scripts/test/unit/ability/test_summon_ability.gd
class_name TestSummonAbility
extends GdUnitTestSuite

## 测试 SummonAbility 召唤能力数据


## 测试1：继承自 UnitAbility
func test_extends_unit_ability() -> void:
	var ability := SummonAbility.new()
	assert_that(ability).is_instanceof(UnitAbility)


## 测试2：默认召唤数量为 1
func test_default_summon_count() -> void:
	var ability := SummonAbility.new()
	assert_that(ability.summon_count).is_equal(1)


## 测试3：默认召唤偏移为 Vector2.ZERO
func test_default_summon_offset() -> void:
	var ability := SummonAbility.new()
	assert_that(ability.summon_offset).is_equal(Vector2.ZERO)


## 测试4：默认无召唤单位
func test_default_no_summon_unit() -> void:
	var ability := SummonAbility.new()
	assert_that(ability.summon_unit).is_null()


## 测试5：可以设置召唤数量
func test_can_set_summon_count() -> void:
	var ability := SummonAbility.new()
	ability.summon_count = 3
	assert_that(ability.summon_count).is_equal(3)


## 测试6：可以设置召唤偏移
func test_can_set_summon_offset() -> void:
	var ability := SummonAbility.new()
	ability.summon_offset = Vector2(1.5, 2.0)
	assert_that(ability.summon_offset).is_equal(Vector2(1.5, 2.0))
