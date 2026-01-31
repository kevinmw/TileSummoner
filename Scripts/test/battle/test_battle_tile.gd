class_name TestBattleTile
extends GdUnitTestSuite

## BattleTile 测试套件
## 测试范围：
## 1. 数据设置/获取
## 2. 网格坐标管理
## 3. 碰撞检测
## 4. 虚空状态切换
## 5. 信号发射


# ============ 常量 ============

const TILE_SIZE := Vector2(80, 80)


# ============ 辅助方法 ============

## 创建测试用 BattleTile 实例
func _create_battle_tile() -> BattleTile:
	var tile := BattleTile.new()
	add_child(tile)
	auto_free(tile)
	return tile


## 获取测试用 TileBlockData
func _get_test_tile_data() -> TileBlockData:
	return tileDatabase.get_tile_data(TileConstants.TileType.GRASSLAND)


# ============ 基础属性测试 ============

## 测试1：BattleTile 可以实例化
func test_battle_tile_instantiation() -> void:
	var tile := _create_battle_tile()

	assert_that(tile).is_not_null()
	assert_that(tile).is_instanceof(BattleTile)


## 测试2：默认 tile_size 为 80x80
func test_default_tile_size() -> void:
	var tile := _create_battle_tile()

	assert_that(tile.tile_size).is_equal(TILE_SIZE)


## 测试3：默认 grid_position 为 (0, 0)
func test_default_grid_position() -> void:
	var tile := _create_battle_tile()

	assert_that(tile.grid_position).is_equal(Vector2i.ZERO)


## 测试4：默认虚空状态为 false
func test_default_void_state() -> void:
	var tile := _create_battle_tile()

	assert_that(tile.is_void).is_false()


## 测试5：默认可通行状态为 true
func test_default_passable_state() -> void:
	var tile := _create_battle_tile()

	assert_that(tile.is_passable).is_true()


# ============ 数据管理测试 ============

## 测试6：设置并获取 TileBlockData
func test_set_and_get_data() -> void:
	var tile := _create_battle_tile()
	var data := _get_test_tile_data()

	tile.set_data(data)

	assert_that(tile.get_data()).is_equal(data)


## 测试7：设置 null 数据不会崩溃
func test_set_null_data() -> void:
	var tile := _create_battle_tile()

	tile.set_data(null)

	assert_that(tile.get_data()).is_null()


## 测试8：get_tile_type 返回正确类型
func test_get_tile_type() -> void:
	var tile := _create_battle_tile()
	var data := _get_test_tile_data()

	tile.set_data(data)

	assert_that(tile.get_tile_type()).is_equal(TileConstants.TileType.GRASSLAND)


## 测试9：无数据时 get_tile_type 返回 GRASSLAND（默认）
func test_get_tile_type_without_data() -> void:
	var tile := _create_battle_tile()

	# 无数据时应返回默认值
	var tile_type := tile.get_tile_type()
	assert_that(tile_type).is_equal(TileConstants.TileType.GRASSLAND)


# ============ 网格坐标测试 ============

## 测试10：设置并获取网格坐标
func test_set_and_get_grid_position() -> void:
	var tile := _create_battle_tile()
	var pos := Vector2i(3, 5)

	tile.set_grid_position(pos)

	assert_that(tile.get_grid_position()).is_equal(pos)


## 测试11：grid_position 属性直接访问
func test_grid_position_direct_access() -> void:
	var tile := _create_battle_tile()
	var pos := Vector2i(2, 7)

	tile.grid_position = pos

	assert_that(tile.grid_position).is_equal(pos)


# ============ 虚空状态测试 ============

## 测试12：设置虚空状态为 true
func test_set_void_state_true() -> void:
	var tile := _create_battle_tile()

	tile.set_void(true)

	assert_that(tile.is_void).is_true()


## 测试13：设置虚空状态为 false
func test_set_void_state_false() -> void:
	var tile := _create_battle_tile()
	tile.set_void(true)

	tile.set_void(false)

	assert_that(tile.is_void).is_false()


## 测试14：虚空状态影响可通行性
func test_void_affects_passability() -> void:
	var tile := _create_battle_tile()

	tile.set_void(true)

	assert_that(tile.is_passable).is_false()


## 测试15：解除虚空恢复可通行性
func test_unvoid_restores_passability() -> void:
	var tile := _create_battle_tile()
	tile.set_void(true)

	tile.set_void(false)

	assert_that(tile.is_passable).is_true()


