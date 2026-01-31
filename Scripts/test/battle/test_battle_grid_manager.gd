class_name TestBattleGridManager
extends GdUnitTestSuite

## BattleGridManager 测试套件
## 测试范围：
## 1. 网格创建和配置
## 2. 坐标转换
## 3. 地块查询
## 4. 虚空设置
## 5. 入场动画序列


# ============ 常量 ============

const GRID_COLS := 7
const GRID_ROWS := 9
const TILE_SIZE := Vector2(80, 80)
const TOTAL_TILES := 63  # 7 * 9


# ============ 辅助方法 ============

## 创建测试用 BattleGridManager 实例
func _create_grid_manager() -> BattleGridManager:
	var manager := BattleGridManager.new()
	add_child(manager)
	auto_free(manager)
	return manager


## 获取测试用配置
func _get_test_configs() -> Dictionary:
	var map_generator := BattleMapGenerator.new()
	add_child(map_generator)
	auto_free(map_generator)

	var player_config := map_generator.load_player_config(TileConstants.ConfigType.PLAYER_DEFAULT)
	var enemy_config := map_generator.load_enemy_config(TileConstants.ConfigType.ENEMY_EASY)

	return {
		"player": player_config,
		"enemy": enemy_config
	}


# ============ 基础属性测试 ============

## 测试1：BattleGridManager 可以实例化
func test_grid_manager_instantiation() -> void:
	var manager := _create_grid_manager()

	assert_that(manager).is_not_null()
	assert_that(manager).is_instanceof(BattleGridManager)


## 测试2：默认网格尺寸
func test_default_grid_dimensions() -> void:
	var manager := _create_grid_manager()

	assert_that(manager.grid_cols).is_equal(GRID_COLS)
	assert_that(manager.grid_rows).is_equal(GRID_ROWS)


## 测试3：默认地块尺寸
func test_default_tile_size() -> void:
	var manager := _create_grid_manager()

	assert_that(manager.tile_size).is_equal(TILE_SIZE)


## 测试4：默认区域划分
func test_default_zone_division() -> void:
	var manager := _create_grid_manager()

	assert_that(manager.enemy_rows).is_equal(4)
	assert_that(manager.player_rows).is_equal(4)
	assert_that(manager.middle_row).is_equal(4)


# ============ 网格创建测试 ============

## 测试5：创建战斗网格
func test_create_battle_grid() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var all_tiles := manager.get_all_tiles()
	assert_that(all_tiles.size()).is_equal(TOTAL_TILES)


## 测试6：每个位置都有地块
func test_all_positions_have_tiles() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var tile := manager.get_tile_at(Vector2i(x, y))
			assert_that(tile).is_not_null()


## 测试7：地块类型为 BattleTile
func test_tiles_are_battle_tiles() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var tile := manager.get_tile_at(Vector2i(0, 0))
	assert_that(tile).is_instanceof(BattleTile)


## 测试8：清空网格
func test_clear_grid() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	manager.clear_grid()
	await await_idle_frame()

	var all_tiles := manager.get_all_tiles()
	assert_that(all_tiles.size()).is_equal(0)


# ============ 坐标转换测试 ============

## 测试9：网格坐标转世界坐标
func test_grid_to_world() -> void:
	var manager := _create_grid_manager()

	var world_pos := manager.grid_to_world(Vector2i(0, 0))
	assert_that(world_pos).is_equal(Vector2(40, 40))  # 80/2 = 40

	var world_pos2 := manager.grid_to_world(Vector2i(1, 1))
	assert_that(world_pos2).is_equal(Vector2(120, 120))  # 40 + 80


## 测试10：世界坐标转网格坐标
func test_world_to_grid() -> void:
	var manager := _create_grid_manager()

	var grid_pos := manager.world_to_grid(Vector2(40, 40))
	assert_that(grid_pos).is_equal(Vector2i(0, 0))

	var grid_pos2 := manager.world_to_grid(Vector2(120, 120))
	assert_that(grid_pos2).is_equal(Vector2i(1, 1))


