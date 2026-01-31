# 内存管理

## 内存基础

### 引用类型

```gdscript
# Object 派生类 - 需要手动管理
var obj := Object.new()
obj.free()  # 手动释放

# RefCounted 派生类（包括 Resource）- 自动管理
var resource := Resource.new()
# 无需手动释放，引用计数为 0 时自动释放

# Node 派生类 - 使用 queue_free()
var node := Node.new()
node.queue_free()  # 安全释放
```

## 节点释放

### queue_free vs free

```gdscript
# ✅ 推荐：queue_free - 安全，帧末释放
node.queue_free()

# ⚠️ 谨慎：free - 立即释放，可能导致问题
node.free()  # 如果其他代码还在引用会出错
```

### 释放时机

```gdscript
# 信号断开
func _exit_tree() -> void:
    # 断开外部信号连接
    if EventBus.enemy_killed.is_connected(_on_enemy_killed):
        EventBus.enemy_killed.disconnect(_on_enemy_killed)

# 清理定时器
func _exit_tree() -> void:
    for timer in _timers:
        timer.stop()
        timer.queue_free()
```

## 检测泄漏

### 对象计数

```gdscript
# 监控对象数量
func _process(_delta: float) -> void:
    if Engine.get_process_frames() % 60 == 0:  # 每秒检查一次
        print("Nodes: ", Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
        print("Objects: ", Performance.get_monitor(Performance.OBJECT_COUNT))
        print("Resources: ", Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
```

### 使用 print_orphan_nodes

```gdscript
# 调试时打印孤儿节点
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        print_orphan_nodes()
```

## 资源管理

### 预加载 vs 动态加载

```gdscript
# preload - 编译时加载，常驻内存
const PLAYER := preload("res://scenes/player.tscn")

# load - 运行时加载，可释放
var enemy_scene := load("res://scenes/enemy.tscn")
# 使用后可以释放
enemy_scene = null
```

### 资源释放

```gdscript
# Resource 是 RefCounted，设为 null 后自动释放
var texture: Texture2D = load("res://texture.png")
texture = null  # 如果没有其他引用，会被释放

# 强制释放（不推荐）
# 可能导致其他引用失效
```

### 资源缓存

```gdscript
class_name ResourceCache
extends RefCounted

var _cache: Dictionary = {}

func get_resource(path: String) -> Resource:
    if not _cache.has(path):
        _cache[path] = load(path)
    return _cache[path]

func clear_cache() -> void:
    _cache.clear()

func remove(path: String) -> void:
    _cache.erase(path)
```

## 信号连接泄漏

### 问题

```gdscript
# ❌ 潜在泄漏：信号保持引用
func _ready() -> void:
    EventBus.game_over.connect(_on_game_over)
    # 如果不断开，EventBus 会保持对此节点的引用
```

### 解决方案

```gdscript
# ✅ 使用 CONNECT_ONE_SHOT
signal.connect(callback, CONNECT_ONE_SHOT)

# ✅ 在 _exit_tree 中断开
func _exit_tree() -> void:
    if EventBus.game_over.is_connected(_on_game_over):
        EventBus.game_over.disconnect(_on_game_over)

# ✅ 使用弱引用（Node 节点自动处理）
# 当节点被释放时，自动断开与它的信号连接
```

## 循环引用

### 问题

```gdscript
# ❌ 循环引用可能阻止释放
class A extends RefCounted:
    var b: B

class B extends RefCounted:
    var a: A

var a := A.new()
var b := B.new()
a.b = b
b.a = a
# a 和 b 相互引用，即使设为 null 也不会释放
```

### 解决方案

```gdscript
# ✅ 使用弱引用
class B extends RefCounted:
    var a_ref: WeakRef

    func set_a(a: A) -> void:
        a_ref = weakref(a)

    func get_a() -> A:
        return a_ref.get_ref() as A
```

## 大型资源处理

### 分块加载

```gdscript
# 异步加载大资源
func load_level_async(path: String) -> void:
    ResourceLoader.load_threaded_request(path)

    while true:
        var status := ResourceLoader.load_threaded_get_status(path)
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            break
        elif status == ResourceLoader.THREAD_LOAD_FAILED:
            push_error("Failed to load: " + path)
            return
        await get_tree().process_frame

    var resource := ResourceLoader.load_threaded_get(path)
```

### 卸载不用的关卡

```gdscript
func change_level(new_level_path: String) -> void:
    # 卸载当前关卡
    current_level.queue_free()
    await current_level.tree_exited

    # 加载新关卡
    var new_level := load(new_level_path).instantiate()
    add_child(new_level)
    current_level = new_level
```

## 内存分析工具

```gdscript
# 打印内存统计
func print_memory_stats() -> void:
    print("=== Memory Stats ===")
    print("Static Memory: %.2f MB" % (Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0))
    print("Object Count: %d" % Performance.get_monitor(Performance.OBJECT_COUNT))
    print("Node Count: %d" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
    print("Resource Count: %d" % Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
```
