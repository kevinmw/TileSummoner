# Scripts/unit/building_controller.gd
class_name BuildingController
extends Node

## 建筑控制器
## 管理基地护盾状态，监听塔死亡事件

# ============ 信号 ============

signal shield_broken

# ============ 属性 ============

## 管理的基地
var base: Building = null

## 友方防御塔列表
var friendly_towers: Array[Building] = []

# ============ 公共方法 ============

## 设置基地
func set_base(building: Building) -> void:
	if not building:
		push_error("Building is null")
		return

	base = building


## 注册友方塔
func register_tower(tower: Building) -> void:
	if not tower:
		push_error("Tower is null")
		return

	if tower in friendly_towers:
		return

	friendly_towers.append(tower)

	# 监听塔死亡信号
	if not tower.died.is_connected(_on_tower_died):
		tower.died.connect(_on_tower_died.bind(tower))


## 注销友方塔
func unregister_tower(tower: Building) -> void:
	if not tower:
		return

	var idx := friendly_towers.find(tower)
	if idx >= 0:
		friendly_towers.remove_at(idx)

	if tower.died.is_connected(_on_tower_died):
		tower.died.disconnect(_on_tower_died)


## 获取存活塔数量
func get_alive_tower_count() -> int:
	var count := 0
	for tower in friendly_towers:
		if tower and tower.is_alive():
			count += 1
	return count


## 护盾是否激活
func is_shield_active() -> bool:
	if base:
		return base.shield_active
	return false


# ============ 私有方法 ============

func _on_tower_died(_killer: Unit, _tower: Building) -> void:
	if not base:
		return

	if not base.data is BuildingData:
		return

	var bd := base.data as BuildingData
	var alive_count := get_alive_tower_count()

	# 存活塔数小于要求时，关闭护盾
	if alive_count < bd.shield_requires_towers:
		_disable_shield()


func _disable_shield() -> void:
	if not base:
		return

	base.set_shield_active(false)

	# 如果配置了护盾消失后攻击，启用能力
	if base.data is BuildingData:
		var bd := base.data as BuildingData
		if bd.attack_when_vulnerable and base.ability_manager:
			# ability_manager 默认启用，此处可以添加额外逻辑
			pass

	shield_broken.emit()
