# 状态机模式

## 基础状态机

```gdscript
class_name StateMachine
extends Node

signal state_changed(from_state: StringName, to_state: StringName)

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
    # 收集所有 State 子节点
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.state_machine = self

    # 设置初始状态
    if initial_state:
        current_state = initial_state
        current_state.enter()

func _process(delta: float) -> void:
    if current_state:
        current_state.update(delta)

func _physics_process(delta: float) -> void:
    if current_state:
        current_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
    if current_state:
        current_state.handle_input(event)

func transition_to(state_name: StringName) -> void:
    if not states.has(state_name):
        push_error("State not found: " + state_name)
        return

    if current_state:
        current_state.exit()

    var previous_state := current_state.name if current_state else &""
    current_state = states[state_name]
    current_state.enter()
    state_changed.emit(previous_state, state_name)
```

## 状态基类

```gdscript
class_name State
extends Node

var state_machine: StateMachine

# 进入状态
func enter() -> void:
    pass

# 退出状态
func exit() -> void:
    pass

# 每帧更新
func update(_delta: float) -> void:
    pass

# 物理更新
func physics_update(_delta: float) -> void:
    pass

# 输入处理
func handle_input(_event: InputEvent) -> void:
    pass
```

## 具体状态实现

### 空闲状态

```gdscript
class_name IdleState
extends State

@onready var character: CharacterBody2D = owner

func enter() -> void:
    character.velocity = Vector2.ZERO
    character.play_animation("idle")

func physics_update(_delta: float) -> void:
    if character.velocity.length() > 10:
        state_machine.transition_to("Run")

    if Input.is_action_just_pressed("jump") and character.is_on_floor():
        state_machine.transition_to("Jump")

func handle_input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        state_machine.transition_to("Attack")
```

### 跑步状态

```gdscript
class_name RunState
extends State

@onready var character: CharacterBody2D = owner

func enter() -> void:
    character.play_animation("run")

func physics_update(delta: float) -> void:
    var direction := Input.get_axis("move_left", "move_right")

    if direction == 0:
        state_machine.transition_to("Idle")
        return

    character.velocity.x = direction * character.move_speed

    if Input.is_action_just_pressed("jump") and character.is_on_floor():
        state_machine.transition_to("Jump")

    if not character.is_on_floor():
        state_machine.transition_to("Fall")
```

### 跳跃状态

```gdscript
class_name JumpState
extends State

@onready var character: CharacterBody2D = owner

func enter() -> void:
    character.velocity.y = character.jump_force
    character.play_animation("jump")

func physics_update(delta: float) -> void:
    # 空中移动
    var direction := Input.get_axis("move_left", "move_right")
    character.velocity.x = direction * character.move_speed * 0.8

    # 应用重力
    character.velocity.y += character.gravity * delta

    # 转换到下落状态
    if character.velocity.y > 0:
        state_machine.transition_to("Fall")

    # 可变跳跃高度
    if Input.is_action_just_released("jump"):
        character.velocity.y *= 0.5
```

## 场景结构

```
Player (CharacterBody2D)
├── Sprite2D
├── AnimationPlayer
├── CollisionShape2D
└── StateMachine
    ├── Idle (IdleState)
    ├── Run (RunState)
    ├── Jump (JumpState)
    ├── Fall (FallState)
    └── Attack (AttackState)
```

## 层级状态机

```gdscript
class_name HierarchicalStateMachine
extends StateMachine

var parent_state_machine: StateMachine

func _ready() -> void:
    super._ready()
    # 允许父状态机处理某些转换

func transition_to(state_name: StringName) -> void:
    if states.has(state_name):
        super.transition_to(state_name)
    elif parent_state_machine:
        parent_state_machine.transition_to(state_name)
```

## 推送状态机（用于临时状态）

```gdscript
class_name PushdownStateMachine
extends StateMachine

var state_stack: Array[State] = []

func push_state(state_name: StringName) -> void:
    if current_state:
        current_state.exit()
        state_stack.push_back(current_state)

    current_state = states[state_name]
    current_state.enter()

func pop_state() -> void:
    if current_state:
        current_state.exit()

    if state_stack.size() > 0:
        current_state = state_stack.pop_back()
        current_state.enter()
```

## 枚举状态机（简化版）

```gdscript
extends CharacterBody2D

enum State { IDLE, RUN, JUMP, FALL, ATTACK }
var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            state_idle(delta)
        State.RUN:
            state_run(delta)
        State.JUMP:
            state_jump(delta)
        State.FALL:
            state_fall(delta)
        State.ATTACK:
            state_attack(delta)

    move_and_slide()

func change_state(new_state: State) -> void:
    exit_state(current_state)
    current_state = new_state
    enter_state(new_state)
```
