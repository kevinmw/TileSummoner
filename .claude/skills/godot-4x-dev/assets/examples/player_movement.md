# 玩家移动系统完整示例

## 概述

这个示例展示如何实现一个完整的 2D 平台跳跃玩家移动系统，包含：

- 基础移动和跳跃
- Coyote time 和 Jump buffer
- 可变跳跃高度
- 状态机管理
- 动画集成

## 场景结构

```
Player (CharacterBody2D)
├── Sprite2D
├── AnimationPlayer
├── CollisionShape2D (CapsuleShape2D)
├── StateMachine
│   ├── Idle
│   ├── Run
│   ├── Jump
│   └── Fall
└── Camera2D
```

## 主玩家脚本

```gdscript
# player.gd
class_name Player
extends CharacterBody2D

## 信号
signal health_changed(current: int, maximum: int)
signal died

## 移动参数
@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

## 跳跃参数
@export_group("Jump")
@export var jump_force: float = -400.0
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.5
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

## 状态
var facing_direction: int = 1
var is_dead: bool = false

## 内部计时器
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0

## 节点引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine


func _physics_process(delta: float) -> void:
    if is_dead:
        return

    _update_timers(delta)
    _apply_gravity(delta)

    move_and_slide()


func _update_timers(delta: float) -> void:
    if is_on_floor():
        _coyote_timer = coyote_time
    else:
        _coyote_timer = maxf(_coyote_timer - delta, 0.0)

    if Input.is_action_just_pressed("jump"):
        _jump_buffer_timer = jump_buffer_time
    else:
        _jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        var grav_mult := fall_gravity_multiplier if velocity.y > 0 else 1.0
        velocity.y += gravity * grav_mult * delta


func can_jump() -> bool:
    return is_on_floor() or _coyote_timer > 0


func wants_jump() -> bool:
    return Input.is_action_just_pressed("jump") or _jump_buffer_timer > 0


func consume_jump() -> void:
    velocity.y = jump_force
    _coyote_timer = 0.0
    _jump_buffer_timer = 0.0


func get_input_direction() -> float:
    return Input.get_axis("move_left", "move_right")


func update_facing(direction: float) -> void:
    if direction != 0:
        facing_direction = int(sign(direction))
        sprite.flip_h = facing_direction < 0
```

## 状态脚本

### 基础状态

```gdscript
# player_state.gd
class_name PlayerState
extends State

var player: Player

func _ready() -> void:
    await owner.ready
    player = owner as Player
```

### 空闲状态

```gdscript
# idle_state.gd
extends PlayerState

func enter() -> void:
    player.anim.play("idle")
    player.velocity.x = 0


func physics_update(delta: float) -> void:
    var direction := player.get_input_direction()

    if direction != 0:
        transition_to("Run")
        return

    if player.can_jump() and player.wants_jump():
        player.consume_jump()
        transition_to("Jump")
        return

    if not player.is_on_floor():
        transition_to("Fall")
```

### 跑步状态

```gdscript
# run_state.gd
extends PlayerState

func enter() -> void:
    player.anim.play("run")


func physics_update(delta: float) -> void:
    var direction := player.get_input_direction()

    if direction == 0:
        transition_to("Idle")
        return

    player.velocity.x = move_toward(
        player.velocity.x,
        direction * player.move_speed,
        player.acceleration * delta
    )
    player.update_facing(direction)

    if player.can_jump() and player.wants_jump():
        player.consume_jump()
        transition_to("Jump")
        return

    if not player.is_on_floor():
        transition_to("Fall")
```

### 跳跃状态

```gdscript
# jump_state.gd
extends PlayerState

func enter() -> void:
    player.anim.play("jump")


func physics_update(delta: float) -> void:
    # 空中移动
    var direction := player.get_input_direction()
    player.velocity.x = move_toward(
        player.velocity.x,
        direction * player.move_speed * 0.8,
        player.acceleration * 0.5 * delta
    )

    if direction != 0:
        player.update_facing(direction)

    # 可变跳跃高度
    if Input.is_action_just_released("jump") and player.velocity.y < 0:
        player.velocity.y *= 0.5

    # 转换到下落
    if player.velocity.y >= 0:
        transition_to("Fall")
```

### 下落状态

```gdscript
# fall_state.gd
extends PlayerState

func enter() -> void:
    player.anim.play("fall")


func physics_update(delta: float) -> void:
    var direction := player.get_input_direction()
    player.velocity.x = move_toward(
        player.velocity.x,
        direction * player.move_speed * 0.8,
        player.acceleration * 0.5 * delta
    )

    if direction != 0:
        player.update_facing(direction)

    if player.is_on_floor():
        if direction != 0:
            transition_to("Run")
        else:
            transition_to("Idle")
```

## 输入映射

在项目设置中配置：

```
move_left:  A, Left Arrow
move_right: D, Right Arrow
jump:       Space, W, Up Arrow
```

## MCP 工具验证

```bash
# 验证代码
godot_lint_file player.gd

# 运行测试
godot_run_tests tests/player/
```
