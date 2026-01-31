# Resource 资源管理

## 什么是 Resource

Resource 是 Godot 的数据容器，可序列化保存为 `.tres` 文件，用于存储游戏数据、配置、统计等。

## 创建自定义 Resource

```gdscript
# res://resources/character_stats.gd
class_name CharacterStats
extends Resource

@export var max_health: int = 100
@export var attack_power: int = 10
@export var defense: int = 5
@export var move_speed: float = 200.0

@export_group("Experience")
@export var level: int = 1
@export var experience: int = 0
@export var experience_to_next: int = 100
```

## 在编辑器中创建 Resource

1. 右键 FileSystem → New Resource
2. 选择你的 Resource 类型（如 CharacterStats）
3. 保存为 `.tres` 文件

## 使用 Resource

```gdscript
# 预加载（编译时）
const PLAYER_STATS = preload("res://resources/data/player_stats.tres")

# 运行时加载
var enemy_stats: CharacterStats = load("res://resources/data/enemy_stats.tres")

# 作为 @export 变量
@export var stats: CharacterStats

func _ready() -> void:
    health = stats.max_health
    speed = stats.move_speed
```

## Resource 的共享特性

**重要**: Resource 默认是共享引用！

```gdscript
# ❌ 共享问题 - 所有敌人共用同一个 stats
@export var stats: EnemyStats

func take_damage(amount: int) -> void:
    stats.health -= amount  # 所有敌人都会扣血！

# ✅ 解决方案 - 复制 Resource
func _ready() -> void:
    stats = stats.duplicate()  # 创建独立副本
```

## 常用 Resource 模式

### 游戏配置

```gdscript
# game_config.gd
class_name GameConfig
extends Resource

@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 1.0
@export var difficulty: int = 1
```

### 物品数据

```gdscript
# item_data.gd
class_name ItemData
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var stack_size: int = 99
@export var item_type: ItemType

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }
```

### 技能数据

```gdscript
# skill_data.gd
class_name SkillData
extends Resource

@export var skill_name: String
@export var damage: int
@export var mana_cost: int
@export var cooldown: float
@export var icon: Texture2D
@export var effect_scene: PackedScene
```

## Resource 方法

```gdscript
class_name CharacterStats
extends Resource

@export var base_attack: int = 10
@export var level: int = 1

# Resource 可以有方法
func get_total_attack() -> int:
    return base_attack + (level * 2)

func level_up() -> void:
    level += 1
    resource_changed.emit()  # 通知变化
```

## 保存 Resource

```gdscript
# 保存到文件
var save_result = ResourceSaver.save(stats, "user://saves/player_stats.tres")

# 加载用户数据
var loaded_stats = ResourceLoader.load("user://saves/player_stats.tres")
```
