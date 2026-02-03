# Scripts/unit/ability/instance/melee_attack_instance.gd
class_name MeleeAttackInstance
extends AbilityInstance

## 近战攻击能力实例


## 获取攻击范围
func get_attack_range() -> float:
	var ability := data as MeleeAttackAbility
	if ability:
		return ability.attack_range
	return 0.0


## 执行攻击
func execute(target: Unit = null) -> void:
	if not target or not can_execute():
		return

	var ability := data as MeleeAttackAbility
	if not ability:
		return

	# 播放攻击动画
	if owner_unit:
		owner_unit.play_attack(target.global_position)

	# 造成伤害
	target.take_damage(ability.damage, owner_unit)

	# 进入冷却
	_start_cooldown(ability.attack_interval)
