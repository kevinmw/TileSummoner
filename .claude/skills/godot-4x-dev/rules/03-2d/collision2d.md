# 2D 碰撞系统

## 碰撞体类型

| 类型 | 用途 |
|------|------|
| CharacterBody2D | 角色控制（玩家、敌人） |
| RigidBody2D | 物理模拟（箱子、球） |
| StaticBody2D | 静态障碍（墙壁、地面） |
| Area2D | 检测区域（触发器、拾取物） |

## CollisionShape2D 形状

```gdscript
# 常用形状
$CollisionShape2D.shape = RectangleShape2D.new()
$CollisionShape2D.shape = CircleShape2D.new()
$CollisionShape2D.shape = CapsuleShape2D.new()
$CollisionShape2D.shape = ConvexPolygonShape2D.new()

# 代码设置形状大小
var rect := RectangleShape2D.new()
rect.size = Vector2(32, 64)
$CollisionShape2D.shape = rect

var circle := CircleShape2D.new()
circle.radius = 16.0
$CollisionShape2D.shape = circle
```

## 碰撞层与掩码

```
Layer: 物体所在的层（"我是什么"）
Mask: 物体检测的层（"我与什么碰撞"）

推荐层级设置:
Layer 1: Player
Layer 2: Enemies
Layer 3: PlayerProjectiles
Layer 4: EnemyProjectiles
Layer 5: Pickups
Layer 6: Environment
```

```gdscript
# 代码设置碰撞层
collision_layer = 1      # 二进制: 0001
collision_mask = 2 | 4   # 二进制: 0110

# 使用位运算
func set_collision_layer_value(layer: int, value: bool) -> void:
    set_collision_layer_value(layer, value)

func set_collision_mask_value(layer: int, value: bool) -> void:
    set_collision_mask_value(layer, value)
```

## Area2D 检测

```gdscript
extends Area2D

signal body_detected(body: Node2D)

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        body_detected.emit(body)

func _on_body_exited(body: Node2D) -> void:
    pass

func _on_area_entered(area: Area2D) -> void:
    if area.is_in_group("hitbox"):
        take_damage(area.damage)
```

## Hitbox/Hurtbox 模式

```gdscript
# Hitbox - 造成伤害的区域
extends Area2D
class_name Hitbox

@export var damage: int = 10

func _ready() -> void:
    # Hitbox 在 Layer 3，检测 Layer 2 (Hurtbox)
    collision_layer = 4  # 0100
    collision_mask = 8   # 1000

# Hurtbox - 接受伤害的区域
extends Area2D
class_name Hurtbox

signal hurt(damage: int, hitbox: Hitbox)

func _ready() -> void:
    # Hurtbox 在 Layer 4，被 Layer 3 (Hitbox) 检测
    collision_layer = 8  # 1000
    collision_mask = 0   # 不主动检测

    area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: Area2D) -> void:
    if hitbox is Hitbox:
        hurt.emit(hitbox.damage, hitbox)
```

## 场景结构

```
Player (CharacterBody2D)
├── CollisionShape2D      # 物理碰撞
├── Hurtbox (Area2D)      # 受伤判定
│   └── CollisionShape2D
├── Hitbox (Area2D)       # 攻击判定（可禁用）
│   └── CollisionShape2D
└── PickupArea (Area2D)   # 拾取范围
    └── CollisionShape2D
```

## 射线检测

```gdscript
# 使用 RayCast2D 节点
@onready var raycast: RayCast2D = $RayCast2D

func check_ground() -> bool:
    return raycast.is_colliding()

func get_ground_point() -> Vector2:
    return raycast.get_collision_point()

# 代码射线
func raycast_check(from: Vector2, to: Vector2) -> Dictionary:
    var space := get_world_2d().direct_space_state
    var query := PhysicsRayQueryParameters2D.create(from, to)
    query.collision_mask = 1  # 检测层
    query.exclude = [self]    # 排除自身
    return space.intersect_ray(query)

# 使用结果
var result := raycast_check(global_position, global_position + Vector2.DOWN * 100)
if result:
    var hit_point: Vector2 = result.position
    var hit_normal: Vector2 = result.normal
    var hit_object: Object = result.collider
```

## 形状查询

```gdscript
# 检测某区域内的所有物体
func get_bodies_in_area(center: Vector2, radius: float) -> Array:
    var space := get_world_2d().direct_space_state
    var shape := CircleShape2D.new()
    shape.radius = radius

    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = Transform2D(0, center)
    query.collision_mask = collision_mask

    return space.intersect_shape(query)
```
