# 敌人 AI 系统完整示例

## 概述

这个示例展示如何实现一个基础的敌人 AI 系统，包含：

- 巡逻行为
- 玩家检测
- 追击行为
- 攻击系统
- 状态机管理

## 场景结构

```
Enemy (CharacterBody2D)
├── Sprite2D
├── AnimationPlayer
├── CollisionShape2D
├── DetectionArea (Area2D)
│   └── CollisionShape2D
├── AttackArea (Area2D)
│   └── CollisionShape2D
├── RayCast2D (视线检测)
└── StateMachine
    ├── Patrol
    ├── Chase
    ├── Attack
    └── Hurt
```

## 敌人基类

```gdscript
# enemy.gd
class_name Enemy
extends CharacterBody2D

## 信号
signal died
signal health_changed(current: int, maximum: int)

## 属性
@export_group("Stats")
@export var max_health: int = 100
@export var damage: int = 10
@export var move_speed: float = 80.0
@export var chase_speed: float = 120.0

@export_group("Detection")
@export var detection_range: float = 200.0
@export var attack_range: float = 40.0
@export var lose_sight_range: float = 300.0

## 状态
var health: int
var target: Node2D = null
var facing_direction: int = 1

## 节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var raycast: RayCast2D = $RayCast2D
@onready var state_machine: StateMachine = $StateMachine

## 巡逻点
@export var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0


func _ready() -> void:
    health = max_health
    detection_area.body_entered.connect(_on_detection_area_body_entered)
    detection_area.body_exited.connect(_on_detection_area_body_exited)


func _physics_process(delta: float) -> void:
    apply_gravity(delta)
    move_and_slide()


func apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y += 980.0 * delta


func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health, max_health)

    if health <= 0:
        die()
    else:
        state_machine.transition_to("Hurt")


func die() -> void:
    died.emit()
    queue_free()


func update_facing(direction: float) -> void:
    if direction != 0:
        facing_direction = int(sign(direction))
        sprite.flip_h = facing_direction < 0
        raycast.target_position.x = abs(raycast.target_position.x) * facing_direction


func can_see_target() -> bool:
    if not target:
        return false

    raycast.target_position = (target.global_position - global_position).normalized() * detection_range
    raycast.force_raycast_update()

    if raycast.is_colliding():
        return raycast.get_collider() == target

    return true


func get_direction_to_target() -> float:
    if not target:
        return 0.0
    return sign(target.global_position.x - global_position.x)


func get_distance_to_target() -> float:
    if not target:
        return INF
    return global_position.distance_to(target.global_position)


func _on_detection_area_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        target = body


func _on_detection_area_body_exited(body: Node2D) -> void:
    if body == target:
        target = null
```

## AI 状态

### 巡逻状态

```gdscript
# patrol_state.gd
extends State

var enemy: Enemy
var wait_timer: float = 0.0
const WAIT_TIME: float = 2.0

func _ready() -> void:
    await owner.ready
    enemy = owner as Enemy


func enter() -> void:
    enemy.anim.play("walk")
    wait_timer = 0.0


func physics_update(delta: float) -> void:
    # 检测玩家
    if enemy.target and enemy.can_see_target():
        transition_to("Chase")
        return

    # 巡逻逻辑
    if enemy.patrol_points.is_empty():
        _idle_behavior(delta)
        return

    _patrol_behavior(delta)


func _idle_behavior(delta: float) -> void:
    enemy.velocity.x = 0
    enemy.anim.play("idle")


func _patrol_behavior(delta: float) -> void:
    var target_point := enemy.patrol_points[enemy.current_patrol_index]
    var distance := enemy.global_position.distance_to(target_point)

    if distance < 10:
        # 到达巡逻点，等待
        wait_timer += delta
        enemy.velocity.x = 0
        enemy.anim.play("idle")

        if wait_timer >= WAIT_TIME:
            wait_timer = 0.0
            enemy.current_patrol_index = (enemy.current_patrol_index + 1) % enemy.patrol_points.size()
    else:
        # 移动到巡逻点
        var direction := sign(target_point.x - enemy.global_position.x)
        enemy.velocity.x = direction * enemy.move_speed
        enemy.update_facing(direction)
        enemy.anim.play("walk")
```

### 追击状态

```gdscript
# chase_state.gd
extends State

var enemy: Enemy

func _ready() -> void:
    await owner.ready
    enemy = owner as Enemy


func enter() -> void:
    enemy.anim.play("run")


func physics_update(delta: float) -> void:
    # 丢失目标
    if not enemy.target:
        transition_to("Patrol")
        return

    var distance := enemy.get_distance_to_target()

    # 超出追击范围
    if distance > enemy.lose_sight_range:
        enemy.target = null
        transition_to("Patrol")
        return

    # 进入攻击范围
    if distance <= enemy.attack_range:
        transition_to("Attack")
        return

    # 追击
    var direction := enemy.get_direction_to_target()
    enemy.velocity.x = direction * enemy.chase_speed
    enemy.update_facing(direction)
```

### 攻击状态

```gdscript
# attack_state.gd
extends State

var enemy: Enemy
var has_attacked: bool = false

func _ready() -> void:
    await owner.ready
    enemy = owner as Enemy
    enemy.anim.animation_finished.connect(_on_animation_finished)


func enter() -> void:
    enemy.velocity.x = 0
    has_attacked = false
    enemy.anim.play("attack")


func exit() -> void:
    has_attacked = false


func physics_update(delta: float) -> void:
    # 在攻击动画的特定帧触发伤害
    if not has_attacked and enemy.anim.current_animation_position > 0.3:
        _deal_damage()
        has_attacked = true


func _deal_damage() -> void:
    for body in enemy.attack_area.get_overlapping_bodies():
        if body.is_in_group("player") and body.has_method("take_damage"):
            body.take_damage(enemy.damage)


func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "attack" and enemy.state_machine.get_current_state_name() == name:
        # 检查是否继续攻击
        if enemy.get_distance_to_target() <= enemy.attack_range:
            enter()  # 重新攻击
        else:
            transition_to("Chase")
```

### 受伤状态

```gdscript
# hurt_state.gd
extends State

var enemy: Enemy

func _ready() -> void:
    await owner.ready
    enemy = owner as Enemy
    enemy.anim.animation_finished.connect(_on_animation_finished)


func enter() -> void:
    enemy.velocity.x = 0
    enemy.anim.play("hurt")


func _on_animation_finished(anim_name: String) -> void:
    if anim_name == "hurt" and enemy.state_machine.get_current_state_name() == name:
        if enemy.target:
            transition_to("Chase")
        else:
            transition_to("Patrol")
```

## 使用方式

1. 创建敌人场景，附加 `enemy.gd` 脚本
2. 配置子节点
3. 设置巡逻点或留空（会原地待机）
4. 将玩家添加到 "player" 组
