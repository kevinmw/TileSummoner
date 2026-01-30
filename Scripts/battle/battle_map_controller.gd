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


# ============ 节点引用 ============

## 网格管理器
@onready var _grid_manager: BattleGridManager = $BattleGridManager

## 返回按钮
@onready var _back_button: Button = $UI/TopBar/BackButton

## 信息标签
@onready var _info_label: Label = $UI/TopBar/InfoLabel


# ============ 内部变量 ============

## 地图生成器
var _map_generator: BattleMapGenerator


# ============ 生命周期 ============

func _ready() -> void:
	_map_generator = BattleMapGenerator.new()

	if _back_button:
		_back_button.pressed.connect(_on_back_pressed)

	call_deferred("_initialize_battle")


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
	_grid_manager.play_spawn_sequence()

	# 居中显示网格
	_center_grid()

	# 更新 UI
	_update_info_label(enemy_difficulty)

	battle_initialized.emit()


## 居中显示网格
func _center_grid() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var map_size := _grid_manager.get_map_size()
	var center_offset := (viewport_size - map_size) / 2

	_grid_manager.position = center_offset

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