# ============ 信号测试 ============

## 测试16：tile_clicked 信号发射
func test_tile_clicked_signal() -> void:
	var tile := _create_battle_tile()
	var monitor := monitor_signals(tile)

	tile.emit_clicked()
	await await_idle_frame()

	assert_signal(monitor).is_emitted("tile_clicked")


## 测试17：tile_hovered 信号发射
func test_tile_hovered_signal() -> void:
	var tile := _create_battle_tile()
	var monitor := monitor_signals(tile)

	tile.emit_hovered()
	await await_idle_frame()

	assert_signal(monitor).is_emitted("tile_hovered")


## 测试18：tile_unhovered 信号发射
func test_tile_unhovered_signal() -> void:
	var tile := _create_battle_tile()
	var monitor := monitor_signals(tile)

	tile.emit_unhovered()
	await await_idle_frame()

	assert_signal(monitor).is_emitted("tile_unhovered")


## 测试19：void_state_changed 信号发射
func test_void_state_changed_signal() -> void:
	var tile := _create_battle_tile()
	var monitor := monitor_signals(tile)

	tile.set_void(true)
	await await_idle_frame()

	assert_signal(monitor).is_emitted("void_state_changed")


# ============ 单位占用测试 ============

## 测试20：默认无单位占用
func test_default_no_unit_occupying() -> void:
	var tile := _create_battle_tile()

	assert_that(tile.occupying_unit).is_null()
	assert_that(tile.is_occupied()).is_false()


## 测试21：设置占用单位
func test_set_occupying_unit() -> void:
	var tile := _create_battle_tile()
	var mock_unit := Node2D.new()
	add_child(mock_unit)
	auto_free(mock_unit)

	tile.set_occupying_unit(mock_unit)

	assert_that(tile.occupying_unit).is_equal(mock_unit)
	assert_that(tile.is_occupied()).is_true()


## 测试22：清除占用单位
func test_clear_occupying_unit() -> void:
	var tile := _create_battle_tile()
	var mock_unit := Node2D.new()
	add_child(mock_unit)
	auto_free(mock_unit)
	tile.set_occupying_unit(mock_unit)

	tile.clear_occupying_unit()

	assert_that(tile.occupying_unit).is_null()
	assert_that(tile.is_occupied()).is_false()


## 测试23：unit_entered 信号发射
func test_unit_entered_signal() -> void:
	var tile := _create_battle_tile()
	var mock_unit := Node2D.new()
	add_child(mock_unit)
	auto_free(mock_unit)
	var monitor := monitor_signals(tile)

	tile.set_occupying_unit(mock_unit)
	await await_idle_frame()

	assert_signal(monitor).is_emitted("unit_entered")


## 测试24：unit_exited 信号发射
func test_unit_exited_signal() -> void:
	var tile := _create_battle_tile()
	var mock_unit := Node2D.new()
	add_child(mock_unit)
	auto_free(mock_unit)
	tile.set_occupying_unit(mock_unit)
	var monitor := monitor_signals(tile)

	tile.clear_occupying_unit()
	await await_idle_frame()

	assert_signal(monitor).is_emitted("unit_exited")


# ============ 公共接口兼容性测试 ============

## 测试25：实现 Tile 相同的数据接口
func test_implements_tile_data_interface() -> void:
	var tile := _create_battle_tile()

	# 测试所有接口方法存在
	assert_that(tile.has_method("set_data")).is_true()
	assert_that(tile.has_method("get_data")).is_true()
	assert_that(tile.has_method("get_tile_type")).is_true()
	assert_that(tile.has_method("get_grid_position")).is_true()
	assert_that(tile.has_method("set_grid_position")).is_true()


# ============ 视觉效果测试 ============

## 测试26：Visual 子节点存在
func test_visual_node_exists() -> void:
	var tile := _create_battle_tile()

	var visual := tile.get_node_or_null("Visual")
	assert_that(visual).is_not_null()
	assert_that(visual).is_instanceof(BattleTileVisual)


## 测试27：设置数据后应用 hover_color
func test_hover_color_from_data() -> void:
	var tile := _create_battle_tile()
	var data := _get_test_tile_data()

	tile.set_data(data)
	var visual: BattleTileVisual = tile.get_node_or_null("Visual")

	if visual:
		assert_that(visual.hover_color).is_equal(data.hover_color)


