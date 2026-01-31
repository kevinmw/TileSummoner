# 调试技巧

## 打印调试

### 基础打印

```gdscript
print("Simple message")
print("Value: ", some_value)
print("Multiple: ", a, " ", b, " ", c)

# 格式化字符串
print("Player at (%d, %d)" % [position.x, position.y])
print("Health: %.1f%%" % (health / max_health * 100))

# 推送警告/错误
push_warning("Something might be wrong")
push_error("Something is definitely wrong")
```

### 条件打印

```gdscript
# 只在调试模式打印
if OS.is_debug_build():
    print("Debug info: ", debug_data)

# 使用 assert（release 模式下会被移除）
assert(health >= 0, "Health cannot be negative!")
```

## 可视化调试

### 绘制调试形状

```gdscript
extends Node2D

var _debug_points: Array[Vector2] = []

func _draw() -> void:
    if not OS.is_debug_build():
        return

    # 绘制点
    for point in _debug_points:
        draw_circle(point, 5, Color.RED)

    # 绘制线
    draw_line(start, end, Color.GREEN, 2.0)

    # 绘制矩形
    draw_rect(Rect2(pos, size), Color.BLUE, false, 2.0)

    # 绘制圆
    draw_arc(center, radius, 0, TAU, 32, Color.YELLOW, 2.0)

func add_debug_point(point: Vector2) -> void:
    _debug_points.append(point)
    queue_redraw()
```

### 调试绘制管理器

```gdscript
# autoloads/debug_draw.gd
extends Node2D

var _shapes: Array[Dictionary] = []
var _persistent_shapes: Array[Dictionary] = []

func _process(_delta: float) -> void:
    if not _shapes.is_empty():
        queue_redraw()
        _shapes.clear()

func _draw() -> void:
    for shape in _shapes + _persistent_shapes:
        _draw_shape(shape)

func line(from: Vector2, to: Vector2, color: Color = Color.WHITE, duration: float = 0) -> void:
    var shape := {"type": "line", "from": from, "to": to, "color": color}
    if duration > 0:
        _add_timed_shape(shape, duration)
    else:
        _shapes.append(shape)

func circle(pos: Vector2, radius: float, color: Color = Color.WHITE) -> void:
    _shapes.append({"type": "circle", "pos": pos, "radius": radius, "color": color})

func rect(rect: Rect2, color: Color = Color.WHITE) -> void:
    _shapes.append({"type": "rect", "rect": rect, "color": color})
```

## 断点调试

### 在编辑器中

```gdscript
# 点击行号设置断点
# 运行时会在断点处暂停

# 代码中设置断点
breakpoint  # 相当于在此行设置断点
```

### 调试器功能

- **Step Over (F10)** - 执行当前行
- **Step Into (F11)** - 进入函数
- **Step Out (Shift+F11)** - 跳出当前函数
- **Continue (F5)** - 继续执行

## 检查器调试

### @export 调试变量

```gdscript
@export_group("Debug")
@export var debug_mode: bool = false
@export var show_hitboxes: bool = false
@export var invincible: bool = false

func _physics_process(delta: float) -> void:
    if debug_mode:
        print_debug_info()

    if show_hitboxes:
        $Hitbox/CollisionShape2D.debug_color = Color.RED
```

### 运行时修改

```gdscript
# 在 Remote 场景树中选择节点
# 可以在 Inspector 中实时修改 @export 变量
```

## 信号调试

```gdscript
# 追踪信号发射
func _ready() -> void:
    health_changed.connect(_debug_health_changed)

func _debug_health_changed(value: int) -> void:
    print("[SIGNAL] health_changed: ", value)
    print_stack()  # 打印调用栈
```

## 性能调试

```gdscript
# 测量代码执行时间
func measure_performance() -> void:
    var start := Time.get_ticks_usec()

    # 被测代码
    expensive_operation()

    var elapsed := Time.get_ticks_usec() - start
    print("Operation took: %d μs" % elapsed)

# 帧率监控
func _process(_delta: float) -> void:
    if Engine.get_process_frames() % 60 == 0:
        print("FPS: ", Engine.get_frames_per_second())
```

## 调试类

```gdscript
class_name Debug
extends RefCounted

static var enabled: bool = OS.is_debug_build()

static func log(message: String, context: String = "") -> void:
    if enabled:
        var prefix := "[%s] " % context if context else ""
        print(prefix, message)

static func warn(message: String) -> void:
    if enabled:
        push_warning(message)

static func error(message: String) -> void:
    push_error(message)

static func assert_true(condition: bool, message: String = "") -> void:
    if not condition:
        push_error("Assertion failed: " + message)
        breakpoint

# 使用
Debug.log("Player spawned", "Game")
Debug.assert_true(health >= 0, "Health cannot be negative")
```

## 远程调试

```gdscript
# 项目设置 → Debug → Remote
# 可以调试导出的游戏

# 手机调试
# Editor → Editor Settings → Network → Remote
# 设置 Remote Host 和 Remote Port
```

## 常见调试场景

### 碰撞调试

```gdscript
# 显示碰撞形状
# 项目 → 项目设置 → Debug → Shapes → Collision
# 或在代码中
$CollisionShape2D.debug_color = Color(1, 0, 0, 0.5)
```

### 导航调试

```gdscript
# 显示导航网格
# Debug → Visible Navigation
```

### 空间查询调试

```gdscript
func debug_raycast(from: Vector2, to: Vector2) -> void:
    var result := raycast(from, to)
    DebugDraw.line(from, to, Color.RED if result else Color.GREEN)
    if result:
        DebugDraw.circle(result.position, 5, Color.YELLOW)
```
