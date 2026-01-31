# GDScript 代码风格

## 文件结构顺序

```gdscript
# 1. 类定义
class_name MyClass
extends Node2D

# 2. 文档注释
## 这个类负责处理玩家输入

# 3. 信号
signal health_changed(value: int)
signal died

# 4. 枚举
enum State { IDLE, RUNNING, JUMPING }

# 5. 常量
const MAX_SPEED: float = 200.0

# 6. @export 变量（按功能分组）
@export_group("Movement")
@export var speed: float = 100.0
@export var jump_force: float = 300.0

@export_group("Combat")
@export var max_health: int = 100

# 7. public 变量
var current_state: State = State.IDLE

# 8. private 变量 (下划线前缀)
var _velocity: Vector2 = Vector2.ZERO

# 9. @onready 变量
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

# 10. 内置回调（按生命周期顺序）
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func _physics_process(delta: float) -> void:
    pass

func _input(event: InputEvent) -> void:
    pass

# 11. public 方法
func take_damage(amount: int) -> void:
    pass

# 12. private 方法
func _calculate_movement() -> Vector2:
    return Vector2.ZERO
```

## 类型提示（必须）

```gdscript
# 变量
var health: int = 100
var position: Vector2 = Vector2.ZERO
var items: Array[Item] = []
var stats: Dictionary = {}

# 函数参数和返回值
func calculate_damage(base: int, multiplier: float) -> int:
    return int(base * multiplier)

# 可空类型
var target: Node2D = null
```

## 空行规则

- 顶级声明之间：2 个空行
- 方法内逻辑块之间：1 个空行
- 紧密相关的代码：无空行

## 行长度

- 最大 100 字符
- 长语句换行：

```gdscript
var result = some_long_function_name(
    first_argument,
    second_argument,
    third_argument
)
```

## 禁止事项

```gdscript
# ❌ 避免 - 无类型
var speed = 100

# ✅ 正确 - 有类型
var speed: float = 100.0

# ❌ 避免 - 硬编码字符串
if state == "idle":

# ✅ 正确 - 使用枚举
if state == State.IDLE:
```

## MCP 验证

使用 `godot_lint_file` 检查代码风格
