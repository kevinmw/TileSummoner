# 类型提示

## 为什么使用类型提示

1. **编译时错误检测** - 在运行前发现类型错误
2. **更好的代码补全** - IDE 提供准确的建议
3. **自文档化** - 代码意图更清晰
4. **性能优化** - 某些情况下运行更快

## 变量类型

```gdscript
# 基础类型
var health: int = 100
var speed: float = 200.0
var player_name: String = "Hero"
var is_alive: bool = true

# Godot 类型
var position: Vector2 = Vector2.ZERO
var color: Color = Color.WHITE
var direction: Vector3 = Vector3.FORWARD

# 节点类型
var player: CharacterBody2D = null
var sprite: Sprite2D = null
var collision: CollisionShape2D = null

# 资源类型
var texture: Texture2D = null
var stats: CharacterStats = null
```

## 集合类型

```gdscript
# 类型化数组
var items: Array[Item] = []
var enemies: Array[Enemy] = []
var positions: Array[Vector2] = []
var scores: Array[int] = [100, 200, 300]

# Dictionary（键值类型提示有限）
var inventory: Dictionary = {}  # {String: int}
var data: Dictionary = {}

# PackedArray（性能更好）
var points: PackedVector2Array = []
var indices: PackedInt32Array = []
var colors: PackedColorArray = []
```

## 函数签名

```gdscript
# 参数和返回类型
func calculate_damage(base: int, multiplier: float) -> int:
    return int(base * multiplier)

# void 返回
func take_damage(amount: int) -> void:
    health -= amount

# 可选参数
func spawn_enemy(pos: Vector2, type: String = "basic") -> Enemy:
    var enemy: Enemy = EnemyScene.instantiate()
    enemy.position = pos
    enemy.enemy_type = type
    return enemy

# 无返回值可省略
func _ready():
    pass
```

## @onready 类型

```gdscript
# 显式类型
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox

# 或使用 as 转换
@onready var label = $Label as Label
```

## 枚举作为类型

```gdscript
enum State { IDLE, RUN, JUMP, FALL }

var current_state: State = State.IDLE

func change_state(new_state: State) -> void:
    current_state = new_state
```

## 自定义类型

```gdscript
# 使用 class_name 定义
class_name Player

# 其他文件可使用
var player: Player = null
var players: Array[Player] = []
```

## 可空类型

```gdscript
# 节点引用可为 null
var target: Node2D = null

func set_target(new_target: Node2D) -> void:
    target = new_target

func attack() -> void:
    if target != null:
        target.take_damage(damage)
    # 或使用安全调用
    if is_instance_valid(target):
        target.take_damage(damage)
```

## 类型转换

```gdscript
# as 操作符（安全转换）
var body := other as CharacterBody2D
if body:
    body.take_damage(10)

# 强制转换（确定类型时）
var damage: int = int(base_damage * multiplier)
var index: int = floori(progress * array.size())
```

## 静态类型模式

在项目设置中启用严格类型检查：
- 项目 → 项目设置 → Debug → GDScript
- 启用相关警告选项
