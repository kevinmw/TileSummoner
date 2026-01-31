# @onready 节点引用模式

## 基础用法

`@onready` 在 `_ready()` 调用前解析节点路径，比在 `_ready()` 中手动获取更简洁。

```gdscript
# ✅ 推荐方式
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D

# ❌ 避免 - 冗长且易出错
var sprite: Sprite2D

func _ready() -> void:
    sprite = $Sprite2D
```

## 类型安全

```gdscript
# 显式类型声明
@onready var label: Label = $UI/ScoreLabel
@onready var progress_bar: ProgressBar = $UI/HealthBar

# 使用 as 转换（当路径可能变化时）
@onready var player = get_node("../Player") as CharacterBody2D
```

## 嵌套节点路径

```gdscript
# 场景树结构:
# Player
# ├── Sprite2D
# ├── CollisionShape2D
# ├── Pivot
# │   ├── Weapon
# │   └── Hitbox
# └── UI
#     └── HealthBar

@onready var sprite: Sprite2D = $Sprite2D
@onready var weapon: Node2D = $Pivot/Weapon
@onready var hitbox: Area2D = $Pivot/Hitbox
@onready var health_bar: ProgressBar = $UI/HealthBar
```

## 唯一名称 (%)

使用 `%` 访问场景中标记为"唯一名称"的节点：

```gdscript
# 在编辑器中右键节点 → Access as Unique Name
# 无论节点在树中的位置如何，都可以直接访问

@onready var health_bar: ProgressBar = %HealthBar
@onready var score_label: Label = %ScoreLabel
@onready var pause_menu: Control = %PauseMenu
```

## 常见模式

### 缓存子节点

```gdscript
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var state_machine: Node = $StateMachine
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
    hitbox.body_entered.connect(_on_hitbox_body_entered)
```

### 获取父节点

```gdscript
# 获取特定类型的父节点
@onready var character: CharacterBody2D = get_parent() as CharacterBody2D

# 向上查找
@onready var game_manager: Node = get_tree().current_scene.get_node("GameManager")
```

### 获取同级节点

```gdscript
# 通过父节点访问同级
@onready var sibling: Node2D = get_parent().get_node("SiblingNode")

# 或使用相对路径
@onready var sibling: Node2D = $"../SiblingNode"
```

## 空值检查

```gdscript
@onready var optional_node: Node2D = get_node_or_null("OptionalChild")

func _ready() -> void:
    if optional_node:
        optional_node.visible = true

# 或在使用时检查
func update_ui() -> void:
    if is_instance_valid(health_bar):
        health_bar.value = health
```

## 注意事项

1. **不要在 @onready 之前访问** - 节点尚未解析
2. **路径必须正确** - 拼写错误会导致 null
3. **场景实例化时机** - 确保子节点已添加到树
4. **使用类型提示** - 获得更好的代码补全

```gdscript
# ❌ 错误 - 在 @onready 前访问
var sprite: Sprite2D = $Sprite2D  # 会是 null！

# ✅ 正确
@onready var sprite: Sprite2D = $Sprite2D
```