## 测试28：hover 状态切换边框颜色
func test_hover_changes_border_color() -> void:
	var tile := _create_battle_tile()
	var data := _get_test_tile_data()
	tile.set_data(data)

	var visual: BattleTileVisual = tile.get_node_or_null("Visual")
	if visual:
		var original_border := visual.border_color
		visual.set_hovered(true)
		# hover 时边框应该变为 hover_color
		assert_that(visual.get_current_border_color()).is_equal(visual.hover_color)


## 测试29：unhover 恢复边框颜色
func test_unhover_restores_border_color() -> void:
	var tile := _create_battle_tile()
	var data := _get_test_tile_data()
	tile.set_data(data)

	var visual: BattleTileVisual = tile.get_node_or_null("Visual")
	if visual:
		var original_border := visual.border_color
		visual.set_hovered(true)
		visual.set_hovered(false)
		# unhover 后边框应恢复原色
		assert_that(visual.get_current_border_color()).is_equal(original_border)


## 测试30：图标从 TileBlockData 加载
func test_icon_loaded_from_data() -> void:
	var tile := _create_battle_tile()
	var data := _get_test_tile_data()
	# 确保有 icon_path
	if data.icon_path.is_empty():
		data.icon_path = "res://Assets/Icons/UI/grass.svg"

	tile.set_data(data)

	var visual: BattleTileVisual = tile.get_node_or_null("Visual")
	if visual:
		# 应该有图标纹理
		assert_that(visual.has_icon_texture()).is_true()


## 测试31：图标透明度为 0.2
func test_icon_opacity() -> void:
	var tile := _create_battle_tile()
	var data := _get_test_tile_data()
	if data.icon_path.is_empty():
		data.icon_path = "res://Assets/Icons/UI/grass.svg"

	tile.set_data(data)

	var visual: BattleTileVisual = tile.get_node_or_null("Visual")
	if visual:
		assert_that(visual.get_icon_opacity()).is_equal_approx(0.2, 0.01)


## 测试32：Shader 材质已应用
func test_shader_material_applied() -> void:
	var tile := _create_battle_tile()

	var visual: BattleTileVisual = tile.get_node_or_null("Visual")
	if visual:
		assert_that(visual.has_inset_shader()).is_true()


## 测试33：Shader 参数可配置
func test_shader_parameters_configurable() -> void:
	var tile := _create_battle_tile()

	var visual: BattleTileVisual = tile.get_node_or_null("Visual")
	if visual:
		visual.set_inset_size(20.0)
		assert_that(visual.get_inset_size()).is_equal_approx(20.0, 0.01)


# ============ 入场动画测试 ============

## 测试34：默认 spawn_duration 为 0.3 秒
func test_default_spawn_duration() -> void:
	var tile := _create_battle_tile()
	assert_that(tile.spawn_duration).is_equal_approx(0.3, 0.01)


## 测试35：默认 spawn_initial_scale 为 0.0
func test_default_spawn_initial_scale() -> void:
	var tile := _create_battle_tile()
	assert_that(tile.spawn_initial_scale).is_equal_approx(0.0, 0.01)


## 测试36：动画开始时 scale 为初始值
func test_spawn_animation_initial_scale() -> void:
	var tile := _create_battle_tile()
	tile.play_spawn_animation(0.0)
	await await_millis(50)
	# 动画刚开始时 scale 应接近初始值
	assert_that(tile.scale.x).is_less(0.5)


## 测试37：动画完成后 scale 为 1
func test_spawn_animation_final_scale() -> void:
	var tile := _create_battle_tile()
	tile.play_spawn_animation(0.0)
	await await_millis(500)
	assert_that(tile.scale).is_equal(Vector2.ONE)


## 测试38：动画完成后 modulate.a 为 1
func test_spawn_animation_final_opacity() -> void:
	var tile := _create_battle_tile()
	tile.play_spawn_animation(0.0)
	await await_millis(500)
	assert_that(tile.modulate.a).is_equal_approx(1.0, 0.01)


## 测试39：动画延迟正确工作
func test_spawn_animation_delay() -> void:
	var tile := _create_battle_tile()
	tile.scale = Vector2.ONE
	tile.play_spawn_animation(0.2)
	await await_millis(50)
	# 延迟期间 scale 应该保持原值（还没开始动画）
	assert_that(tile.scale).is_equal(Vector2.ONE)
