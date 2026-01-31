# 观察者模式（信号）

## 信号即观察者

Godot 的信号系统是观察者模式的原生实现。

## 基础模式

### 发布者（Subject）

```gdscript
class_name Player
extends CharacterBody2D

# 定义信号（事件）
signal health_changed(current: int, maximum: int)
signal died
signal score_changed(new_score: int)
signal item_collected(item: Item)

var health: int = 100:
    set(value):
        var old_health := health
        health = clamp(value, 0, max_health)
        if health != old_health:
            health_changed.emit(health, max_health)
        if health <= 0 and old_health > 0:
            died.emit()

func collect_item(item: Item) -> void:
    item_collected.emit(item)
```

### 订阅者（Observer）

```gdscript
class_name HealthBar
extends ProgressBar

func _ready() -> void:
    # 订阅玩家的信号
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.health_changed.connect(_on_health_changed)
        player.died.connect(_on_player_died)

func _on_health_changed(current: int, maximum: int) -> void:
    max_value = maximum
    value = current

func _on_player_died() -> void:
    visible = false
```

## 事件总线模式

集中管理全局事件：

```gdscript
# autoloads/event_bus.gd
extends Node

# 游戏事件
signal game_started
signal game_paused
signal game_resumed
signal game_over

# 玩家事件
signal player_spawned(player: Node2D)
signal player_died
signal player_respawned

# 战斗事件
signal enemy_killed(enemy: Node2D, killer: Node2D)
signal damage_dealt(target: Node2D, amount: int, source: Node2D)
signal boss_defeated(boss: Node2D)

# 进度事件
signal level_completed(level_id: int)
signal checkpoint_reached(checkpoint_id: int)
signal achievement_unlocked(achievement_id: String)

# UI 事件
signal show_notification(message: String)
signal show_dialog(dialog_data: DialogData)
signal screen_shake(intensity: float)
```

### 使用事件总线

```gdscript
# 发布事件
func kill_enemy() -> void:
    EventBus.enemy_killed.emit(self, killer)

# 订阅事件
func _ready() -> void:
    EventBus.enemy_killed.connect(_on_enemy_killed)
    EventBus.game_over.connect(_on_game_over)

func _on_enemy_killed(enemy: Node2D, killer: Node2D) -> void:
    if killer == player:
        score += enemy.score_value

func _exit_tree() -> void:
    # 可选：断开连接
    EventBus.enemy_killed.disconnect(_on_enemy_killed)
```

## 类型安全的事件

```gdscript
# 使用 Resource 传递复杂数据
class_name DamageEvent
extends Resource

var amount: int
var damage_type: DamageType
var source: Node2D
var target: Node2D
var is_critical: bool

enum DamageType { PHYSICAL, MAGICAL, TRUE }

# 信号
signal damage_event(event: DamageEvent)

# 发送
func deal_damage(target: Node2D, amount: int) -> void:
    var event := DamageEvent.new()
    event.amount = amount
    event.source = self
    event.target = target
    event.damage_type = DamageType.PHYSICAL
    damage_event.emit(event)
```

## 一次性连接

```gdscript
# 只触发一次
animation_player.animation_finished.connect(
    _on_death_finished,
    CONNECT_ONE_SHOT
)

# 或使用 await
await animation_player.animation_finished
queue_free()
```

## 延迟连接

```gdscript
# 延迟到下一帧处理
signal_name.connect(handler, CONNECT_DEFERRED)
```

## 断开模式

```gdscript
# 显式断开
func _exit_tree() -> void:
    if EventBus.enemy_killed.is_connected(_on_enemy_killed):
        EventBus.enemy_killed.disconnect(_on_enemy_killed)

# 使用 Callable 存储
var _enemy_killed_callback: Callable

func _ready() -> void:
    _enemy_killed_callback = _on_enemy_killed
    EventBus.enemy_killed.connect(_enemy_killed_callback)

func _exit_tree() -> void:
    EventBus.enemy_killed.disconnect(_enemy_killed_callback)
```

## 优势

1. **解耦** - 发布者不需要知道订阅者
2. **灵活** - 可以动态添加/移除订阅者
3. **原生支持** - Godot 内建，无需额外实现
4. **编辑器集成** - 可在编辑器中连接信号

## 注意事项

```gdscript
# ⚠️ 避免在已删除的对象上调用
# 使用 is_instance_valid 检查
func _on_enemy_killed(enemy: Node2D) -> void:
    if is_instance_valid(enemy):
        spawn_particles(enemy.global_position)

# ⚠️ 内存泄漏 - 确保断开不再需要的连接
# 特别是当订阅者比发布者先销毁时

# ⚠️ 避免信号循环
# A → B → A 可能导致无限循环
```
