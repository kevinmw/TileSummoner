# 节点与场景系统

## 核心概念

**节点 (Node)**: Godot 的基本构建块，具有名称、属性和方法
**场景 (Scene)**: 节点树的可重用组合，保存为 `.tscn` 文件

## 常用节点类型

### 2D 节点
```
Node2D          - 2D 基类，有 transform
├── Sprite2D    - 显示纹理
├── AnimatedSprite2D - 帧动画
├── CharacterBody2D  - 角色物理
├── RigidBody2D      - 刚体物理
├── Area2D           - 检测区域
├── Camera2D         - 2D 相机
└── TileMapLayer     - 瓦片地图
```

### 3D 节点
```
Node3D          - 3D 基类
├── MeshInstance3D   - 3D 网格
├── CharacterBody3D  - 角色物理
├── RigidBody3D      - 刚体物理
├── Area3D           - 检测区域
└── Camera3D         - 3D 相机
```

### UI 节点
```
Control         - UI 基类
├── Label       - 文本
├── Button      - 按钮
├── TextureRect - 图片
└── Container   - 布局容器
```

## 场景实例化

```gdscript
# 预加载场景（编译时）
const BulletScene = preload("res://src/weapons/bullet.tscn")

# 运行时加载
var enemy_scene = load("res://src/enemies/enemy.tscn")

# 实例化
func spawn_bullet() -> void:
    var bullet: Node2D = BulletScene.instantiate()
    bullet.position = global_position
    bullet.direction = facing_direction
    get_tree().current_scene.add_child(bullet)
```

## 节点引用

```gdscript
# @onready - 在 _ready() 前解析
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

# 相对路径
@onready var hitbox: Area2D = $Pivot/Hitbox

# 获取父节点
var parent: Node = get_parent()

# 获取子节点
var children: Array[Node] = get_children()

# 按组查找
var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
```

## 节点组

```gdscript
# 添加到组
func _ready() -> void:
    add_to_group("enemies")
    add_to_group("damageable")

# 调用组内所有节点
get_tree().call_group("enemies", "take_damage", 10)

# 检查组
if is_in_group("player"):
    pass
```

## 节点生命周期

1. `_init()` - 构造函数
2. `_enter_tree()` - 进入场景树
3. `_ready()` - 所有子节点就绪
4. `_process()` / `_physics_process()` - 每帧调用
5. `_exit_tree()` - 离开场景树

## MCP 工具

- `godot_create_scene`: 创建新场景
- `godot_add_node`: 添加节点
- `godot_analyze_scene`: 分析场景结构
