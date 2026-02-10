# Scripts/unit/unit_config.gd
class_name UnitConfig
extends RefCounted

## 单位配置
## 提供体型半径、形状边数等配置查询


## 体型对应的碰撞半径（格为单位）
const SIZE_RADIUS: Dictionary = {
	UnitEnums.UnitSize.SMALL: 0.2,
	UnitEnums.UnitSize.MEDIUM: 0.5,
	UnitEnums.UnitSize.LARGE: 0.8,
	UnitEnums.UnitSize.HUGE: 1.2
}

## 模式对应的形状边数（0表示圆形）
const MODE_SIDES: Dictionary = {
	UnitEnums.UnitMode.TANK: 6,      # 六边形
	UnitEnums.UnitMode.WARRIOR: 8,   # 八边形
	UnitEnums.UnitMode.ASSASSIN: 3,  # 三角形
	UnitEnums.UnitMode.MAGE: 0,      # 圆形
	UnitEnums.UnitMode.SUPPORT: 4,   # 菱形（旋转45度的正方形）
	UnitEnums.UnitMode.BUILDING: 4   # 正方形
}

## 阵营颜色
const TEAM_COLORS: Dictionary = {
	0: Color.DODGER_BLUE,   # 己方 - 蓝色
	1: Color.INDIAN_RED     # 敌方 - 红色
}


## 获取体型对应的碰撞半径
static func get_size_radius(size: UnitEnums.UnitSize) -> float:
	return SIZE_RADIUS.get(size, 0.5)


## 获取模式对应的形状边数
static func get_shape_sides(mode: UnitEnums.UnitMode) -> int:
	return MODE_SIDES.get(mode, 4)


## 获取阵营颜色
static func get_team_color(team: int) -> Color:
	return TEAM_COLORS.get(team, Color.WHITE)


## 判断模式是否为圆形
static func is_circle_shape(mode: UnitEnums.UnitMode) -> bool:
	return get_shape_sides(mode) == 0


## 判断模式是否需要旋转（菱形、正方形边朝上）
static func needs_rotation(mode: UnitEnums.UnitMode) -> bool:
	return mode == UnitEnums.UnitMode.SUPPORT or mode == UnitEnums.UnitMode.BUILDING
