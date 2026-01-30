extends Node2D

## 战斗场景测试控制器
## 用于可视化测试 BattleBackground、BattleGridManager、BattleTile


# ============ 子节点引用 ============

@onready var _background: BattleBackground = $Background
@onready var _grid_manager: BattleGridManager = $GameLayer/GridManager


# ============ 测试状态 ============

var _center_void: bool = false


# ============ 生命周期 ============

func _ready() -> void:
	# 等待一帧确保所有节点就绪
	await get_tree().process_frame

	_initialize_test()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				_toggle_center_void()
			KEY_R:
				_replay_spawn_animation()
			KEY_ESCAPE:
				get_tree().quit()


# ============ 初始化 ============

func _initialize_test() -> void:
	print("[TestBattleScene] Initializing...")

	# 启动背景动画
	if _background:
		_background.start_animations()
		print("[TestBattleScene] Background animations started")

	# 创建战斗网格
	_create_test_grid()


func _create_test_grid() -> void:
	if not _grid_manager:
		push_error("[TestBattleScene] GridManager not found")
		return

	# 加载配置
	var map_generator := BattleMapGenerator.new()
	add_child(map_generator)

	var player_config := map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)
	var enemy_config := map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_EASY)

	# 创建网格
	_grid_manager.create_battle_grid(player_config, enemy_config)

	print("[TestBattleScene] Grid created with %d tiles" % _grid_manager.get_all_tiles().size())

	# 居中网格
	_center_grid()

	# 播放入场动画
	await get_tree().create_timer(0.5).timeout
	_grid_manager.play_spawn_sequence()

	# 清理临时节点
	map_generator.queue_free()


func _center_grid() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var map_size := _grid_manager.get_map_size()

	var offset := (viewport_size - map_size) / 2
	_grid_manager.position = offset

	print("[TestBattleScene] Grid centered at %s" % offset)


# ============ 测试功能 ============

func _toggle_center_void() -> void:
	_center_void = not _center_void

	# 中心位置
	var center := Vector2i(3, 4)
	_grid_manager.set_tile_void(center, _center_void)

	var state := "VOID" if _center_void else "NORMAL"
	print("[TestBattleScene] Center tile (%s) set to %s" % [center, state])


func _replay_spawn_animation() -> void:
	print("[TestBattleScene] Replaying spawn animation...")

	# 重置所有地块位置
	for tile in _grid_manager.get_all_tiles():
		tile.position = _grid_manager.grid_to_world(tile.grid_position)

	# 播放动画
	_grid_manager.play_spawn_sequence()
