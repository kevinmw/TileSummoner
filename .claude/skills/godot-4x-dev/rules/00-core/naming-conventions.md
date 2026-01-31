# Godot 4.x 命名规范

## GDScript 命名

### 变量和函数: snake_case
```gdscript
var player_health: int = 100
var max_speed: float = 200.0

func calculate_damage(base_damage: int) -> int:
    return base_damage * damage_multiplier
```

### 类名和节点: PascalCase
```gdscript
class_name PlayerController
class_name EnemySpawner

# 节点引用保持 PascalCase
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
```

### 常量: SCREAMING_SNAKE_CASE
```gdscript
const MAX_HEALTH: int = 100
const GRAVITY: float = 980.0
const DEFAULT_SPAWN_POSITION: Vector2 = Vector2(100, 200)
```

### 枚举
```gdscript
# 枚举类型: PascalCase
# 枚举值: SCREAMING_SNAKE_CASE
enum PlayerState {
    IDLE,
    RUNNING,
    JUMPING,
    FALLING
}

enum DamageType {
    PHYSICAL,
    MAGICAL,
    TRUE_DAMAGE
}
```

### 信号: past_tense 或 描述性
```gdscript
signal health_changed(new_health: int)
signal player_died
signal item_collected(item: Item)
signal level_completed(level_id: int, score: int)
```

### 私有成员: 下划线前缀
```gdscript
var _internal_counter: int = 0
var _cached_position: Vector2

func _calculate_internal_value() -> float:
    return _internal_counter * 0.5
```

## 文件命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 脚本 | snake_case.gd | `player_controller.gd` |
| 场景 | snake_case.tscn | `main_menu.tscn` |
| 资源 | snake_case.tres | `enemy_stats.tres` |
| 着色器 | snake_case.gdshader | `water_effect.gdshader` |

## 节点命名

场景树中的节点使用 **PascalCase**：
```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer
└── Hitbox (Area2D)
    └── CollisionShape2D
```

## 资源路径

```gdscript
# 使用 res:// 和 snake_case 路径
@export player_scene = preload("res://src/characters/player/player.tscn")
@export enemy_data = preload("res://resources/data/enemy_stats.tres")
```
