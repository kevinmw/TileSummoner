extends Node2D
class_name BattleGridManager

## 战斗网格管理器
## 负责创建、管理和查询战斗地块网格


# ============ 信号 ============

## 网格创建完成
signal grid_created()

## 网格清空完成
signal grid_cleared()

## 入场动画完成
signal spawn_sequence_completed()


# ============ 导出变量 ============

## 网格列数
@export var grid_cols: int = 7

## 网格行数
@export var grid_rows: int = 9

## 地块尺寸（像素）
@export var tile_size: Vector2 = Vector2(80, 80)

## 敌方区域行数（从顶部开始）
@export var enemy_rows: int = 4

## 玩家区域行数（从底部开始）
@export var player_rows: int = 4

## 中线行索引
@export var middle_row: int = 4

## 入场动画：波纹扩散延迟（每单位距离的秒数）
@export var spawn_ripple_delay: float = 0.06

## 地块间距（像素）
@export var tile_spacing: float = 2.0


# ============ 常量 ============

## BattleTile 场景路径
const BATTLE_TILE_SCENE := preload("res://Scenes/battle/battle_tile.tscn")


# ============ 内部变量 ============

## 网格数据（二维数组）
var _grid: Array[Array] = []

## 是否已初始化
var _initialized: bool = false


# ============ 生命周期 ============

func _ready() -> void:
	_init_grid_array()


# ============ 初始化 ============

## 初始化网格数组
func _init_grid_array() -> void:
	_grid.clear()
	for y in range(grid_rows):
		var row: Array[BattleTile] = []
		row.resize(grid_cols)
		_grid.append(row)


# ============ 网格创建 ============

## 创建战斗网格
func create_battle_grid(player_config: TileConfig, enemy_config: TileConfig) -> void:
	# 清空现有网格
	clear_grid()
	_init_grid_array()

	# 获取地块类型数组
	var player_tiles := player_config.get_player_tiles() if player_config else []
	var enemy_tiles := enemy_config.get_enemy_tiles() if enemy_config else []

	# 创建敌方区域地块（0 到 enemy_rows-1 行）
	for y in range(enemy_rows):
		for x in range(grid_cols):
			var index := y * grid_cols + x
			var tile_type := TileConstants.TileType.GRASSLAND
			if index < enemy_tiles.size():
				tile_type = enemy_tiles[index]
			_create_tile_at(Vector2i(x, y), tile_type)

	# 创建中线地块（随机生成）
	var middle_types := _generate_middle_row()
	for x in range(grid_cols):
		var tile_type := middle_types[x] if x < middle_types.size() else TileConstants.TileType.GRASSLAND
		_create_tile_at(Vector2i(x, middle_row), tile_type)

	# 创建玩家区域地块（middle_row+1 到 grid_rows-1 行）
	for y in range(middle_row + 1, grid_rows):
		for x in range(grid_cols):
			var local_y := y - (middle_row + 1)
			var index := local_y * grid_cols + x
			var tile_type := TileConstants.TileType.GRASSLAND
			if index < player_tiles.size():
				tile_type = player_tiles[index]
			_create_tile_at(Vector2i(x, y), tile_type)

	_initialized = true
	grid_created.emit()


## 创建单个地块
func _create_tile_at(grid_pos: Vector2i, tile_type: TileConstants.TileType) -> BattleTile:
	var tile: BattleTile = BATTLE_TILE_SCENE.instantiate()
	add_child(tile)

	# 设置位置
	tile.position = grid_to_world(grid_pos)
	tile.grid_position = grid_pos

	# 设置数据
	var data := tileDatabase.get_tile_data(tile_type)
	tile.set_data(data)

	# 存储到网格
	_grid[grid_pos.y][grid_pos.x] = tile

	return tile


## 清空网格
func clear_grid() -> void:
	for row in _grid:
		for tile in row:
			if tile:
				tile.queue_free()

	_grid.clear()
	_initialized = false
	grid_cleared.emit()


# ============ 坐标转换 ============

## 网格坐标转世界坐标（返回地块中心点）
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var cell_size := tile_size + Vector2(tile_spacing, tile_spacing)
	return Vector2(
		grid_pos.x * cell_size.x + tile_size.x / 2,
		grid_pos.y * cell_size.y + tile_size.y / 2
	)


## 世界坐标转网格坐标
func world_to_grid(world_pos: Vector2) -> Vector2i:
	var cell_size := tile_size + Vector2(tile_spacing, tile_spacing)
	@warning_ignore("narrowing_conversion")
	var x: int = int(world_pos.x / cell_size.x)
	@warning_ignore("narrowing_conversion")
	var y: int = int(world_pos.y / cell_size.y)

	# 限制在有效范围内
	x = clampi(x, 0, grid_cols - 1)
	y = clampi(y, 0, grid_rows - 1)

	return Vector2i(x, y)


