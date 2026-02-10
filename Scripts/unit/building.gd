# Scripts/unit/building.gd
class_name Building
extends Unit

## 建筑节点
## 继承自 Unit，支持护盾机制

# ============ 信号 ============

signal shield_state_changed(active: bool)

# ============ 属性 ============

## 护盾是否激活
var shield_active: bool = true

# ============ 公共方法 ============

## 重写受伤逻辑，支持护盾免疫
func take_damage(amount: int, attacker: Unit) -> void:
	# 检查护盾是否阻挡伤害
	if _should_block_damage():
		return

	# 调用父类方法处理伤害
	super.take_damage(amount, attacker)


## 获取建筑类型
func get_building_type() -> UnitEnums.BuildingType:
	if data is BuildingData:
		return (data as BuildingData).building_type
	return UnitEnums.BuildingType.TOWER


## 设置护盾状态
func set_shield_active(active: bool) -> void:
	if shield_active == active:
		return

	shield_active = active
	shield_state_changed.emit(active)


## 是否为主基地
func is_base() -> bool:
	return get_building_type() == UnitEnums.BuildingType.BASE


## 是否为防御塔
func is_tower() -> bool:
	return get_building_type() == UnitEnums.BuildingType.TOWER


# ============ 私有方法 ============

func _should_block_damage() -> bool:
	# 护盾未激活，不阻挡
	if not shield_active:
		return false

	# 检查数据是否启用护盾
	if data is BuildingData:
		var bd := data as BuildingData
		return bd.shield_enabled

	return false
