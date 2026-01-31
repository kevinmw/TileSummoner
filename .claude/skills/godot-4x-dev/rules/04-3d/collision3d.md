# 3D 碰撞系统

## 碰撞形状

```gdscript
# 常用形状
BoxShape3D        # 盒子
SphereShape3D     # 球体
CapsuleShape3D    # 胶囊（角色常用）
CylinderShape3D   # 圆柱
ConvexPolygonShape3D  # 凸多边形
ConcavePolygonShape3D # 凹多边形（仅静态）

# 代码创建
var capsule := CapsuleShape3D.new()
capsule.radius = 0.5
capsule.height = 2.0
$CollisionShape3D.shape = capsule
```

## 碰撞层设置

```
推荐层级:
Layer 1: Player
Layer 2: Enemies
Layer 3: Environment (墙壁、地面)
Layer 4: Projectiles
Layer 5: Pickups
Layer 6: Interactables
Layer 7: Triggers
```

```gdscript
# 设置碰撞层
collision_layer = 1 << 0  # Layer 1
collision_mask = (1 << 2) | (1 << 5)  # Layer 3 和 Layer 6

# 使用函数
set_collision_layer_value(1, true)
set_collision_mask_value(3, true)
```

## Area3D 检测

```gdscript
extends Area3D

signal player_entered
signal player_exited

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("player"):
        player_entered.emit()

func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("player"):
        player_exited.emit()
```

## 射线检测

```gdscript
# 使用 RayCast3D 节点
@onready var raycast: RayCast3D = $RayCast3D

func check_forward() -> Dictionary:
    if raycast.is_colliding():
        return {
            "collider": raycast.get_collider(),
            "point": raycast.get_collision_point(),
            "normal": raycast.get_collision_normal()
        }
    return {}

# 代码射线
func raycast_from_camera() -> Dictionary:
    var camera := get_viewport().get_camera_3d()
    var mouse_pos := get_viewport().get_mouse_position()

    var from := camera.project_ray_origin(mouse_pos)
    var to := from + camera.project_ray_normal(mouse_pos) * 1000

    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collision_mask = 0b111  # Layers 1-3
    query.exclude = [self]

    return space.intersect_ray(query)
```

## 形状投射

```gdscript
# ShapeCast3D - 检测路径上的所有碰撞
@onready var shape_cast: ShapeCast3D = $ShapeCast3D

func check_sweep() -> Array:
    var results := []
    for i in shape_cast.get_collision_count():
        results.append({
            "collider": shape_cast.get_collider(i),
            "point": shape_cast.get_collision_point(i),
            "normal": shape_cast.get_collision_normal(i)
        })
    return results
```

## Hitbox/Hurtbox 3D

```gdscript
# Hitbox3D
extends Area3D
class_name Hitbox3D

@export var damage: int = 10
@export var knockback_force: float = 5.0

func get_knockback_direction(target_pos: Vector3) -> Vector3:
    return (target_pos - global_position).normalized()

# Hurtbox3D
extends Area3D
class_name Hurtbox3D

signal hit_received(damage: int, knockback: Vector3)

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
    if area is Hitbox3D:
        var knockback := area.get_knockback_direction(global_position) * area.knockback_force
        hit_received.emit(area.damage, knockback)
```

## 地面检测

```gdscript
extends CharacterBody3D

@onready var ground_ray: RayCast3D = $GroundRay

func get_floor_info() -> Dictionary:
    if ground_ray.is_colliding():
        return {
            "normal": ground_ray.get_collision_normal(),
            "point": ground_ray.get_collision_point(),
            "collider": ground_ray.get_collider()
        }
    return {}

func is_on_slope() -> bool:
    var info := get_floor_info()
    if info.is_empty():
        return false
    return info.normal.angle_to(Vector3.UP) > deg_to_rad(5)
```

## 常见场景结构

```
Player (CharacterBody3D)
├── CollisionShape3D (CapsuleShape3D)
├── Hurtbox (Area3D)
│   └── CollisionShape3D
├── MeleeHitbox (Area3D)
│   └── CollisionShape3D
├── GroundRay (RayCast3D)
├── InteractionRay (RayCast3D)
└── Model (Node3D)
    └── MeshInstance3D
```

## 性能优化

1. 使用简单形状（Box, Sphere, Capsule）
2. 避免 ConcavePolygonShape3D 用于动态物体
3. 合理设置碰撞层，减少不必要的检测
4. 远距离物体可以禁用碰撞 `collision_layer = 0`
