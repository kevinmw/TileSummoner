# Scripts/unit/unit_factory.gd
class_name UnitFactory
extends RefCounted

## 单位工厂
## 负责创建和初始化单位实例

const UNIT_SCENE: PackedScene = preload("res://Scenes/unit/unit.tscn")
const TILE_SIZE: float = 80.0


## 创建单个单位
## @param data: 单位数据
## @param pos: 世界坐标位置
## @param team: 所属阵营 (0=己方, 1=敌方)
## @return: 创建的单位实例，失败返回 null
static func create(data: UnitData, pos: Vector2, team: int) -> Unit:
	if not data:
		push_error("UnitFactory.create: UnitData is null")
		return null

	var unit: Unit = UNIT_SCENE.instantiate()
	unit.initialize(data, team)
	unit.global_position = pos
	return unit


## 创建单位组（小队）
## 根据 UnitData.spawn_count 创建多个单位
## @param data: 单位数据
## @param pos: 中心世界坐标位置
## @param team: 所属阵营
## @return: 创建的单位数组
static func create_group(data: UnitData, pos: Vector2, team: int) -> Array[Unit]:
	var units: Array[Unit] = []

	if not data:
		push_error("UnitFactory.create_group: UnitData is null")
		return units

	var spawn_count := data.spawn_count

	for i in spawn_count:
		var offset := _get_group_offset(i, spawn_count)
		var unit := create(data, pos + offset, team)
		if unit:
			units.append(unit)

	return units


## 获取小队成员的位置偏移
## 单个单位时无偏移，多个单位时围绕中心点均匀分布
## @param index: 成员索引
## @param total: 总成员数
## @return: 位置偏移向量
static func _get_group_offset(index: int, total: int) -> Vector2:
	if total == 1:
		return Vector2.ZERO

	# 小组成员围绕中心点分布
	var angle := TAU * index / total
	var radius := 0.3 * TILE_SIZE
	return Vector2(cos(angle), sin(angle)) * radius
