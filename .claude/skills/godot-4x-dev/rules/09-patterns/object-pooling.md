# 对象池模式

## 为什么使用对象池

- 避免频繁的 `instantiate()` 和 `queue_free()`
- 减少内存分配和垃圾回收
- 适用于频繁创建/销毁的对象（子弹、粒子、敌人等）

## 基础对象池

```gdscript
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var initial_size: int = 20
@export var max_size: int = 100

var _available: Array[Node] = []
var _in_use: Array[Node] = []

func _ready() -> void:
    _warm_up()

func _warm_up() -> void:
    for i in initial_size:
        _create_instance()

func _create_instance() -> Node:
    var instance := scene.instantiate()
    instance.set_process(false)
    instance.set_physics_process(false)
    instance.visible = false
    add_child(instance)
    _available.append(instance)
    return instance

func acquire() -> Node:
    var instance: Node

    if _available.size() > 0:
        instance = _available.pop_back()
    elif _in_use.size() < max_size:
        instance = _create_instance()
        _available.erase(instance)
    else:
        # 池已满，复用最旧的对象
        instance = _in_use.pop_front()

    _activate(instance)
    _in_use.append(instance)
    return instance

func release(instance: Node) -> void:
    if instance not in _in_use:
        return

    _deactivate(instance)
    _in_use.erase(instance)
    _available.append(instance)

func _activate(instance: Node) -> void:
    instance.set_process(true)
    instance.set_physics_process(true)
    instance.visible = true

    if instance.has_method("on_pool_acquire"):
        instance.on_pool_acquire()

func _deactivate(instance: Node) -> void:
    instance.set_process(false)
    instance.set_physics_process(false)
    instance.visible = false

    if instance.has_method("on_pool_release"):
        instance.on_pool_release()
```

## 可池化对象接口

```gdscript
class_name Bullet
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 500.0
var damage: int = 10
var _pool: ObjectPool

func setup(pool: ObjectPool) -> void:
    _pool = pool

func on_pool_acquire() -> void:
    # 重置状态
    direction = Vector2.RIGHT
    speed = 500.0
    damage = 10

func on_pool_release() -> void:
    # 清理状态
    pass

func _physics_process(delta: float) -> void:
    position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
    return_to_pool()

func _on_lifetime_timeout() -> void:
    return_to_pool()

func return_to_pool() -> void:
    if _pool:
        _pool.release(self)
```

## 类型化对象池

```gdscript
class_name BulletPool
extends ObjectPool

func acquire_bullet(pos: Vector2, dir: Vector2, dmg: int = 10) -> Bullet:
    var bullet := acquire() as Bullet
    bullet.global_position = pos
    bullet.direction = dir.normalized()
    bullet.damage = dmg
    bullet.setup(self)
    return bullet
```

## 多类型对象池管理器

```gdscript
class_name PoolManager
extends Node

var _pools: Dictionary = {}

func register_pool(pool_name: String, scene: PackedScene, initial: int = 10) -> ObjectPool:
    if _pools.has(pool_name):
        return _pools[pool_name]

    var pool := ObjectPool.new()
    pool.scene = scene
    pool.initial_size = initial
    pool.name = pool_name + "Pool"
    add_child(pool)
    _pools[pool_name] = pool
    return pool

func get_pool(pool_name: String) -> ObjectPool:
    return _pools.get(pool_name)

func acquire_from(pool_name: String) -> Node:
    var pool := get_pool(pool_name)
    if pool:
        return pool.acquire()
    return null

func release_to(pool_name: String, instance: Node) -> void:
    var pool := get_pool(pool_name)
    if pool:
        pool.release(instance)
```

## 使用示例

```gdscript
# 武器使用子弹池
class_name Weapon
extends Node2D

@export var bullet_scene: PackedScene
var _bullet_pool: BulletPool

func _ready() -> void:
    _bullet_pool = BulletPool.new()
    _bullet_pool.scene = bullet_scene
    _bullet_pool.initial_size = 30
    add_child(_bullet_pool)

func fire(direction: Vector2) -> void:
    var bullet := _bullet_pool.acquire_bullet(
        global_position,
        direction,
        damage
    )
```

## 自动回收

```gdscript
class_name AutoReleasePool
extends ObjectPool

@export var auto_release_time: float = 5.0

func acquire() -> Node:
    var instance := super.acquire()

    # 自动回收计时器
    var timer := instance.get_node_or_null("AutoReleaseTimer") as Timer
    if not timer:
        timer = Timer.new()
        timer.name = "AutoReleaseTimer"
        timer.one_shot = true
        instance.add_child(timer)

    timer.wait_time = auto_release_time
    timer.timeout.connect(func(): release(instance), CONNECT_ONE_SHOT)
    timer.start()

    return instance
```

## 性能监控

```gdscript
func get_stats() -> Dictionary:
    return {
        "available": _available.size(),
        "in_use": _in_use.size(),
        "total": _available.size() + _in_use.size(),
        "max": max_size
    }

func print_stats() -> void:
    var stats := get_stats()
    print("Pool [%s]: %d/%d (available: %d)" % [
        name,
        stats.in_use,
        stats.total,
        stats.available
    ])
```
