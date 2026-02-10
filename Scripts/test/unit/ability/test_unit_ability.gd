# Scripts/test/unit/ability/test_unit_ability.gd
class_name TestUnitAbility
extends GdUnitTestSuite

## 测试 UnitAbility 基类


## 测试1：UnitAbility 可以实例化
func test_unit_ability_instantiation() -> void:
	var ability := UnitAbility.new()
	assert_that(ability).is_not_null()
	assert_that(ability).is_instanceof(Resource)


## 测试2：默认 id 为空 StringName
func test_default_id_empty() -> void:
	var ability := UnitAbility.new()
	assert_that(ability.id).is_equal(&"")


## 测试3：默认触发类型为 AUTO
func test_default_trigger_auto() -> void:
	var ability := UnitAbility.new()
	assert_that(ability.trigger).is_equal(UnitEnums.AbilityTrigger.AUTO)


## 测试4：可以设置 id
func test_can_set_id() -> void:
	var ability := UnitAbility.new()
	ability.id = &"test_ability"
	assert_that(ability.id).is_equal(&"test_ability")


## 测试5：可以设置 trigger
func test_can_set_trigger() -> void:
	var ability := UnitAbility.new()
	ability.trigger = UnitEnums.AbilityTrigger.ON_DEATH
	assert_that(ability.trigger).is_equal(UnitEnums.AbilityTrigger.ON_DEATH)
