# 组件系统

## 组件模式概述

将功能分解为独立、可复用的组件，通过组合构建游戏对象。

## 基础组件

```gdscript
class_name Component
extends Node

# 组件所属的实体
var entity: Node:
    get:
        return get_parent()

func _ready() -> void:
    # 组件初始化
    pass
```

## 常用组件

### 生命组件

```gdscript
class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died
signal healed(amount: int)
signal damaged(amount: int)

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    var actual_damage := mini(amount, current_health)
    current_health -= actual_damage

    damaged.emit(actual_damage)
    health_changed.emit(current_health, max_health)

    if current_health <= 0:
        died.emit()

func heal(amount: int) -> void:
    var actual_heal := mini(amount, max_health - current_health)
    current_health += actual_heal

    healed.emit(actual_heal)
    health_changed.emit(current_health, max_health)

func is_alive() -> bool:
    return current_health > 0

func get_health_percent() -> float:
    return float(current_health) / float(max_health)
```

### 移动组件

```gdscript
class_name MovementComponent
extends Node

@export var move_speed: float = 200.0
@export var acceleration: float = 1000.0
@export var friction: float = 800.0

var velocity: Vector2 = Vector2.ZERO
var body: CharacterBody2D

func _ready() -> void:
    body = get_parent() as CharacterBody2D

func move(direction: Vector2, delta: float) -> void:
    if direction.length() > 0:
        velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

    body.velocity = velocity
    body.move_and_slide()
    velocity = body.velocity
```

### 攻击组件

```gdscript
class_name AttackComponent
extends Node

signal attack_started
signal attack_ended
signal dealt_damage(target: Node, amount: int)

@export var damage: int = 10
@export var attack_cooldown: float = 0.5
@export var hitbox_path: NodePath

var _can_attack: bool = true
var _hitbox: Area2D

func _ready() -> void:
    _hitbox = get_node(hitbox_path) as Area2D
    _hitbox.body_entered.connect(_on_hitbox_body_entered)
    _hitbox.monitoring = false

func attack() -> void:
    if not _can_attack:
        return

    _can_attack = false
    attack_started.emit()

    _hitbox.monitoring = true
    await get_tree().create_timer(0.1).timeout
    _hitbox.monitoring = false

    attack_ended.emit()

    await get_tree().create_timer(attack_cooldown).timeout
    _can_attack = true

func _on_hitbox_body_entered(body: Node2D) -> void:
    var health := body.get_node_or_null("HealthComponent") as HealthComponent
    if health:
        health.take_damage(damage)
        dealt_damage.emit(body, damage)
```

### 拾取组件

```gdscript
class_name PickupComponent
extends Node

signal item_collected(item: Node)

@export var pickup_area_path: NodePath
var _pickup_area: Area2D

func _ready() -> void:
    _pickup_area = get_node(pickup_area_path) as Area2D
    _pickup_area.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("pickup"):
        item_collected.emit(area)
        if area.has_method("collect"):
            area.collect(get_parent())
```

## 组合实体

```gdscript
# Player 使用组件组合
extends CharacterBody2D

@onready var health: HealthComponent = $HealthComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var attack: AttackComponent = $AttackComponent

func _ready() -> void:
    health.died.connect(_on_died)
    health.damaged.connect(_on_damaged)

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("left", "right", "up", "down")
    movement.move(direction, delta)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        attack.attack()

func _on_died() -> void:
    queue_free()

func _on_damaged(amount: int) -> void:
    # 闪烁效果等
    pass
```

## 场景结构

```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── HealthComponent
├── MovementComponent
├── AttackComponent
│   └── Hitbox (Area2D)
└── PickupComponent
    └── PickupArea (Area2D)
```

## 组件通信

### 通过信号

```gdscript
# 组件之间通过信号解耦
func _ready() -> void:
    var health := get_node_or_null("HealthComponent")
    var animation := get_node_or_null("AnimationComponent")

    if health and animation:
        health.damaged.connect(animation.play_hurt)
        health.died.connect(animation.play_death)
```

### 通过组件查找

```gdscript
# 查找兄弟组件
func get_sibling_component(component_type: Script) -> Node:
    for sibling in get_parent().get_children():
        if sibling.get_script() == component_type:
            return sibling
    return null

# 使用
func _ready() -> void:
    var health := get_sibling_component(HealthComponent)
```

## 组件工厂

```gdscript
class_name ComponentFactory

static func add_health(entity: Node, max_health: int = 100) -> HealthComponent:
    var component := HealthComponent.new()
    component.max_health = max_health
    entity.add_child(component)
    return component

static func add_movement(entity: Node, speed: float = 200.0) -> MovementComponent:
    var component := MovementComponent.new()
    component.move_speed = speed
    entity.add_child(component)
    return component
```

## 优势

1. **可复用** - 同一组件用于不同实体
2. **可组合** - 灵活组合功能
3. **解耦** - 组件间低耦合
4. **可测试** - 组件独立测试
