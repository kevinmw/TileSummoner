# Scripts/unit/ability/data/ranged_attack_ability.gd
class_name RangedAttackAbility
extends UnitAbility

## 远程攻击能力 - 远距离弹道攻击

## 攻击伤害值
@export var damage: int = 10

## 攻击范围（格数）
@export var attack_range: float = 3.0

## 攻击间隔（秒）
@export var attack_interval: float = 1.0

## 弹道飞行速度（格/秒）
@export var projectile_speed: float = 5.0
