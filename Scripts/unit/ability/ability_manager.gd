# Scripts/unit/ability/ability_manager.gd
class_name AbilityManager
extends Node

## 能力管理器
## 管理单位的所有能力实例

# ============ 属性 ============

## 所属单位
var owner_unit: Unit

## 自动攻击能力（缓存）
var auto_attack: AbilityInstance

# ============ 公共方法 ============

## 初始化能力管理器
func initialize(unit: Unit, abilities: Array) -> void:
	if not unit:
		push_error("Unit is null")
		return

	owner_unit = unit

	for ability_data in abilities:
		if ability_data is UnitAbility:
			var instance := _create_instance(ability_data)
			if instance:
				add_child(instance)
				_cache_auto_attack(instance, ability_data)


## 尝试执行自动攻击
func try_attack(target: Unit) -> void:
	if not target:
		push_error("Target is null")
		return

	if auto_attack and auto_attack.can_execute():
		auto_attack.execute(target)


## 获取最大攻击范围
func get_max_attack_range() -> float:
	var max_range := 0.0
	for child in get_children():
		if child is AbilityInstance:
			max_range = maxf(max_range, child.get_attack_range())
	return max_range


## 获取指定类型的能力实例
func get_ability_by_type(type: Variant) -> AbilityInstance:
	for child in get_children():
		if child is AbilityInstance and child.data is type:
			return child
	return null


## 获取指定触发类型的所有能力
func get_abilities_by_trigger(trigger: UnitEnums.AbilityTrigger) -> Array[AbilityInstance]:
	var result: Array[AbilityInstance] = []
	for child in get_children():
		if child is AbilityInstance and child.data.trigger == trigger:
			result.append(child)
	return result


# ============ 私有方法 ============

func _create_instance(ability_data: UnitAbility) -> AbilityInstance:
	var instance: AbilityInstance = null

	if ability_data is MeleeAttackAbility:
		instance = MeleeAttackInstance.new()
	# 其他能力类型暂时使用基类
	# elif ability_data is RangedAttackAbility:
	#     instance = RangedAttackInstance.new()
	# elif ability_data is SummonAbility:
	#     instance = SummonInstance.new()
	# elif ability_data is HealAbility:
	#     instance = HealInstance.new()
	else:
		instance = AbilityInstance.new()

	if instance:
		instance.initialize(ability_data, owner_unit)

	return instance


func _cache_auto_attack(instance: AbilityInstance, ability_data: UnitAbility) -> void:
	if ability_data.trigger != UnitEnums.AbilityTrigger.AUTO:
		return

	if ability_data is MeleeAttackAbility or ability_data is RangedAttackAbility:
		if not auto_attack:
			auto_attack = instance
