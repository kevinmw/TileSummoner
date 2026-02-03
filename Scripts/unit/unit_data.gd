# Scripts/unit/unit_data.gd
@icon("res://Assets/Icons/UI/unit.svg")
class_name UnitData
extends Resource

## 单位数据资源
## 定义单位的所有静态属性

# ============ 基础信息 ============

## 单位唯一标识
@export var id: StringName = &""

## 显示名称
@export var display_name: String = ""

## 单位图标
@export var icon: Texture2D = null

## 单位填充颜色
@export var base_color: Color = Color.WHITE

# ============ 模式与体型 ============

## 单位模式（决定几何形状）
@export var unit_mode: UnitEnums.UnitMode = UnitEnums.UnitMode.WARRIOR

## 单位体型（决定碰撞半径）
@export var unit_size: UnitEnums.UnitSize = UnitEnums.UnitSize.MEDIUM

# ============ 基础属性 ============

## 最大生命值
@export var max_health: int = 100

## 移动速度（格/秒）
@export var move_speed: float = 2.0

## 元素词条
@export var element_tag: UnitEnums.ElementTag = UnitEnums.ElementTag.NEUTRAL

## 移动类型
@export var move_type: UnitEnums.MoveType = UnitEnums.MoveType.GROUND

## 目标优先级
@export var target_priority: UnitEnums.TargetPriority = UnitEnums.TargetPriority.NEAREST

# ============ 能力列表 ============

## 单位拥有的能力
@export var abilities: Array[UnitAbility] = []

# ============ 召唤信息 ============

## 法力消耗
@export var mana_cost: int = 3

## 需要的地形类型
@export var required_terrain: StringName = &""

## 召唤数量（1-3，小组单位）
@export_range(1, 3) var spawn_count: int = 1
