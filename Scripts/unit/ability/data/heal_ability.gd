# Scripts/unit/ability/data/heal_ability.gd
class_name HealAbility
extends UnitAbility

## 治疗能力 - 恢复友方单位生命值

## 每次治疗量
@export var heal_amount: int = 20

## 治疗范围（格数）
@export var heal_range: float = 2.0

## 治疗间隔（秒）
@export var interval: float = 3.0

## 是否可以治疗自己
@export var target_self: bool = false

## 是否可以治疗友军
@export var target_allies: bool = true
