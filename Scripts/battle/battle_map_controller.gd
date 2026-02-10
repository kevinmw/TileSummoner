## 战斗地图控制器
##
## 管理战斗地图的初始化、数据加载和 UI 交互
extends Node2D
class_name BattleMapController


# ============ 信号 ============

## 战斗初始化完成
signal battle_initialized()

## 返回请求
signal back_requested()

## 玩家护盾破碎
signal player_shield_broken()

## 敌方护盾破碎
signal enemy_shield_broken()

## 战斗结束 (0=玩家胜, 1=敌方胜)
signal battle_ended(winner: int)


# ============ 导出变量 ============

@export_group("Building Positions")
@export var player_base_pos := Vector2i(3, 8)
@export var player_tower_positions: Array[Vector2i] = [Vector2i(1, 7), Vector2i(5, 7)]
@export var enemy_base_pos := Vector2i(3, 0)
@export var enemy_tower_positions: Array[Vector2i] = [Vector2i(1, 1), Vector2i(5, 1)]

@export_group("Building Data")
@export var tower_data: BuildingData
@export var base_data: BuildingData

@export_group("Test Units")
@export var test_unit_data: UnitData


# ============ 节点引用 ============

## 网格管理器
@onready var _grid_manager: BattleGridManager = $BattleGridManager

## 建筑容器
@onready var _buildings_container: Node2D = $BuildingsContainer

## 单位容器
@onready var _units_container: Node2D = $UnitsContainer

## 返回按钮
@onready var _back_button: Button = $UI/TopBar/BackButton

## 信息标签
@onready var _info_label: Label = $UI/TopBar/InfoLabel


# ============ 内部变量 ============

## 地图生成器
var _map_generator: BattleMapGenerator

## 玩家建筑控制器
var _player_building_controller: BuildingController

## 敌方建筑控制器
var _enemy_building_controller: BuildingController


# ============ 生命周期 ============

func _ready() -> void:
	_map_generator = BattleMapGenerator.new()

	if _back_button:
		_back_button.pressed.connect(_on_back_pressed)

	call_deferred("_initialize_battle")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		# 按空格生成测试单位
		_spawn_test_unit(0, Vector2i(3, 6))  # 玩家单位
	elif event.is_action_pressed("ui_focus_next"):
		# 按 Tab 生成敌方测试单位
		_spawn_test_unit(1, Vector2i(3, 2))  # 敌方单位


# ============ 初始化 ============

## 初始化战斗
func _initialize_battle() -> void:
	if not _grid_manager:
		push_error("BattleGridManager not found")
		return

	# 从 SceneManager 获取配置
	var enemy_difficulty := SceneManager.current_enemy_difficulty
	var player_config := SceneManager.get_player_config()

	# 加载敌方配置文件
	var enemy_tile_config := _map_generator.load_enemy_config(enemy_difficulty)

	# 创建玩家配置
	var player_tile_config := TileConfig.new()
	player_tile_config.config_type = TileConstants.ConfigType.PLAYER_DEFAULT

	if not player_config.is_empty():
		# 使用 UI 中配置的数据
		player_tile_config.player_tiles = player_config
	else:
		# 无配置时加载默认
		player_tile_config = _map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)

	# 创建战斗网格
	_grid_manager.create_battle_grid(player_tile_config, enemy_tile_config)

	# 居中显示网格
	_center_grid()

	# 更新 UI
	_update_info_label(enemy_difficulty)

	# 播放入场动画，完成后初始化建筑
	_grid_manager.spawn_sequence_completed.connect(_on_grid_spawn_completed, CONNECT_ONE_SHOT)
	_grid_manager.play_spawn_sequence()


## 居中显示网格
func _center_grid() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var map_size := _grid_manager.get_map_size()
	var center_offset := (viewport_size - map_size) / 2

	_grid_manager.position = center_offset

	# 同步居中建筑容器（与网格使用相同偏移）
	if _buildings_container:
		_buildings_container.position = center_offset

	# 同步居中单位容器
	if _units_container:
		_units_container.position = center_offset

	# 同步居中 BattleGridContainer
	var grid_container := get_node_or_null("BattleGridContainer") as BattleGridContainer
	if grid_container:
		# BattleGridContainer 使用 PADDING 和 TILE_GAP，需要计算正确偏移
		# 容器从左上角绘制，所以需要考虑尺寸差异
		var container_size := grid_container.get_total_size()
		var container_offset := (viewport_size - container_size) / 2
		grid_container.position = container_offset


