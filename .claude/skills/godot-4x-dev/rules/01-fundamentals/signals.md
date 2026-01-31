# 信号系统

## 核心概念

信号是 Godot 的观察者模式实现，用于节点间解耦通信。

## 定义信号

```gdscript
# 无参数信号
signal died
signal game_started

# 带参数信号（必须声明类型）
signal health_changed(new_health: int)
signal item_collected(item: Item, amount: int)
signal position_updated(new_position: Vector2)
```

## 发射信号

```gdscript
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)  # 发射信号

    if health <= 0:
        died.emit()

func collect_item(item: Item, count: int = 1) -> void:
    item_collected.emit(item, count)
```

## 连接信号

### 代码连接（推荐）

```gdscript
func _ready() -> void:
    # 连接到方法
    health_changed.connect(_on_health_changed)

    # 连接其他节点的信号
    $Button.pressed.connect(_on_button_pressed)

    # 带参数绑定
    $Enemy.died.connect(_on_enemy_died.bind(enemy_id))

func _on_health_changed(new_health: int) -> void:
    health_bar.value = new_health

func _on_button_pressed() -> void:
    start_game()

func _on_enemy_died(id: int) -> void:
    score += 100
```

### 一次性连接

```gdscript
# 信号触发一次后自动断开
animation_player.animation_finished.connect(
    _on_death_animation_finished,
    CONNECT_ONE_SHOT
)
```

### Lambda 连接（简单逻辑）

```gdscript
$Button.pressed.connect(func(): visible = false)

timer.timeout.connect(func():
    spawn_enemy()
    timer.start()
)
```

## 断开信号

```gdscript
# 断开特定连接
health_changed.disconnect(_on_health_changed)

# 检查是否已连接
if health_changed.is_connected(_on_health_changed):
    health_changed.disconnect(_on_health_changed)
```

## 内置信号

```gdscript
# 节点
$Node.ready.connect(...)
$Node.tree_entered.connect(...)
$Node.tree_exited.connect(...)

# Area2D
$Area2D.body_entered.connect(_on_body_entered)
$Area2D.area_entered.connect(_on_area_entered)

# Button
$Button.pressed.connect(...)
$Button.toggled.connect(...)

# AnimationPlayer
$AnimationPlayer.animation_finished.connect(...)
```

## 信号最佳实践

```gdscript
# ✅ 使用信号解耦
# Player.gd
signal coin_collected(value: int)

func collect_coin(coin: Coin) -> void:
    coin_collected.emit(coin.value)

# GameManager.gd
func _ready() -> void:
    player.coin_collected.connect(_on_coin_collected)

# ❌ 避免直接引用
# Player.gd - 紧耦合
func collect_coin(coin: Coin) -> void:
    GameManager.add_coins(coin.value)  # 直接调用 = 紧耦合
```

## 自定义信号传递复杂数据

```gdscript
# 使用 Resource 或 Dictionary
signal damage_received(damage_info: DamageInfo)

class DamageInfo:
    var amount: int
    var type: DamageType
    var source: Node2D
```