# ============ 地块查询 ============

## 获取指定位置的地块
func get_tile_at(grid_pos: Vector2i) -> BattleTile:
	if not _is_valid_position(grid_pos):
		return null

	return _grid[grid_pos.y][grid_pos.x]


## 获取所有地块
func get_all_tiles() -> Array[BattleTile]:
	var tiles: Array[BattleTile] = []
	for row in _grid:
		for tile in row:
			if tile:
				tiles.append(tile)
	return tiles


## 检查位置是否有效
func _is_valid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < grid_cols and \
		grid_pos.y >= 0 and grid_pos.y < grid_rows


# ============ 区域判断 ============

## 判断是否为敌方区域
func is_enemy_zone(grid_pos: Vector2i) -> bool:
	return grid_pos.y < enemy_rows


## 判断是否为玩家区域
func is_player_zone(grid_pos: Vector2i) -> bool:
	return grid_pos.y > middle_row


## 判断是否为中线
func is_middle_row(grid_pos: Vector2i) -> bool:
	return grid_pos.y == middle_row


# ============ 虚空设置 ============

## 设置地块虚空状态
func set_tile_void(grid_pos: Vector2i, void_state: bool = true) -> void:
	var tile := get_tile_at(grid_pos)
	if tile:
		tile.set_void(void_state)


## 批量设置虚空
func set_tiles_void(positions: Array[Vector2i], void_state: bool = true) -> void:
	for pos in positions:
		set_tile_void(pos, void_state)


# ============ 邻居查询 ============

## 获取邻居地块
func get_neighbors(grid_pos: Vector2i, include_diagonals: bool = false) -> Array[BattleTile]:
	var neighbors: Array[BattleTile] = []

	# 四方向
	var directions: Array[Vector2i] = [
		Vector2i(0, -1),  # 上
		Vector2i(1, 0),   # 右
		Vector2i(0, 1),   # 下
		Vector2i(-1, 0),  # 左
	]

	# 八方向（添加对角线）
	if include_diagonals:
		directions.append_array([
			Vector2i(1, -1),   # 右上
			Vector2i(1, 1),    # 右下
			Vector2i(-1, 1),   # 左下
			Vector2i(-1, -1),  # 左上
		])

	for dir in directions:
		var neighbor_pos: Vector2i = grid_pos + dir
		var tile := get_tile_at(neighbor_pos)
		if tile:
			neighbors.append(tile)

	return neighbors


## 获取可通行的邻居
func get_passable_neighbors(grid_pos: Vector2i, include_diagonals: bool = false) -> Array[BattleTile]:
	var all_neighbors := get_neighbors(grid_pos, include_diagonals)
	var passable: Array[BattleTile] = []

	for tile in all_neighbors:
		if tile.is_passable and not tile.is_occupied():
			passable.append(tile)

	return passable


# ============ 地图尺寸 ============

## 获取地图像素尺寸
func get_map_size() -> Vector2:
	return Vector2(
		grid_cols * tile_size.x + (grid_cols - 1) * tile_spacing,
		grid_rows * tile_size.y + (grid_rows - 1) * tile_spacing
	)


## 获取地图中心点
func get_map_center() -> Vector2:
	return get_map_size() / 2


# ============ 中立区生成 ============

## 生成中线随机地块类型
func _generate_middle_row() -> Array[TileConstants.TileType]:
	var types: Array[TileConstants.TileType] = []
	var all_types := TileConstants.get_all_tile_types()

	for i in range(grid_cols):
		var random_index := randi() % all_types.size()
		types.append(all_types[random_index])

	return types


# ============ 入场动画 ============

## 播放入场动画序列（水波纹从中心向外扩散）
func play_spawn_sequence() -> void:
	var center := Vector2(grid_cols / 2.0, grid_rows / 2.0)
	var max_distance: float = 0.0

	# 计算最大距离
	for y in range(grid_rows):
		for x in range(grid_cols):
			var dist := Vector2(x, y).distance_to(center)
			max_distance = maxf(max_distance, dist)

	# 从中心向外播放动画
	for y in range(grid_rows):
		for x in range(grid_cols):
			var tile := get_tile_at(Vector2i(x, y))
			if tile:
				var dist := Vector2(x, y).distance_to(center)
				var delay := dist * spawn_ripple_delay
				tile.play_spawn_animation(delay)

	# 发射完成信号
	var total_delay := max_distance * spawn_ripple_delay + 0.5
	await get_tree().create_timer(total_delay).timeout
	spawn_sequence_completed.emit()
