# 工厂模式

## 简单工厂

```gdscript
class_name EnemyFactory
extends Node

const ENEMIES := {
    "slime": preload("res://src/enemies/slime.tscn"),
    "skeleton": preload("res://src/enemies/skeleton.tscn"),
    "boss": preload("res://src/enemies/boss.tscn")
}

func create_enemy(enemy_type: String, position: Vector2) -> Enemy:
    if not ENEMIES.has(enemy_type):
        push_error("Unknown enemy type: " + enemy_type)
        return null

    var enemy: Enemy = ENEMIES[enemy_type].instantiate()
    enemy.position = position
    return enemy

# 使用
func spawn_wave() -> void:
    var enemy := EnemyFactory.create_enemy("slime", Vector2(100, 200))
    add_child(enemy)
```

## 带配置的工厂

```gdscript
class_name ProjectileFactory
extends Node

const BULLET := preload("res://src/projectiles/bullet.tscn")
const MISSILE := preload("res://src/projectiles/missile.tscn")
const LASER := preload("res://src/projectiles/laser.tscn")

class ProjectileConfig:
    var scene: PackedScene
    var damage: int
    var speed: float
    var lifetime: float

var _configs: Dictionary = {}

func _ready() -> void:
    _register_projectile("bullet", BULLET, 10, 500.0, 2.0)
    _register_projectile("missile", MISSILE, 50, 200.0, 5.0)
    _register_projectile("laser", LASER, 5, 1000.0, 0.5)

func _register_projectile(id: String, scene: PackedScene, damage: int, speed: float, lifetime: float) -> void:
    var config := ProjectileConfig.new()
    config.scene = scene
    config.damage = damage
    config.speed = speed
    config.lifetime = lifetime
    _configs[id] = config

func create(projectile_id: String, position: Vector2, direction: Vector2) -> Projectile:
    if not _configs.has(projectile_id):
        return null

    var config: ProjectileConfig = _configs[projectile_id]
    var projectile: Projectile = config.scene.instantiate()
    projectile.position = position
    projectile.direction = direction
    projectile.damage = config.damage
    projectile.speed = config.speed
    projectile.setup_lifetime(config.lifetime)

    return projectile
```

## 抽象工厂

```gdscript
# 基类
class_name EntityFactory
extends RefCounted

func create(config: Resource) -> Node:
    push_error("Abstract method called")
    return null

# 玩家工厂
class_name PlayerFactory
extends EntityFactory

const WARRIOR := preload("res://src/characters/warrior.tscn")
const MAGE := preload("res://src/characters/mage.tscn")
const ROGUE := preload("res://src/characters/rogue.tscn")

func create(config: CharacterConfig) -> Player:
    var scene: PackedScene
    match config.class_type:
        "warrior":
            scene = WARRIOR
        "mage":
            scene = MAGE
        "rogue":
            scene = ROGUE
        _:
            return null

    var player: Player = scene.instantiate()
    player.setup(config)
    return player

# 敌人工厂
class_name EnemyFactory
extends EntityFactory

func create(config: EnemyConfig) -> Enemy:
    var scene := load(config.scene_path)
    var enemy: Enemy = scene.instantiate()
    enemy.setup(config)
    return enemy
```

## 工厂注册表

```gdscript
class_name ItemFactory
extends Node

var _factories: Dictionary = {}

func register(item_type: String, factory: Callable) -> void:
    _factories[item_type] = factory

func create(item_type: String, data: Dictionary = {}) -> Item:
    if not _factories.has(item_type):
        push_error("No factory for: " + item_type)
        return null

    return _factories[item_type].call(data)

# 注册
func _ready() -> void:
    register("weapon", _create_weapon)
    register("potion", _create_potion)
    register("armor", _create_armor)

func _create_weapon(data: Dictionary) -> Weapon:
    var weapon := Weapon.new()
    weapon.damage = data.get("damage", 10)
    weapon.attack_speed = data.get("speed", 1.0)
    return weapon

func _create_potion(data: Dictionary) -> Potion:
    var potion := Potion.new()
    potion.heal_amount = data.get("heal", 50)
    return potion
```

## 带对象池的工厂

```gdscript
class_name PooledFactory
extends Node

var _scene: PackedScene
var _pool: Array[Node] = []
var _active: Array[Node] = []
var _initial_size: int

func _init(scene: PackedScene, initial_size: int = 10) -> void:
    _scene = scene
    _initial_size = initial_size

func _ready() -> void:
    _warm_pool()

func _warm_pool() -> void:
    for i in _initial_size:
        var instance := _scene.instantiate()
        instance.set_process(false)
        instance.visible = false
        _pool.append(instance)
        add_child(instance)

func acquire() -> Node:
    var instance: Node
    if _pool.size() > 0:
        instance = _pool.pop_back()
    else:
        instance = _scene.instantiate()
        add_child(instance)

    instance.set_process(true)
    instance.visible = true
    _active.append(instance)
    return instance

func release(instance: Node) -> void:
    if instance in _active:
        _active.erase(instance)
        instance.set_process(false)
        instance.visible = false
        _pool.append(instance)
```

## 使用示例

```gdscript
# Spawner 使用工厂
class_name EnemySpawner
extends Node2D

@export var enemy_factory: EnemyFactory
@export var spawn_interval: float = 2.0

var _timer: Timer

func _ready() -> void:
    _timer = Timer.new()
    _timer.wait_time = spawn_interval
    _timer.timeout.connect(_on_spawn)
    add_child(_timer)
    _timer.start()

func _on_spawn() -> void:
    var enemy_type := ["slime", "skeleton"].pick_random()
    var enemy := enemy_factory.create_enemy(enemy_type, global_position)
    get_parent().add_child(enemy)
```