## 更新信息标签
func _update_info_label(difficulty: TileConstants.ConfigType) -> void:
	if not _info_label:
		return

	var difficulty_names := {
		TileConstants.ConfigType.ENEMY_EASY: "Easy",
		TileConstants.ConfigType.ENEMY_MEDIUM: "Medium",
		TileConstants.ConfigType.ENEMY_HARD: "Hard",
	}

	var difficulty_name: String = difficulty_names.get(difficulty, "Unknown")
	_info_label.text = "Difficulty: %s" % difficulty_name


# ============ 公共方法 ============

## 获取网格管理器
func get_grid_manager() -> BattleGridManager:
	return _grid_manager


# ============ 信号回调 ============

## 返回按钮回调
func _on_back_pressed() -> void:
	back_requested.emit()
	SceneManager.transition_to_terrain_config()


## 网格入场动画完成回调
func _on_grid_spawn_completed() -> void:
	_initialize_buildings()
	battle_initialized.emit()


# ============ 建筑系统 ============

## 初始化建筑
func _initialize_buildings() -> void:
	if not tower_data or not base_data:
		push_warning("Building data not configured, skipping building initialization")
		return

	# 创建建筑控制器
	_player_building_controller = BuildingController.new()
	_player_building_controller.name = "PlayerBuildingController"
	add_child(_player_building_controller)

	_enemy_building_controller = BuildingController.new()
	_enemy_building_controller.name = "EnemyBuildingController"
	add_child(_enemy_building_controller)

	# 创建玩家建筑 (team = 0)
	var player_base := _create_building(base_data, 0, player_base_pos)
	if player_base:
		_player_building_controller.set_base(player_base)

	for tower_pos in player_tower_positions:
		var tower := _create_building(tower_data, 0, tower_pos)
		if tower:
			_player_building_controller.register_tower(tower)

	# 创建敌方建筑 (team = 1)
	var enemy_base := _create_building(base_data, 1, enemy_base_pos)
	if enemy_base:
		_enemy_building_controller.set_base(enemy_base)

	for tower_pos in enemy_tower_positions:
		var tower := _create_building(tower_data, 1, tower_pos)
		if tower:
			_enemy_building_controller.register_tower(tower)

	# 监听护盾事件
	_player_building_controller.shield_broken.connect(_on_player_shield_broken)
	_enemy_building_controller.shield_broken.connect(_on_enemy_shield_broken)

	# 监听基地死亡（胜负判定）
	if _player_building_controller.base:
		_player_building_controller.base.died.connect(_on_player_base_destroyed)
	if _enemy_building_controller.base:
		_enemy_building_controller.base.died.connect(_on_enemy_base_destroyed)

	print("[BattleMap] Buildings initialized")


## 创建建筑
func _create_building(data: BuildingData, team: int, grid_pos: Vector2i) -> Building:
	if not data:
		push_error("BuildingData is null")
		return null

	var building: Building = preload("res://Scenes/unit/building.tscn").instantiate()

	# 设置位置（网格坐标转世界坐标）
	building.position = _grid_manager.grid_to_world(grid_pos)

	# 添加到对应容器
	var container: Node2D
	if team == 0:
		container = _buildings_container.get_node("PlayerBuildings")
	else:
		container = _buildings_container.get_node("EnemyBuildings")
	container.add_child(building)

	# 初始化建筑
	building.initialize(data, team)

	# 占据地块
	var tile := _grid_manager.get_tile_at(grid_pos)
	if tile:
		tile.occupying_unit = building

	return building


## 玩家护盾破碎回调
func _on_player_shield_broken() -> void:
	print("[BattleMap] Player shield broken!")
	player_shield_broken.emit()


## 敌方护盾破碎回调
func _on_enemy_shield_broken() -> void:
	print("[BattleMap] Enemy shield broken!")
	enemy_shield_broken.emit()


## 玩家基地被摧毁回调
func _on_player_base_destroyed(_killer: Unit) -> void:
	print("[BattleMap] Player base destroyed - DEFEAT")
	battle_ended.emit(1)


## 敌方基地被摧毁回调
func _on_enemy_base_destroyed(_killer: Unit) -> void:
	print("[BattleMap] Enemy base destroyed - VICTORY")
	battle_ended.emit(0)


# ============ 测试功能 ============

## 生成测试单位
func _spawn_test_unit(team: int, grid_pos: Vector2i) -> void:
	if not test_unit_data:
		push_warning("Test unit data not configured")
		return

	if not _grid_manager:
		return

	var unit: Unit = preload("res://Scenes/unit/unit.tscn").instantiate()

	# 设置位置
	unit.position = _grid_manager.grid_to_world(grid_pos)

	# 添加到单位容器
	_units_container.add_child(unit)

	# 初始化单位
	unit.initialize(test_unit_data, team)

	print("[BattleMap] Spawned test unit at %s (team %d)" % [grid_pos, team])
