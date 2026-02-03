# Scripts/unit/ability/instance/ability_instance.gd
class_name AbilityInstance
extends Node

## 能力实例基类
## 管理能力的运行时状态

# ============ 属性 ============

## 能力数据
var data: UnitAbility

## 所属单位
var owner_unit: Unit

## 冷却计时器
var cooldown_timer: float = 0.0

## 是否就绪
var is_ready: bool = true

# ============ 公共方法 ============

## 初始化
func initialize(ability_data: UnitAbility, unit: Unit) -> void:
	data = ability_data
	owner_unit = unit
	name = str(ability_data.id) if ability_data.id else "ability"


## 是否可执行
func can_execute() -> bool:
	return is_ready


## 执行能力（子类重写）
func execute(_target: Unit = null) -> void:
	pass


## 获取攻击范围（子类重写）
func get_attack_range() -> float:
	return 0.0


# ============ 生命周期 ============

func _process(delta: float) -> void:
	_update_cooldown(delta)
	_check_trigger()


func _update_cooldown(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0.0
			is_ready = true


func _check_trigger() -> void:
	# 子类重写实现自动触发逻辑
	pass


# ============ 受保护方法 ============

func _start_cooldown(duration: float) -> void:
	cooldown_timer = duration
	is_ready = false
