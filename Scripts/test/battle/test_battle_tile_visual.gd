class_name TestBattleTileVisual
extends GdUnitTestSuite

## BattleTileVisual 测试套件
## 测试范围：
## 1. 背景图片加载
## 2. 图标缩放
## 3. hover 亮度


# ============ 辅助方法 ============

## 创建测试用 BattleTileVisual 实例
func _create_visual() -> BattleTileVisual:
	var visual := BattleTileVisual.new()

	# 添加必要的子节点
	var bg := Sprite2D.new()
	bg.name = "Background"
	visual.add_child(bg)

	var icon := Sprite2D.new()
	icon.name = "Icon"
	visual.add_child(icon)

	var border := Line2D.new()
	border.name = "Border"
	visual.add_child(border)

	add_child(visual)
	auto_free(visual)
	return visual


# ============ 背景图片加载测试 ============

## 测试1：set_background_from_tile_type 方法存在
func test_has_set_background_from_tile_type_method() -> void:
	var visual := _create_visual()

	assert_that(visual.has_method("set_background_from_tile_type")).is_true()


## 测试2：设置 GRASSLAND 背景后 Background 节点有纹理
func test_set_background_grassland_loads_texture() -> void:
	var visual := _create_visual()
	await get_tree().process_frame

	visual.set_background_from_tile_type(TileConstants.TileType.GRASSLAND)

	var bg: Sprite2D = visual.get_node("Background")
	assert_that(bg.texture).is_not_null()


## 测试3：设置 SWAMP 背景加载正确纹理
func test_set_background_swamp_loads_correct_texture() -> void:
	var visual := _create_visual()
	await get_tree().process_frame

	visual.set_background_from_tile_type(TileConstants.TileType.SWAMP)

	var bg: Sprite2D = visual.get_node("Background")
	assert_that(bg.texture).is_not_null()
	# 验证是正确的纹理（通过资源路径）
	if bg.texture:
		assert_that(bg.texture.resource_path).contains("Swamp")


## 测试4：设置 SAND 背景加载 Desert 纹理
func test_set_background_sand_loads_desert_texture() -> void:
	var visual := _create_visual()
	await get_tree().process_frame

	visual.set_background_from_tile_type(TileConstants.TileType.SAND)

	var bg: Sprite2D = visual.get_node("Background")
	assert_that(bg.texture).is_not_null()
	if bg.texture:
		assert_that(bg.texture.resource_path).contains("Desert")
