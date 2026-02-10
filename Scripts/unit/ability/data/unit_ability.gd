# Scripts/unit/ability/data/unit_ability.gd
class_name UnitAbility
extends Resource

## 能力基类 - 所有单位能力的基础数据容器

## 能力唯一标识符
@export var id: StringName = &""

## 能力触发类型
@export var trigger: UnitEnums.AbilityTrigger = UnitEnums.AbilityTrigger.AUTO