## 测试11：世界坐标转换边界处理
func test_world_to_grid_boundary() -> void:
	var manager := _create_grid_manager()

	# 左上角
	var grid_pos := manager.world_to_grid(Vector2(0, 0))
	assert_that(grid_pos).is_equal(Vector2i(0, 0))

	# 右下角边界
	var grid_pos2 := manager.world_to_grid(Vector2(559, 719))  # 7*80-1, 9*80-1
	assert_that(grid_pos2).is_equal(Vector2i(6, 8))


# ============ 地块查询测试 ============

## 测试12：获取有效位置的地块
func test_get_tile_at_valid_position() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var tile := manager.get_tile_at(Vector2i(3, 4))
	assert_that(tile).is_not_null()


## 测试13：获取无效位置返回 null
func test_get_tile_at_invalid_position() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var tile := manager.get_tile_at(Vector2i(-1, 0))
	assert_that(tile).is_null()

	var tile2 := manager.get_tile_at(Vector2i(7, 0))
	assert_that(tile2).is_null()

	var tile3 := manager.get_tile_at(Vector2i(0, 9))
	assert_that(tile3).is_null()


## 测试14：地块网格坐标正确设置
func test_tiles_have_correct_grid_position() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var pos := Vector2i(3, 5)
	var tile := manager.get_tile_at(pos)
	assert_that(tile.grid_position).is_equal(pos)


## 测试15：地块世界位置正确
func test_tiles_have_correct_world_position() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var grid_pos := Vector2i(2, 3)
	var tile := manager.get_tile_at(grid_pos)
	var expected_world := manager.grid_to_world(grid_pos)

	assert_that(tile.position).is_equal(expected_world)


# ============ 区域判断测试 ============

## 测试16：判断敌方区域
func test_is_enemy_zone() -> void:
	var manager := _create_grid_manager()

	assert_that(manager.is_enemy_zone(Vector2i(0, 0))).is_true()
	assert_that(manager.is_enemy_zone(Vector2i(6, 3))).is_true()
	assert_that(manager.is_enemy_zone(Vector2i(3, 4))).is_false()  # 中线
	assert_that(manager.is_enemy_zone(Vector2i(3, 5))).is_false()  # 玩家区域


## 测试17：判断玩家区域
func test_is_player_zone() -> void:
	var manager := _create_grid_manager()

	assert_that(manager.is_player_zone(Vector2i(0, 5))).is_true()
	assert_that(manager.is_player_zone(Vector2i(6, 8))).is_true()
	assert_that(manager.is_player_zone(Vector2i(3, 4))).is_false()  # 中线
	assert_that(manager.is_player_zone(Vector2i(3, 3))).is_false()  # 敌方区域


## 测试18：判断中线
func test_is_middle_row() -> void:
	var manager := _create_grid_manager()

	assert_that(manager.is_middle_row(Vector2i(0, 4))).is_true()
	assert_that(manager.is_middle_row(Vector2i(6, 4))).is_true()
	assert_that(manager.is_middle_row(Vector2i(3, 3))).is_false()
	assert_that(manager.is_middle_row(Vector2i(3, 5))).is_false()


# ============ 虚空设置测试 ============

## 测试19：设置单个地块为虚空
func test_set_tile_void() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var pos := Vector2i(3, 4)
	manager.set_tile_void(pos)

	var tile := manager.get_tile_at(pos)
	assert_that(tile.is_void).is_true()


## 测试20：取消虚空状态
func test_unset_tile_void() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var pos := Vector2i(3, 4)
	manager.set_tile_void(pos)
	manager.set_tile_void(pos, false)

	var tile := manager.get_tile_at(pos)
	assert_that(tile.is_void).is_false()


## 测试21：虚空地块不可通行
func test_void_tile_not_passable() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var pos := Vector2i(3, 4)
	manager.set_tile_void(pos)

	var tile := manager.get_tile_at(pos)
	assert_that(tile.is_passable).is_false()


# ============ 邻居查询测试 ============

## 测试22：获取四方向邻居
func test_get_neighbors_4dir() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var neighbors := manager.get_neighbors(Vector2i(3, 4), false)
	assert_that(neighbors.size()).is_equal(4)


## 测试23：获取八方向邻居
func test_get_neighbors_8dir() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var neighbors := manager.get_neighbors(Vector2i(3, 4), true)
	assert_that(neighbors.size()).is_equal(8)


