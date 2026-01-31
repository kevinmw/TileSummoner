# 性能优化

## 通用原则

1. **先测量，再优化** - 使用 Profiler 定位瓶颈
2. **80/20 法则** - 20% 的代码造成 80% 的性能问题
3. **避免过早优化** - 先让代码正确工作

## 使用 Profiler

```gdscript
# 开启性能分析
# Debug → Monitors 查看性能指标
# Debug → Profiler 查看函数调用

# 代码中测量
var start := Time.get_ticks_usec()
# ... 被测代码 ...
var elapsed := Time.get_ticks_usec() - start
print("Elapsed: %d μs" % elapsed)
```

## GDScript 优化

### 减少函数调用

```gdscript
# ❌ 低效
for i in 1000:
    var pos := get_global_position()
    do_something(pos)

# ✅ 高效
var pos := global_position  # 直接访问属性
for i in 1000:
    do_something(pos)
```

### 使用静态类型

```gdscript
# ❌ 无类型
var speed = 100
var direction = Vector2.RIGHT

# ✅ 有类型（更快）
var speed: float = 100.0
var direction: Vector2 = Vector2.RIGHT
```

### 缓存节点引用

```gdscript
# ❌ 每次调用都查找
func _process(delta: float) -> void:
    $Sprite2D.rotation += delta
    get_node("AnimationPlayer").play("idle")

# ✅ 缓存引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _process(delta: float) -> void:
    sprite.rotation += delta
    anim.play("idle")
```

### 使用适当的集合

```gdscript
# Array - 有序，随机访问 O(1)，搜索 O(n)
var items: Array[Item] = []

# Dictionary - 键值对，访问 O(1)
var items_by_id: Dictionary = {}

# PackedArray - 更紧凑，适合大量数值
var positions: PackedVector2Array = []
```

## 物理优化

### 碰撞层优化

```gdscript
# 减少不必要的碰撞检测
# 只检测需要的层
collision_mask = 1 << 0  # 只检测 Layer 1

# 禁用不需要的碰撞
collision_layer = 0  # 不被其他物体检测
```

### 简化碰撞形状

```gdscript
# ✅ 简单形状性能更好
# CircleShape2D > CapsuleShape2D > ConvexPolygonShape2D > ConcavePolygonShape2D

# 对于复杂模型，使用简化的碰撞形状
```

### 减少物理对象

```gdscript
# 使用 Area2D 替代 RigidBody2D（当不需要物理模拟时）
# 远距离物体禁用物理
if global_position.distance_to(player_pos) > 1000:
    set_physics_process(false)
```

## 渲染优化

### 减少 Draw Calls

```gdscript
# 合并 Sprite 到 SpriteSheet
# 使用 TextureAtlas

# 启用批处理
# 项目设置 → Rendering → Batching
```

### 视口剔除

```gdscript
# 设置 VisibilityNotifier2D
@onready var visibility: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
    visibility.screen_entered.connect(_on_screen_entered)
    visibility.screen_exited.connect(_on_screen_exited)

func _on_screen_entered() -> void:
    set_process(true)
    set_physics_process(true)

func _on_screen_exited() -> void:
    set_process(false)
    set_physics_process(false)
```

### 减少粒子

```gdscript
# 使用 GPUParticles2D 替代 CPUParticles2D
# 减少粒子数量
# 使用 LOD（远距离简化）
```

## 内存优化

### 对象池

```gdscript
# 复用频繁创建的对象
# 见 object-pooling.md
```

### 资源管理

```gdscript
# 预加载常用资源
const BULLET := preload("res://scenes/bullet.tscn")

# 释放不用的资源
resource = null

# 使用 load() 进行延迟加载
var heavy_resource = load("res://large_texture.png")
```

### 内存监控

```gdscript
# 查看内存使用
print(Performance.get_monitor(Performance.MEMORY_STATIC))
print(Performance.get_monitor(Performance.OBJECT_COUNT))
```

## 算法优化

### 空间分区

```gdscript
# 使用网格或四叉树进行空间查询
# 而不是遍历所有对象
func get_nearby_enemies(pos: Vector2, radius: float) -> Array:
    # 使用 Physics2DDirectSpaceState
    var space := get_world_2d().direct_space_state
    var query := PhysicsShapeQueryParameters2D.new()
    # ...
```

### 帧分散处理

```gdscript
# 分散计算到多帧
var _enemies_to_update: Array[Enemy] = []
var _update_index: int = 0
const UPDATES_PER_FRAME: int = 10

func _process(_delta: float) -> void:
    for i in UPDATES_PER_FRAME:
        if _update_index >= _enemies_to_update.size():
            _update_index = 0
            break
        _enemies_to_update[_update_index].update_ai()
        _update_index += 1
```

## 性能监控指标

```gdscript
# 关键指标
Performance.get_monitor(Performance.TIME_FPS)
Performance.get_monitor(Performance.TIME_PROCESS)
Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
```
