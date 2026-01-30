## 战斗场景控制器
##
## 管理战斗场景的初始化和流程
extends Node
class_name BattleSceneController

## 战斗地图生成器
@onready var _map_generator: BattleMapGenerator = $BattleMapGenerator

## 网格管理器（新版本使用 BattleGridManager）
@onready var _grid_manager: BattleGridManager = $GameLayer/BattleGridManager

## 返回按钮
@onready var _back_button: Button = $UI/TopBar/BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	call_deferred("_initialize_battle")


## 初始化战斗
func _initialize_battle() -> void:
	var enemy_difficulty: TileConstants.ConfigType = SceneManager.current_enemy_difficulty

	# 检查是否有玩家编辑的配置
	var player_config := SceneManager.get_player_config()

	# 加载配置
	var player_tile_config := _map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)
	var enemy_tile_config := _map_generator.load_enemy_config(enemy_difficulty)

	# 如果有玩家自定义配置，覆盖默认配置
	if not player_config.is_empty():
		player_tile_config = TileConfig.new()
		player_tile_config.config_type = TileConstants.ConfigType.PLAYER_DEFAULT
		player_tile_config.player_tiles = player_config

	# 使用 BattleGridManager 创建战斗网格
	_grid_manager.create_battle_grid(player_tile_config, enemy_tile_config)

	# 播放入场动画
	_grid_manager.play_spawn_sequence()

	# 居中显示网格
	_center_grid()


## 居中显示网格
func _center_grid() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var map_size := _grid_manager.get_map_size()
	_grid_manager.position = (viewport_size - map_size) / 2


## 返回按钮回调
func _on_back_pressed() -> void:
	SceneManager.transition_to_terrain_config()