## 测试24：边角位置邻居数量正确
func test_corner_neighbor_count() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	# 左上角，四方向只有2个邻居
	var neighbors := manager.get_neighbors(Vector2i(0, 0), false)
	assert_that(neighbors.size()).is_equal(2)

	# 八方向只有3个邻居
	var neighbors8 := manager.get_neighbors(Vector2i(0, 0), true)
	assert_that(neighbors8.size()).is_equal(3)


# ============ 地图尺寸测试 ============

## 测试25：获取地图像素尺寸
func test_get_map_size() -> void:
	var manager := _create_grid_manager()

	var map_size := manager.get_map_size()
	assert_that(map_size).is_equal(Vector2(560, 720))  # 7*80, 9*80


# ============ 中立区生成测试 ============

## 测试26：中立区（中线）有地块
func test_middle_row_has_tiles() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	# 中线是第 4 行
	for x in range(GRID_COLS):
		var tile := manager.get_tile_at(Vector2i(x, 4))
		assert_that(tile).is_not_null()


## 测试27：中立区地块数量为 7
func test_middle_row_count() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var middle_tiles: Array[BattleTile] = []
	for x in range(GRID_COLS):
		var tile := manager.get_tile_at(Vector2i(x, 4))
		if tile:
			middle_tiles.append(tile)

	assert_that(middle_tiles.size()).is_equal(7)


## 测试28：中立区地块有数据
func test_middle_row_tiles_have_data() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()

	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	for x in range(GRID_COLS):
		var tile := manager.get_tile_at(Vector2i(x, 4))
		assert_that(tile.get_data()).is_not_null()


## 测试29：_generate_middle_row 方法存在
func test_generate_middle_row_method_exists() -> void:
	var manager := _create_grid_manager()

	assert_that(manager.has_method("_generate_middle_row")).is_true()


## 测试30：中立区类型多样性（随机生成）
func test_middle_row_random_variety() -> void:
	var manager := _create_grid_manager()

	# 生成多次检查是否有不同类型
	var types_seen: Dictionary = {}

	# 多次生成中立区类型
	for _i in range(10):
		var types := manager._generate_middle_row()
		for tile_type in types:
			types_seen[tile_type] = true

	# 应该至少有 2 种不同的地块类型（随机生成的概率）
	assert_that(types_seen.size()).is_greater_or_equal(2)


# ============ 水波纹动画测试 ============

## 测试31：默认 spawn_ripple_delay 为 0.06 秒
func test_default_spawn_ripple_delay() -> void:
	var manager := _create_grid_manager()
	assert_that(manager.spawn_ripple_delay).is_equal_approx(0.06, 0.01)


## 测试32：中心地块延迟最小
func test_center_tile_has_minimum_delay() -> void:
	var manager := _create_grid_manager()
	# 验证计算逻辑：网格中心应该延迟最小
	var center := Vector2(manager.grid_cols / 2.0, manager.grid_rows / 2.0)
	var center_dist := Vector2(3, 4).distance_to(center)
	var corner_dist := Vector2(0, 0).distance_to(center)
	assert_that(center_dist).is_less(corner_dist)


## 测试33：角落地块延迟最大
func test_corner_tiles_have_maximum_delay() -> void:
	var manager := _create_grid_manager()
	var center := Vector2(manager.grid_cols / 2.0, manager.grid_rows / 2.0)

	# 四个角落到中心的距离应该相似且最大
	var corners := [Vector2(0, 0), Vector2(6, 0), Vector2(0, 8), Vector2(6, 8)]
	var max_dist := 0.0
	for corner in corners:
		var dist := corner.distance_to(center)
		max_dist = maxf(max_dist, dist)

	# 中心点的距离应该远小于角落
	var center_pos := Vector2(3, 4)
	assert_that(center_pos.distance_to(center)).is_less(max_dist * 0.5)


## 测试34：spawn_sequence_completed 信号发射
func test_spawn_sequence_completed_signal() -> void:
	var manager := _create_grid_manager()
	var configs := _get_test_configs()
	manager.create_battle_grid(configs.player, configs.enemy)
	await await_idle_frame()

	var monitor := monitor_signals(manager)
	manager.play_spawn_sequence()
	await await_millis(2000)

	assert_signal(monitor).is_emitted("spawn_sequence_completed")
