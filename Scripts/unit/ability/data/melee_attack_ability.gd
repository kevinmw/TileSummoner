# Scripts/unit/ability/data/melee_attack_ability.gd
class_name MeleeAttackAbility
extends UnitAbility

## 近战攻击能力 - 短距离物理攻击

## 攻击伤害值
@export var damage: int = 10

## 攻击范围（格数）
@export var attack_range: float = 0.5

## 攻击间隔（秒）
@export var attack_interval: float = 1.0
