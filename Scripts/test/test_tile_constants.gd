class_name TestTileConstants
extends GdUnitTestSuite

## TileConstants 测试套件
## 测试范围：
## 1. 背景图片路径映射


# ============ 背景图片路径映射测试 ============

## 测试1：获取 GRASSLAND 背景路径
func test_get_bg_texture_path_grassland() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.GRASSLAND)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Grassland_BG.png")


## 测试2：获取 WATER 背景路径
func test_get_bg_texture_path_water() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.WATER)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Water_BG.png")


## 测试3：获取 SAND 背景路径（特殊映射到 Desert）
func test_get_bg_texture_path_sand_maps_to_desert() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.SAND)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Desert_BG.png")


## 测试4：获取 ROCK 背景路径
func test_get_bg_texture_path_rock() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.ROCK)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Rock_BG.png")


## 测试5：获取 FOREST 背景路径
func test_get_bg_texture_path_forest() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.FOREST)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Forest_BG.png")


## 测试6：获取 FARMLAND 背景路径
func test_get_bg_texture_path_farmland() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.FARMLAND)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Farmland_BG.png")


## 测试7：获取 LAVA 背景路径
func test_get_bg_texture_path_lava() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.LAVA)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Lava_BG.png")


## 测试8：获取 SWAMP 背景路径
func test_get_bg_texture_path_swamp() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.SWAMP)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Swamp_BG.png")


## 测试9：获取 ICE 背景路径
func test_get_bg_texture_path_ice() -> void:
	var path := TileConstants.get_tile_bg_texture_path(TileConstants.TileType.ICE)

	assert_that(path).is_equal("res://Assets/Sprites/Tiles/Tile_Ice_BG.png")


## 测试10：所有地形类型都有对应路径
func test_all_tile_types_have_bg_path() -> void:
	var all_types := TileConstants.get_all_tile_types()

	for tile_type in all_types:
		var path := TileConstants.get_tile_bg_texture_path(tile_type)
		assert_that(path).is_not_empty()
		assert_that(path).starts_with("res://Assets/Sprites/Tiles/Tile_")
		assert_that(path).ends_with("_BG.png")
