class_name TestBattleMapController
extends GdUnitTestSuite

## BattleMapController 测试套件
## 测试范围：
## 1. 控制器基础功能
## 2. 数据传递验证
## 3. UI 元素
## 4. 初始化流程


# ============ 常量 ============

const BATTLE_MAP_SCENE := "res://Scenes/battle_map.tscn"


# ============ 测试变量 ============

var _scene: Node2D
var _controller: BattleMapController


# ============ 生命周期 ============

func before_test() -> void:
	# 设置测试数据到 SceneManager
	var test_tiles: Array[TileConstants.TileType] = []
	for i in range(28):
		if i % 2 == 0:
			test_tiles.append(TileConstants.TileType.WATER)
		else:
			test_tiles.append(TileConstants.TileType.ROCK)
	SceneManager.set_player_config(test_tiles)
	SceneManager.current_enemy_difficulty = TileConstants.ConfigType.ENEMY_EASY


func after_test() -> void:
	if _scene and is_instance_valid(_scene):
		_scene.queue_free()
		_scene = null
	_controller = null
	SceneManager.clear_player_config()


# ============ 辅助方法 ============

## 加载场景
func _load_scene() -> void:
	var scene_resource := load(BATTLE_MAP_SCENE) as PackedScene
	_scene = scene_resource.instantiate()
	add_child(_scene)
	_controller = _scene as BattleMapController


# ============ 基础测试 ============

## 测试1：场景可以加载
func test_scene_loads() -> void:
	var scene_resource := load(BATTLE_MAP_SCENE)
	assert_that(scene_resource).is_not_null()


## 测试2：控制器可实例化
func test_controller_instantiation() -> void:
	_load_scene()
	await await_idle_frame()

	assert_that(_controller).is_not_null()
	assert_that(_controller).is_instanceof(BattleMapController)


## 测试3：控制器继承 Node2D
func test_controller_extends_node2d() -> void:
	_load_scene()
	await await_idle_frame()

	assert_that(_controller).is_instanceof(Node2D)


# ============ 节点引用测试 ============

## 测试4：网格管理器引用存在
func test_grid_manager_reference() -> void:
	_load_scene()
	await await_idle_frame()

	var grid_manager := _controller.get_grid_manager()
	assert_that(grid_manager).is_not_null()
	assert_that(grid_manager).is_instanceof(BattleGridManager)


## 测试5：返回按钮存在
func test_back_button_exists() -> void:
	_load_scene()
	await await_idle_frame()

	var back_button := _controller.get_node_or_null("UI/TopBar/BackButton")
	assert_that(back_button).is_not_null()
	assert_that(back_button).is_instanceof(Button)


## 测试6：信息标签存在
func test_info_label_exists() -> void:
	_load_scene()
	await await_idle_frame()

	var info_label := _controller.get_node_or_null("UI/TopBar/InfoLabel")
	assert_that(info_label).is_not_null()
	assert_that(info_label).is_instanceof(Label)


# ============ 数据传递测试 ============

## 测试7：接收 SceneManager 玩家配置
func test_receives_player_config_from_scene_manager() -> void:
	_load_scene()
	await await_idle_frame()
	await get_tree().create_timer(0.2).timeout  # 等待初始化

	var grid_manager := _controller.get_grid_manager()
	var all_tiles := grid_manager.get_all_tiles()

	# 过滤玩家区域地块
	var player_tiles: Array[BattleTile] = []
	for tile: BattleTile in all_tiles:
		if grid_manager.is_player_zone(tile.grid_position):
			player_tiles.append(tile)

	# 验证玩家区域有地块（4行 x 7列 = 28个）
	assert_that(player_tiles.size()).is_equal(28)


## 测试8：接收 SceneManager 敌方难度
func test_receives_enemy_difficulty_from_scene_manager() -> void:
	SceneManager.current_enemy_difficulty = TileConstants.ConfigType.ENEMY_HARD
	_load_scene()
	await await_idle_frame()
	await get_tree().create_timer(0.2).timeout

	var grid_manager := _controller.get_grid_manager()
	var all_tiles := grid_manager.get_all_tiles()

	# 过滤敌方区域地块
	var enemy_tiles: Array[BattleTile] = []
	for tile: BattleTile in all_tiles:
		if grid_manager.is_enemy_zone(tile.grid_position):
			enemy_tiles.append(tile)

	# 验证敌方区域有地块（4行 x 7列 = 28个）
	assert_that(enemy_tiles.size()).is_equal(28)


## 测试9：空配置时使用默认配置
func test_uses_default_config_when_empty() -> void:
	SceneManager.clear_player_config()
	_load_scene()
	await await_idle_frame()
	await get_tree().create_timer(0.2).timeout

	var grid_manager := _controller.get_grid_manager()
	var all_tiles := grid_manager.get_all_tiles()

	# 应该仍然有 63 个地块（9行 x 7列）
	assert_that(all_tiles.size()).is_equal(63)


# ============ 初始化测试 ============

## 测试10：战斗初始化信号发射
func test_battle_initialized_signal_emitted() -> void:
	_load_scene()
	var signal_monitor := monitor_signals(_controller)

	await await_idle_frame()
	await get_tree().create_timer(0.2).timeout

	assert_that(signal_monitor).is_emit_count("battle_initialized", 1)


## 测试11：网格创建后有正确数量的地块
func test_grid_has_correct_tile_count() -> void:
	_load_scene()
	await await_idle_frame()
	await get_tree().create_timer(0.2).timeout

	var grid_manager := _controller.get_grid_manager()
	var all_tiles := grid_manager.get_all_tiles()

	# 9行 x 7列 = 63个地块
	assert_that(all_tiles.size()).is_equal(63)


## 测试12：中线地块生成
func test_middle_row_generated() -> void:
	_load_scene()
	await await_idle_frame()
	await get_tree().create_timer(0.2).timeout

	var grid_manager := _controller.get_grid_manager()

	# 检查中线（第 4 行）
	for x in range(7):
		var tile := grid_manager.get_tile_at(Vector2i(x, 4))
		assert_that(tile).is_not_null()


# ============ UI 测试 ============

## 测试13：信息标签显示难度
func test_info_label_shows_difficulty() -> void:
	SceneManager.current_enemy_difficulty = TileConstants.ConfigType.ENEMY_MEDIUM
	_load_scene()
	await await_idle_frame()
	await get_tree().create_timer(0.2).timeout

	var info_label: Label = _controller.get_node("UI/TopBar/InfoLabel")
	assert_that(info_label.text).contains("Medium")


## 测试14：返回按钮可点击
func test_back_button_pressable() -> void:
	_load_scene()
	await await_idle_frame()

	var back_button: Button = _controller.get_node("UI/TopBar/BackButton")
	assert_that(back_button.disabled).is_false()


## 测试15：返回按钮触发信号
func test_back_button_emits_signal() -> void:
	_load_scene()
	await await_idle_frame()

	var signal_monitor := monitor_signals(_controller)
	var back_button: Button = _controller.get_node("UI/TopBar/BackButton")
	back_button.pressed.emit()

	assert_that(signal_monitor).is_emit_count("back_requested", 1)


# ============ 公共方法测试 ============

## 测试16：get_grid_manager 返回正确实例
func test_get_grid_manager_returns_correct_instance() -> void:
	_load_scene()
	await await_idle_frame()

	var grid_manager := _controller.get_grid_manager()
	var expected := _controller.get_node("BattleGridManager")

	assert_that(grid_manager).is_same(expected)
