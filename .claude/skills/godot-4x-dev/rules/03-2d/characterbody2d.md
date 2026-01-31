# CharacterBody2D 角色控制器

## 基础移动

```gdscript
extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_VELOCITY: float = -400.0
const GRAVITY: float = 980.0

func _physics_process(delta: float) -> void:
    # 重力
    if not is_on_floor():
        velocity.y += GRAVITY * delta

    # 跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # 水平移动
    var direction := Input.get_axis("move_left", "move_right")
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
```

## 完整平台跳跃控制器

```gdscript
extends CharacterBody2D

@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

@export_group("Jump")
@export var jump_force: float = -400.0
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.5
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false

func _physics_process(delta: float) -> void:
    _update_timers(delta)
    _apply_gravity(delta)
    _handle_jump()
    _handle_horizontal_movement(delta)
    move_and_slide()
    _was_on_floor = is_on_floor()

func _update_timers(delta: float) -> void:
    # Coyote time - 离开平台后短暂允许跳跃
    if is_on_floor():
        _coyote_timer = coyote_time
    else:
        _coyote_timer -= delta

    # Jump buffer - 落地前按跳跃会在落地时触发
    if Input.is_action_just_pressed("jump"):
        _jump_buffer_timer = jump_buffer_time
    else:
        _jump_buffer_timer -= delta

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        var gravity_scale := fall_gravity_multiplier if velocity.y > 0 else 1.0
        velocity.y += gravity * gravity_scale * delta
        velocity.y = min(velocity.y, gravity)  # 终端速度

func _handle_jump() -> void:
    var can_jump := is_on_floor() or _coyote_timer > 0
    var want_jump := Input.is_action_just_pressed("jump") or _jump_buffer_timer > 0

    if can_jump and want_jump:
        velocity.y = jump_force
        _coyote_timer = 0.0
        _jump_buffer_timer = 0.0

    # 可变跳跃高度 - 松开跳跃键减少上升
    if Input.is_action_just_released("jump") and velocity.y < 0:
        velocity.y *= 0.5

func _handle_horizontal_movement(delta: float) -> void:
    var direction := Input.get_axis("move_left", "move_right")

    if direction:
        velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, friction * delta)
```

## 状态机集成

```gdscript
enum State { IDLE, RUN, JUMP, FALL }
var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
    _apply_gravity(delta)

    match current_state:
        State.IDLE:
            _state_idle()
        State.RUN:
            _state_run()
        State.JUMP:
            _state_jump()
        State.FALL:
            _state_fall()

    move_and_slide()
    _update_state()

func _update_state() -> void:
    if not is_on_floor():
        current_state = State.JUMP if velocity.y < 0 else State.FALL
    elif abs(velocity.x) > 10:
        current_state = State.RUN
    else:
        current_state = State.IDLE
```

## 常用属性

```gdscript
# CharacterBody2D 属性
motion_mode = MOTION_MODE_GROUNDED  # 或 MOTION_MODE_FLOATING
up_direction = Vector2.UP
floor_stop_on_slope = true
floor_max_angle = deg_to_rad(45)
platform_on_leave = PLATFORM_ON_LEAVE_ADD_VELOCITY

# 检测
is_on_floor()      # 是否在地面
is_on_wall()       # 是否接触墙壁
is_on_ceiling()    # 是否接触天花板
get_floor_normal() # 地面法线
get_last_slide_collision() # 最后碰撞信息
```

## 场景结构

```
Player (CharacterBody2D)
├── CollisionShape2D (CapsuleShape2D)
├── AnimatedSprite2D
├── AnimationPlayer
└── Camera2D
```
