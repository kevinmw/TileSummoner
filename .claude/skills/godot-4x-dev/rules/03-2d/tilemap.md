# TileMap 系统

## Godot 4.x TileMap 结构

Godot 4.x 使用 TileMapLayer（取代旧版 TileMap）：

```
World (Node2D)
├── BackgroundLayer (TileMapLayer)
├── TerrainLayer (TileMapLayer)
├── ForegroundLayer (TileMapLayer)
└── Player (CharacterBody2D)
```

## TileSet 配置

在编辑器中设置 TileSet：
1. 创建 TileMapLayer 节点
2. 在 Inspector 中创建新 TileSet
3. 添加纹理源（TileSetAtlasSource）
4. 配置物理层、导航层等

## 物理碰撞配置

```
TileSet 配置:
├── Physics Layers
│   └── Layer 0: 地形碰撞
├── Navigation Layers
│   └── Layer 0: 导航网格
└── Custom Data Layers
    └── tile_type: String
```

## 代码访问 TileMap

```gdscript
@onready var tilemap: TileMapLayer = $TerrainLayer

func _ready() -> void:
    # 获取图块信息
    var cell_pos := Vector2i(5, 3)
    var source_id := tilemap.get_cell_source_id(cell_pos)
    var atlas_coords := tilemap.get_cell_atlas_coords(cell_pos)

    # 设置图块
    tilemap.set_cell(cell_pos, source_id, atlas_coords)

    # 清除图块
    tilemap.erase_cell(cell_pos)
```

## 坐标转换

```gdscript
# 世界坐标 → 图块坐标
func world_to_tile(world_pos: Vector2) -> Vector2i:
    return tilemap.local_to_map(world_pos)

# 图块坐标 → 世界坐标（图块中心）
func tile_to_world(tile_pos: Vector2i) -> Vector2:
    return tilemap.map_to_local(tile_pos)

# 获取图块大小
var tile_size: Vector2i = tilemap.tile_set.tile_size

# 获取鼠标所在图块
func get_mouse_tile() -> Vector2i:
    var mouse_pos := get_global_mouse_position()
    return tilemap.local_to_map(tilemap.to_local(mouse_pos))
```

## 获取图块数据

```gdscript
# 获取所有已使用的图块
var used_cells: Array[Vector2i] = tilemap.get_used_cells()

# 获取特定源的图块
var cells_by_source: Array[Vector2i] = tilemap.get_used_cells_by_id(source_id)

# 获取自定义数据
func get_tile_custom_data(cell: Vector2i, data_name: String) -> Variant:
    var data := tilemap.get_cell_tile_data(cell)
    if data:
        return data.get_custom_data(data_name)
    return null
```

## 程序化生成

```gdscript
func generate_terrain(width: int, height: int) -> void:
    var noise := FastNoiseLite.new()
    noise.seed = randi()
    noise.frequency = 0.1

    for x in range(width):
        var ground_height := int((noise.get_noise_1d(x) + 1) * 5) + 10

        for y in range(height):
            if y > ground_height:
                # 地下
                tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))
            elif y == ground_height:
                # 地表
                tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
```

## 自动图块（Terrain）

```gdscript
# 使用地形系统自动连接图块
func set_terrain_cell(pos: Vector2i, terrain_set: int, terrain: int) -> void:
    tilemap.set_cells_terrain_connect([pos], terrain_set, terrain)

# 批量设置（更高效）
func fill_terrain(cells: Array[Vector2i], terrain_set: int, terrain: int) -> void:
    tilemap.set_cells_terrain_connect(cells, terrain_set, terrain)
```

## 常见模式

### 可破坏图块

```gdscript
signal tile_destroyed(pos: Vector2i)

func destroy_tile(world_pos: Vector2) -> void:
    var cell := world_to_tile(world_pos)
    if tilemap.get_cell_source_id(cell) != -1:
        tilemap.erase_cell(cell)
        spawn_debris(tile_to_world(cell))
        tile_destroyed.emit(cell)
```

### 图块交互检测

```gdscript
func get_tile_at_position(pos: Vector2) -> Dictionary:
    var cell := world_to_tile(pos)
    return {
        "position": cell,
        "source_id": tilemap.get_cell_source_id(cell),
        "is_solid": tilemap.get_cell_source_id(cell) != -1
    }
```
