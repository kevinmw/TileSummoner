# AnimationTree 状态机

## AnimationTree 设置

```gdscript
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback

func _ready() -> void:
    anim_tree.active = true
    state_machine = anim_tree.get("parameters/playback")
```

## 场景结构

```
Character (CharacterBody2D/3D)
├── AnimationPlayer
├── AnimationTree
│   └── AnimationNodeStateMachine (root)
│       ├── idle (AnimationNodeAnimation)
│       ├── walk (AnimationNodeAnimation)
│       ├── jump (AnimationNodeAnimation)
│       └── attack (AnimationNodeAnimation)
└── Sprite2D / Model
```

## 状态切换

```gdscript
func _physics_process(delta: float) -> void:
    update_animation_state()

func update_animation_state() -> void:
    if not is_on_floor():
        travel_to("jump")
    elif velocity.length() > 10:
        travel_to("walk")
    else:
        travel_to("idle")

func travel_to(state_name: String) -> void:
    if state_machine.get_current_node() != state_name:
        state_machine.travel(state_name)
```

## 状态机查询

```gdscript
# 获取当前状态
var current: StringName = state_machine.get_current_node()

# 检查是否在播放
var is_playing: bool = state_machine.is_playing()

# 获取当前播放位置
var position: float = state_machine.get_current_play_position()

# 获取当前动画长度
var length: float = state_machine.get_current_length()
```

## 混合空间（BlendSpace）

### BlendSpace1D

用于单一参数控制（如速度）：

```gdscript
# 设置混合参数
anim_tree.set("parameters/BlendSpace1D/blend_position", speed_ratio)

# speed_ratio: 0.0 = idle, 0.5 = walk, 1.0 = run
```

### BlendSpace2D

用于双参数控制（如方向 + 速度）：

```gdscript
# 设置 2D 混合参数
var blend_position := Vector2(velocity.x, velocity.z).normalized()
anim_tree.set("parameters/BlendSpace2D/blend_position", blend_position)
```

## 过渡配置

在 AnimationTree 编辑器中设置：

```
Transition 属性：
- Switch Mode: Immediate / Sync / AtEnd
- Advance Mode: Auto / Enabled / Disabled
- Priority: 数值越低优先级越高
- Xfade Time: 过渡混合时间
- Xfade Curve: 过渡曲线
```

## 条件过渡

```gdscript
# 在编辑器中为过渡添加条件
# 然后通过代码设置参数

# 设置布尔参数
anim_tree.set("parameters/conditions/is_attacking", true)

# 设置触发器（一次性）
anim_tree.set("parameters/conditions/jump_trigger", true)
```

## 子状态机

```
StateMachine (root)
├── locomotion (StateMachine)
│   ├── idle
│   ├── walk
│   └── run
├── air (StateMachine)
│   ├── jump
│   └── fall
└── combat (StateMachine)
    ├── attack1
    ├── attack2
    └── attack3
```

## 完整示例

```gdscript
extends CharacterBody2D

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback

enum State { IDLE, RUN, JUMP, FALL, ATTACK }
var current_state: State = State.IDLE

func _ready() -> void:
    anim_tree.active = true
    state_machine = anim_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
    handle_movement(delta)
    update_animation()
    move_and_slide()

func update_animation() -> void:
    var new_state := determine_state()
    if new_state != current_state:
        current_state = new_state
        apply_animation_state()

func determine_state() -> State:
    if not is_on_floor():
        return State.JUMP if velocity.y < 0 else State.FALL
    elif abs(velocity.x) > 10:
        return State.RUN
    else:
        return State.IDLE

func apply_animation_state() -> void:
    match current_state:
        State.IDLE:
            state_machine.travel("idle")
        State.RUN:
            state_machine.travel("run")
            update_blend_direction()
        State.JUMP:
            state_machine.travel("jump")
        State.FALL:
            state_machine.travel("fall")
        State.ATTACK:
            state_machine.travel("attack")

func update_blend_direction() -> void:
    var direction := sign(velocity.x)
    anim_tree.set("parameters/run/blend_position", direction)
```

## 性能提示

1. 禁用不需要的 AnimationTree: `anim_tree.active = false`
2. 使用 `travel()` 而非频繁调用
3. 避免每帧设置相同的参数值
