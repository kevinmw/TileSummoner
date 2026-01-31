# Area 区域检测

## Area2D 基础

```gdscript
extends Area2D

func _ready() -> void:
    # 连接信号
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        print("Player entered!")

func _on_body_exited(body: Node2D) -> void:
    pass

func _on_area_entered(area: Area2D) -> void:
    pass

func _on_area_exited(area: Area2D) -> void:
    pass
```

## 信号类型

| 信号 | 检测对象 |
|------|---------|
| body_entered | CharacterBody, RigidBody, StaticBody |
| body_exited | 同上离开时 |
| area_entered | 其他 Area |
| area_exited | 其他 Area 离开时 |

## 监控设置

```gdscript
extends Area2D

func _ready() -> void:
    # 监控选项
    monitoring = true           # 是否检测其他物体
    monitorable = true          # 是否被其他 Area 检测

    # 碰撞层
    collision_layer = 1 << 6    # Trigger 层
    collision_mask = 1 << 0     # 检测 Player 层
```

## 常见用途

### 伤害区域

```gdscript
extends Area2D
class_name DamageZone

@export var damage_per_second: int = 10
var bodies_in_zone: Array[Node2D] = []

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
    for body in bodies_in_zone:
        if body.has_method("take_damage"):
            body.take_damage(int(damage_per_second * delta))

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("damageable"):
        bodies_in_zone.append(body)

func _on_body_exited(body: Node2D) -> void:
    bodies_in_zone.erase(body)
```

### 拾取物

```gdscript
extends Area2D
class_name Pickup

signal collected(item: Pickup)

@export var item_data: ItemData

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        collect(body)

func collect(collector: Node2D) -> void:
    collected.emit(self)
    if collector.has_method("add_item"):
        collector.add_item(item_data)
    queue_free()
```

### 触发区域

```gdscript
extends Area2D
class_name Trigger

signal triggered
signal player_entered
signal player_exited

@export var one_shot: bool = true
var has_triggered: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        if one_shot and has_triggered:
            return
        has_triggered = true
        player_entered.emit()
        triggered.emit()

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        player_exited.emit()
```

### 检测范围

```gdscript
extends Area2D
class_name DetectionZone

signal target_entered(target: Node2D)
signal target_exited(target: Node2D)

var targets: Array[Node2D] = []

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func get_nearest_target() -> Node2D:
    var nearest: Node2D = null
    var nearest_dist := INF

    for target in targets:
        if not is_instance_valid(target):
            continue
        var dist := global_position.distance_to(target.global_position)
        if dist < nearest_dist:
            nearest_dist = dist
            nearest = target

    return nearest

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("enemies"):
        targets.append(body)
        target_entered.emit(body)

func _on_body_exited(body: Node2D) -> void:
    targets.erase(body)
    target_exited.emit(body)
```

## 查询区域内物体

```gdscript
# 获取当前重叠的所有物体
func get_overlapping() -> void:
    var bodies := get_overlapping_bodies()
    var areas := get_overlapping_areas()

    for body in bodies:
        print("Overlapping body: ", body.name)

# 检查是否重叠
func is_player_inside() -> bool:
    for body in get_overlapping_bodies():
        if body.is_in_group("player"):
            return true
    return false
```

## Area3D

```gdscript
extends Area3D

@export var gravity_strength: float = 10.0
@export var gravity_direction: Vector3 = Vector3.DOWN

func _ready() -> void:
    # 自定义重力区域
    gravity_space_override = Area3D.SPACE_OVERRIDE_REPLACE
    gravity = gravity_strength
    gravity_direction = gravity_direction

    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    if body is RigidBody3D:
        print("RigidBody entered gravity zone")
```

## 重叠检测设置

```gdscript
# 精确检测
priority = 1  # 优先级（重叠时使用）

# 2D 特有
gravity_space_override = SPACE_OVERRIDE_DISABLED
gravity_point = false
gravity_direction = Vector2.DOWN
gravity = 980.0
linear_damp_space_override = SPACE_OVERRIDE_DISABLED
angular_damp_space_override = SPACE_OVERRIDE_DISABLED
```
