# Scripts/unit/ability/data/summon_ability.gd
class_name SummonAbility
extends UnitAbility

## 召唤能力 - 生成新单位

## 召唤的单位数据（UnitData 资源）
@export var summon_unit: Resource = null

## 每次召唤的单位数量
@export var summon_count: int = 1

## 召唤位置偏移（相对于施法者）
@export var summon_offset: Vector2 = Vector2.ZERO
