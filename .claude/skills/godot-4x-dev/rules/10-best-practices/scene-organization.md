# 场景组织

## 场景分层

### 推荐项目结构

```
project/
├── scenes/
│   ├── levels/          # 游戏关卡
│   │   ├── level_01.tscn
│   │   └── level_02.tscn
│   ├── menus/           # 菜单场景
│   │   ├── main_menu.tscn
│   │   ├── pause_menu.tscn
│   │   └── settings.tscn
│   └── ui/              # UI 预制件
│       ├── hud.tscn
│       └── dialog_box.tscn
│
├── src/
│   ├── characters/
│   │   ├── player/
│   │   │   ├── player.tscn
│   │   │   └── player.gd
│   │   └── enemies/
│   │       ├── slime/
│   │       └── skeleton/
│   ├── objects/
│   │   ├── items/
│   │   └── interactables/
│   └── systems/
│       ├── autoloads/
│       └── components/
```

## 场景树最佳实践

### 根节点选择

| 场景类型 | 推荐根节点 |
|---------|-----------|
| 角色 | CharacterBody2D/3D |
| 关卡 | Node2D/Node3D |
| UI | Control/CanvasLayer |
| 可拾取物 | Area2D/3D |
| 静态物体 | StaticBody2D/3D |

### 节点命名

```
Player (CharacterBody2D)      # PascalCase
├── Sprite2D                   # 保持类型名
├── CollisionShape2D
├── AnimationPlayer
├── StateMachine              # 功能命名
│   ├── Idle
│   ├── Run
│   └── Jump
└── Components                # 组件容器
    ├── HealthComponent
    └── MovementComponent
```

## 分层组织

### 关卡场景结构

```
Level (Node2D)
├── Environment               # 环境层
│   ├── Background           # 背景
│   │   └── ParallaxBackground
│   ├── Terrain              # 地形
│   │   └── TileMapLayer
│   └── Foreground           # 前景装饰
│
├── Entities                  # 实体层
│   ├── Player
│   ├── Enemies
│   │   ├── Enemy1
│   │   └── Enemy2
│   └── NPCs
│
├── Objects                   # 物件层
│   ├── Pickups
│   ├── Interactables
│   └── Hazards
│
├── Triggers                  # 触发器层
│   ├── CameraZone
│   ├── SpawnTrigger
│   └── EventTrigger
│
└── UI                        # UI 层
    └── CanvasLayer
        └── HUD
```

### Z-Index 管理

```gdscript
# 2D 场景的 Z-Index 约定
const Z_BACKGROUND := -10
const Z_TERRAIN := 0
const Z_OBJECTS := 10
const Z_ENTITIES := 20
const Z_PLAYER := 25
const Z_FOREGROUND := 30
const Z_PARTICLES := 40
const Z_UI := 100
```

## 场景继承

```gdscript
# 基础敌人场景
# enemy_base.tscn
extends CharacterBody2D

@export var max_health: int = 100
@export var move_speed: float = 50.0
@export var damage: int = 10

func take_damage(amount: int) -> void:
    pass

func die() -> void:
    queue_free()

# 继承场景
# slime.tscn (继承自 enemy_base.tscn)
# 只覆盖需要修改的部分
```

## 可复用场景

```gdscript
# 创建可配置的预制件
# pickup.tscn
extends Area2D

@export var item_data: ItemData
@export var float_amplitude: float = 5.0
@export var float_speed: float = 2.0

func _process(delta: float) -> void:
    position.y += sin(Time.get_ticks_msec() * 0.001 * float_speed) * float_amplitude * delta
```

## 场景实例化

```gdscript
# 预加载（编译时）
const EnemyScene := preload("res://src/characters/enemies/enemy.tscn")

# 实例化并添加
func spawn_enemy(pos: Vector2) -> void:
    var enemy := EnemyScene.instantiate()
    enemy.position = pos
    $Entities/Enemies.add_child(enemy)

# 延迟添加（避免在遍历时修改）
func spawn_enemies(positions: Array[Vector2]) -> void:
    for pos in positions:
        var enemy := EnemyScene.instantiate()
        enemy.position = pos
        $Entities/Enemies.call_deferred("add_child", enemy)
```

## 场景切换

```gdscript
# 简单切换
get_tree().change_scene_to_file("res://scenes/levels/level_02.tscn")

# 带加载的切换
func change_level(path: String) -> void:
    var loader := ResourceLoader.load_threaded_request(path)
    # 显示加载画面...
    while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        await get_tree().process_frame

    var scene := ResourceLoader.load_threaded_get(path)
    get_tree().change_scene_to_packed(scene)
```

## 节点组

```gdscript
# 使用组管理节点
func _ready() -> void:
    add_to_group("enemies")
    add_to_group("damageable")

# 批量操作
func kill_all_enemies() -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.die()

# 广播调用
get_tree().call_group("enemies", "alert", player_position)
```
