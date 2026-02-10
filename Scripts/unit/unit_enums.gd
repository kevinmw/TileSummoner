# Scripts/unit/unit_enums.gd
class_name UnitEnums
extends RefCounted

## 单位模式（决定几何形状）
enum UnitMode {
	TANK,      ## 肉盾型 - 六边形
	WARRIOR,   ## 战士型 - 八边形
	ASSASSIN,  ## 刺客型 - 三角形
	MAGE,      ## 法师型 - 圆形
	SUPPORT,   ## 辅助型 - 菱形
	BUILDING   ## 建筑型 - 正方形
}

## 单位体型（决定碰撞半径）
enum UnitSize {
	SMALL,   ## 小型 - 0.2格
	MEDIUM,  ## 中型 - 0.5格
	LARGE,   ## 大型 - 0.8格
	HUGE     ## 巨大型 - 1.2格
}

## 元素词条
enum ElementTag {
	EARTH,    ## 地
	WIND,     ## 风
	WATER,    ## 水
	FIRE,     ## 火
	GRASS,    ## 草
	METAL,    ## 金
	ICE,      ## 冰
	NEUTRAL   ## 通用
}

## 移动类型
enum MoveType {
	GROUND,  ## 地面
	FLYING   ## 飞行
}

## 能力触发类型
enum AbilityTrigger {
	AUTO,              ## 自动攻击（持续）
	ON_COMBAT_START,   ## 首次交战
	PERIODIC,          ## 周期性（每N秒）
	ON_HEALTH_BELOW,   ## 生命低于X%
	ON_ATTACK_COUNT,   ## 攻击N次后
	ON_HIT_COUNT,      ## 受击N次后
	ON_ENEMY_COUNT,    ## 范围内敌人>X
	ON_DEATH,          ## 死亡时
	ON_ENERGY_FULL     ## 能量槽满
}

## 目标优先级
enum TargetPriority {
	NEAREST,        ## 最近目标
	LOWEST_HEALTH,  ## 最低血量
	HIGHEST_THREAT, ## 最高威胁
	BUILDING_FIRST  ## 建筑优先
}

## 建筑类型
enum BuildingType {
	TOWER,  ## 防御塔
	BASE    ## 主基地
}
