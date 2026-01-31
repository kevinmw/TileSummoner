# 碰撞层级管理

## 碰撞层系统

Godot 使用两个属性控制碰撞：
- **Layer (层)**: 物体所在的层（"我是什么"）
- **Mask (掩码)**: 物体检测的层（"我与什么碰撞"）

## 推荐层级分配

### 2D 项目

```
Layer 1:  Player
Layer 2:  Enemies
Layer 3:  Player Projectiles
Layer 4:  Enemy Projectiles
Layer 5:  Pickups / Items
Layer 6:  Environment / Walls
Layer 7:  Triggers / Areas
Layer 8:  Interactables
Layer 9:  Platforms (单向)
Layer 10: Hazards
```

### 3D 项目

```
Layer 1:  Player
Layer 2:  Enemies
Layer 3:  Player Projectiles
Layer 4:  Enemy Projectiles
Layer 5:  Pickups
Layer 6:  Static Environment
Layer 7:  Dynamic Props
Layer 8:  Triggers
Layer 9:  Navigation Obstacles
Layer 10: Ragdoll
```

## 在项目设置中命名

```
项目 → 项目设置 → Layer Names → 2D Physics (或 3D Physics)
layer_1 = "player"
layer_2 = "enemies"
layer_3 = "player_projectiles"
...
```

## 代码设置

```gdscript
# 设置单个层
collision_layer = 1 << 0  # Layer 1
collision_mask = 1 << 5   # Layer 6

# 多个层使用位或
collision_layer = (1 << 0) | (1 << 2)  # Layers 1 和 3
collision_mask = (1 << 1) | (1 << 5)   # Layers 2 和 6

# 使用函数
set_collision_layer_value(1, true)   # 启用 Layer 1
set_collision_layer_value(2, false)  # 禁用 Layer 2
set_collision_mask_value(6, true)    # 检测 Layer 6
```

## 典型配置示例

### Player

```gdscript
extends CharacterBody2D

func _ready() -> void:
    # 玩家在 Layer 1
    collision_layer = 1 << 0

    # 检测: 环境、敌人子弹、拾取物、危险
    collision_mask = (1 << 5) | (1 << 3) | (1 << 4) | (1 << 9)
```

### Enemy

```gdscript
extends CharacterBody2D

func _ready() -> void:
    # 敌人在 Layer 2
    collision_layer = 1 << 1

    # 检测: 环境、玩家子弹
    collision_mask = (1 << 5) | (1 << 2)
```

### Player Bullet

```gdscript
extends Area2D

func _ready() -> void:
    # 玩家子弹在 Layer 3
    collision_layer = 1 << 2

    # 检测: 敌人、环境
    collision_mask = (1 << 1) | (1 << 5)
```

### Pickup

```gdscript
extends Area2D

func _ready() -> void:
    # 拾取物在 Layer 5
    collision_layer = 1 << 4

    # 被玩家检测，自己不检测任何东西
    collision_mask = 0
```

## 碰撞矩阵

| 物体 | Layer | 检测 (Mask) |
|------|-------|-------------|
| Player | 1 | Environment, Enemy Bullets |
| Enemies | 2 | Environment, Player Bullets |
| Player Bullets | 3 | Enemies, Environment |
| Enemy Bullets | 4 | Player, Environment |
| Pickups | 5 | (none - player detects them) |
| Environment | 6 | (none - others detect it) |

## 运行时切换

```gdscript
# 无敌状态 - 不检测敌人子弹
func set_invincible(enabled: bool) -> void:
    set_collision_mask_value(4, not enabled)

# 隐身状态 - 敌人不检测玩家
func set_invisible(enabled: bool) -> void:
    set_collision_layer_value(1, not enabled)

# 幽灵状态 - 穿墙
func set_ghost_mode(enabled: bool) -> void:
    set_collision_mask_value(6, not enabled)
```

## Area2D/3D 检测层

```gdscript
extends Area2D

func _ready() -> void:
    # Area 的检测层（同样的系统）
    collision_layer = 1 << 6  # Trigger
    collision_mask = 1 << 0   # 只检测玩家

    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    # 由于 mask 设置，只有 Layer 1 的物体会触发
    if body is CharacterBody2D:
        trigger_event()
```

## RayCast 层级

```gdscript
@onready var ray: RayCast2D = $RayCast2D

func _ready() -> void:
    # 射线的检测层
    ray.collision_mask = (1 << 5) | (1 << 1)  # 环境和敌人
    ray.exclude_parent = true  # 排除父节点

# 代码射线
func check_line_of_sight(target: Node2D) -> bool:
    var space := get_world_2d().direct_space_state
    var query := PhysicsRayQueryParameters2D.create(
        global_position,
        target.global_position
    )
    query.collision_mask = 1 << 5  # 只检测环境
    query.exclude = [self]

    var result := space.intersect_ray(query)
    return result.is_empty()  # 没有障碍物 = 可见
```
