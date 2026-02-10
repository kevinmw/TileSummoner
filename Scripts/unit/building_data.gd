# Scripts/unit/building_data.gd
@icon("res://Assets/Icons/UI/building.svg")
class_name BuildingData
extends UnitData

## 建筑数据资源
## 继承自 UnitData，添加建筑特有属性

# ============ 建筑属性 ============

## 建筑类型
@export var building_type: UnitEnums.BuildingType = UnitEnums.BuildingType.TOWER

## 是否启用护盾
@export var shield_enabled: bool = false

## 护盾需要的塔数量（存活塔数小于此值时护盾消失）
@export var shield_requires_towers: int = 1

## 护盾消失后是否开始攻击
@export var attack_when_vulnerable: bool = false
