# Scripts/unit/behavior/behavior_manager.gd
class_name BehaviorManager
extends Node

## 行为管理器
## 管理单位的自动战斗行为（移动、索敌、攻击）

# ============ 信号 ============

## 目标改变
signal target_changed(old_target: Unit, new_target: Unit)

## 进入攻击范围
signal entered_attack_range(target: Unit)

## 离开攻击范围
signal left_attack_range(target: Unit)

# ============ 导出变量 ============

## 索敌间隔（秒）
@export var search_interval: float = 0.5

## 是否启用行为
@export var enabled: bool = true

# ============ 属性 ============

## 所属单位
var owner_unit: Unit = null

## 当前目标
var current_target: Unit = null

## 搜索计时器
var _search_timer: float = 0.0

## 上一帧是否在攻击范围内
var _was_in_attack_range: bool = false

# ============ 公共方法 ============

## 初始化
func initialize(unit: Unit) -> void:
	if not unit:
		push_error("Unit is null")
		return
	owner_unit = unit


## 设置目标
func set_target(target: Unit) -> void:
	if current_target == target:
		return

	var old_target := current_target
	current_target = target
	target_changed.emit(old_target, current_target)


## 清除目标
func clear_target() -> void:
	set_target(null)


## 检查是否有有效目标
func has_valid_target() -> bool:
	if not current_target:
		return false
	if not is_instance_valid(current_target):
		return false
	if current_target.is_dead:
		return false
	return true


## 获取到目标的距离
func get_distance_to_target() -> float:
	if not has_valid_target():
		return INF
	if not owner_unit:
		return INF
	return owner_unit.global_position.distance_to(current_target.global_position)


# ============ 生命周期 ============

func _process(delta: float) -> void:
	if not enabled:
		return
	if not owner_unit:
		return
	if owner_unit.is_dead:
		return

	_update_target(delta)
	_update_movement()
	_update_abilities()
	_check_attack_range()


# ============ 私有方法 ============

## 更新目标
func _update_target(delta: float) -> void:
	_search_timer -= delta
	if _search_timer <= 0:
		_search_timer = search_interval
		_find_target()


## 查找目标
func _find_target() -> void:
	# 如果当前目标无效，清除它
	if current_target and not has_valid_target():
		clear_target()

	# 如果已有有效目标，不重新索敌
	if has_valid_target():
		return

	# 获取敌方单位
	var enemies := UnitManager.get_enemies(owner_unit.team)
	if enemies.is_empty():
		return

	# 根据优先级选择目标
	var priority := owner_unit.data.target_priority
	var new_target := _select_target_by_priority(enemies, priority)
	if new_target:
		set_target(new_target)


## 根据优先级选择目标
func _select_target_by_priority(enemies: Array[Unit], priority: UnitEnums.TargetPriority) -> Unit:
	if enemies.is_empty():
		return null

	match priority:
		UnitEnums.TargetPriority.NEAREST:
			return _get_nearest(enemies)
		UnitEnums.TargetPriority.LOWEST_HEALTH:
			return _get_lowest_health(enemies)
		UnitEnums.TargetPriority.BUILDING_FIRST:
			return _get_building_first(enemies)
		_:
			return _get_nearest(enemies)


## 获取最近的敌人
func _get_nearest(enemies: Array[Unit]) -> Unit:
	var nearest: Unit = null
	var min_dist := INF
	for enemy in enemies:
		var dist := owner_unit.global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
	return nearest


## 获取血量最低的敌人
func _get_lowest_health(enemies: Array[Unit]) -> Unit:
	var lowest: Unit = null
	var min_health := INF
	for enemy in enemies:
		if enemy.current_health < min_health:
			min_health = enemy.current_health
			lowest = enemy
	return lowest


## 获取建筑优先的敌人
func _get_building_first(enemies: Array[Unit]) -> Unit:
	# 优先攻击建筑
	for enemy in enemies:
		if enemy is Building:
			return enemy
	# 没有建筑则选最近的
	return _get_nearest(enemies)


## 更新移动
func _update_movement() -> void:
	if not owner_unit:
		return

	if has_valid_target():
		var distance := get_distance_to_target()
		var attack_range := _get_attack_range()

		if distance > attack_range:
			owner_unit.move_toward(current_target.global_position)
		else:
			owner_unit.stop_moving()
	else:
		owner_unit.move_toward_enemy_base()


## 更新能力
func _update_abilities() -> void:
	if not owner_unit:
		return

	var ability_manager := owner_unit.get_node_or_null("AbilityManager") as AbilityManager
	if not ability_manager:
		return

	# 尝试自动攻击
	if has_valid_target():
		var distance := get_distance_to_target()
		var attack_range := _get_attack_range()

		if distance <= attack_range:
			ability_manager.try_attack(current_target)


## 检查攻击范围变化
func _check_attack_range() -> void:
	if not has_valid_target():
		if _was_in_attack_range:
			_was_in_attack_range = false
		return

	var distance := get_distance_to_target()
	var attack_range := _get_attack_range()
	var is_in_range := distance <= attack_range

	if is_in_range and not _was_in_attack_range:
		entered_attack_range.emit(current_target)
	elif not is_in_range and _was_in_attack_range:
		left_attack_range.emit(current_target)

	_was_in_attack_range = is_in_range


## 获取攻击范围（像素）
func _get_attack_range() -> float:
	if not owner_unit:
		return 0.0

	var ability_manager := owner_unit.get_node_or_null("AbilityManager") as AbilityManager
	if ability_manager:
		return ability_manager.get_max_attack_range() * 80.0  # 转换为像素
	return 0.0
