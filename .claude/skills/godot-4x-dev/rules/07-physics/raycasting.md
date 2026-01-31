# 射线检测

## RayCast2D 节点

```gdscript
@onready var raycast: RayCast2D = $RayCast2D

func _ready() -> void:
    raycast.enabled = true
    raycast.target_position = Vector2(0, 100)  # 向下 100 像素
    raycast.collision_mask = 1  # 检测 Layer 1

func _physics_process(_delta: float) -> void:
    if raycast.is_colliding():
        var collider := raycast.get_collider()
        var point := raycast.get_collision_point()
        var normal := raycast.get_collision_normal()
```

## RayCast3D 节点

```gdscript
@onready var raycast: RayCast3D = $RayCast3D

func _ready() -> void:
    raycast.target_position = Vector3(0, 0, -10)  # 向前 10 单位
    raycast.collision_mask = 0b111  # Layers 1-3

func check_forward() -> Node3D:
    if raycast.is_colliding():
        return raycast.get_collider()
    return null
```

## 代码射线（2D）

```gdscript
func raycast_2d(from: Vector2, to: Vector2, mask: int = 1) -> Dictionary:
    var space := get_world_2d().direct_space_state
    var query := PhysicsRayQueryParameters2D.create(from, to)
    query.collision_mask = mask
    query.exclude = [self]  # 排除自身
    return space.intersect_ray(query)

# 使用
func check_ground() -> bool:
    var result := raycast_2d(
        global_position,
        global_position + Vector2.DOWN * 50
    )
    return not result.is_empty()
```

## 代码射线（3D）

```gdscript
func raycast_3d(from: Vector3, to: Vector3, mask: int = 1) -> Dictionary:
    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.collision_mask = mask
    query.exclude = [self]
    return space.intersect_ray(query)

# 从相机投射
func raycast_from_camera() -> Dictionary:
    var camera := get_viewport().get_camera_3d()
    var mouse_pos := get_viewport().get_mouse_position()

    var from := camera.project_ray_origin(mouse_pos)
    var direction := camera.project_ray_normal(mouse_pos)
    var to := from + direction * 1000

    return raycast_3d(from, to)
```

## 射线结果字典

```gdscript
# 射线命中时返回的字典
{
    "position": Vector2/Vector3,  # 碰撞点
    "normal": Vector2/Vector3,    # 碰撞法线
    "collider": Object,           # 碰撞对象
    "collider_id": int,           # 碰撞对象 ID
    "rid": RID,                   # 碰撞形状 RID
    "shape": int                  # 碰撞形状索引
}

# 未命中返回空字典 {}
```

## 常见用途

### 地面检测

```gdscript
func is_on_ground() -> bool:
    var result := raycast_2d(
        global_position,
        global_position + Vector2.DOWN * 16,
        GROUND_LAYER
    )
    return not result.is_empty()
```

### 视线检测

```gdscript
func can_see_target(target: Node2D) -> bool:
    var result := raycast_2d(
        global_position,
        target.global_position,
        OBSTACLE_LAYER
    )
    # 如果没有障碍物阻挡，可以看到目标
    return result.is_empty()
```

### 墙壁检测

```gdscript
func is_facing_wall(direction: Vector2) -> bool:
    var result := raycast_2d(
        global_position,
        global_position + direction * 32,
        WALL_LAYER
    )
    return not result.is_empty()
```

### 鼠标交互

```gdscript
func get_object_under_mouse() -> Node2D:
    var mouse_pos := get_global_mouse_position()
    var result := raycast_2d(
        mouse_pos - Vector2(0, 1),
        mouse_pos + Vector2(0, 1),
        INTERACTABLE_LAYER
    )
    if result:
        return result.collider
    return null
```

## 多射线

```gdscript
# 扇形射线
func fan_raycast(origin: Vector2, direction: Vector2, count: int, spread: float) -> Array:
    var results := []
    var angle_step := spread / (count - 1)
    var start_angle := direction.angle() - spread / 2

    for i in count:
        var angle := start_angle + angle_step * i
        var end := origin + Vector2.from_angle(angle) * 100
        var result := raycast_2d(origin, end)
        if result:
            results.append(result)

    return results
```

## RayCast 属性

```gdscript
# 2D
raycast.enabled = true
raycast.target_position = Vector2(0, 100)
raycast.collision_mask = 1
raycast.exclude_parent = true
raycast.collide_with_areas = false
raycast.collide_with_bodies = true
raycast.hit_from_inside = false

# 3D
raycast.debug_shape_custom_color = Color.RED
raycast.debug_shape_thickness = 2
```

## ShapeCast（形状投射）

```gdscript
# 比射线检测更多碰撞
@onready var shape_cast: ShapeCast2D = $ShapeCast2D

func get_all_hits() -> Array:
    var hits := []
    for i in shape_cast.get_collision_count():
        hits.append({
            "collider": shape_cast.get_collider(i),
            "point": shape_cast.get_collision_point(i),
            "normal": shape_cast.get_collision_normal(i)
        })
    return hits
```
