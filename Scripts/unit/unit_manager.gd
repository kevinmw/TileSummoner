# Scripts/unit/unit_manager.gd
extends Node

## 单位管理器（AutoLoad 单例）
## 跟踪战场上的所有单位，提供查询功能

# ============ 属性 ============

## 已注册的单位列表
var _units: Array[Unit] = []

# ============ 公共方法 ============

## 注册单位
func register(unit: Unit) -> void:
	if not unit:
		return
	if not _units.has(unit):
		_units.append(unit)


## 注销单位
func unregister(unit: Unit) -> void:
	_units.erase(unit)


## 获取敌方单位
func get_enemies(team: int) -> Array[Unit]:
	return _units.filter(func(u: Unit) -> bool:
		return u.team != team and u.is_alive()
	)


## 获取友方单位
func get_allies(team: int) -> Array[Unit]:
	return _units.filter(func(u: Unit) -> bool:
		return u.team == team and u.is_alive()
	)


## 获取范围内的单位
func get_units_in_range(pos: Vector2, radius: float) -> Array[Unit]:
	return _units.filter(func(u: Unit) -> bool:
		return u.is_alive() and pos.distance_to(u.global_position) <= radius
	)


## 获取所有注册的单位
func get_all_units() -> Array[Unit]:
	return _units.duplicate()


## 获取单位总数
func get_unit_count() -> int:
	return _units.size()


## 清空所有单位
func clear() -> void:
	_units.clear()
