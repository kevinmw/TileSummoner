# 枚举与常量

## 枚举定义

```gdscript
# 基础枚举
enum State { IDLE, RUN, JUMP, FALL, ATTACK }

# 带值枚举
enum Direction {
    UP = 0,
    DOWN = 1,
    LEFT = 2,
    RIGHT = 3
}

# 位标志枚举
enum DamageFlags {
    NONE = 0,
    PHYSICAL = 1 << 0,    # 1
    MAGICAL = 1 << 1,     # 2
    FIRE = 1 << 2,        # 4
    ICE = 1 << 3,         # 8
    CRITICAL = 1 << 4     # 16
}
```

## 使用枚举

```gdscript
var current_state: State = State.IDLE
var facing: Direction = Direction.RIGHT

func change_state(new_state: State) -> void:
    if current_state == new_state:
        return
    current_state = new_state

# switch/match 语句
func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            process_idle(delta)
        State.RUN:
            process_run(delta)
        State.JUMP, State.FALL:
            process_air(delta)
        State.ATTACK:
            process_attack(delta)
```

## 位标志操作

```gdscript
var damage_types: int = DamageFlags.NONE

# 添加标志
damage_types |= DamageFlags.PHYSICAL
damage_types |= DamageFlags.FIRE

# 检查标志
if damage_types & DamageFlags.FIRE:
    apply_burn_effect()

# 移除标志
damage_types &= ~DamageFlags.FIRE

# 组合标志
const ELEMENTAL = DamageFlags.FIRE | DamageFlags.ICE
```

## 常量定义

```gdscript
# 数值常量
const MAX_HEALTH: int = 100
const GRAVITY: float = 980.0
const MOVE_SPEED: float = 200.0
const JUMP_FORCE: float = -400.0

# 字符串常量
const PLAYER_GROUP: String = "player"
const ENEMY_GROUP: String = "enemies"
const SAVE_PATH: String = "user://save.dat"

# Vector 常量
const SPAWN_POSITION: Vector2 = Vector2(100, 200)
const DEFAULT_SCALE: Vector2 = Vector2.ONE

# 预加载场景/资源
const BulletScene: PackedScene = preload("res://scenes/bullet.tscn")
const HitSound: AudioStream = preload("res://audio/hit.wav")
```

## 常量类（组织相关常量）

```gdscript
# constants.gd
class_name Constants

# 游戏配置
class Game:
    const TILE_SIZE: int = 16
    const MAX_ENEMIES: int = 50
    const RESPAWN_TIME: float = 3.0

# 物理参数
class Physics:
    const GRAVITY: float = 980.0
    const TERMINAL_VELOCITY: float = 500.0
    const FRICTION: float = 0.8

# 输入动作名
class Input:
    const MOVE_LEFT: String = "move_left"
    const MOVE_RIGHT: String = "move_right"
    const JUMP: String = "jump"
    const ATTACK: String = "attack"

# 使用
func _physics_process(delta: float) -> void:
    velocity.y += Constants.Physics.GRAVITY * delta
```

## 枚举转换

```gdscript
enum State { IDLE, RUN, JUMP }

# 枚举转字符串
var state_name: String = State.keys()[current_state]

# 字符串转枚举
var state_value: State = State.get(state_name)

# 枚举转数值
var state_int: int = current_state

# 数值转枚举（需要验证）
func int_to_state(value: int) -> State:
    if value >= 0 and value < State.size():
        return value as State
    return State.IDLE
```

## 最佳实践

```gdscript
# ✅ 使用枚举替代魔法数字和字符串
enum PlayerClass { WARRIOR, MAGE, ROGUE }
var player_class: PlayerClass = PlayerClass.WARRIOR

# ❌ 避免
var player_class: String = "warrior"
var player_class: int = 0

# ✅ 使用常量替代硬编码值
const COYOTE_TIME: float = 0.1
if time_since_grounded < COYOTE_TIME:
    can_jump = true

# ❌ 避免
if time_since_grounded < 0.1:  # 魔法数字
    can_jump = true
```
