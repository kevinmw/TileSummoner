# RigidBody3D 刚体物理

## 基础设置

```gdscript
extends RigidBody3D

func _ready() -> void:
    # 基本属性
    mass = 1.0
    gravity_scale = 1.0
    linear_damp = 0.0
    angular_damp = 0.0

    # 物理材质
    physics_material_override = PhysicsMaterial.new()
    physics_material_override.bounce = 0.5
    physics_material_override.friction = 0.8
```

## 施加力和冲量

```gdscript
extends RigidBody3D

# 施加持续力（在 _physics_process 中调用）
func apply_movement_force(direction: Vector3, force: float) -> void:
    apply_central_force(direction * force)

# 施加瞬时冲量
func apply_impulse_at_center(impulse: Vector3) -> void:
    apply_central_impulse(impulse)

# 在特定位置施加冲量（会产生旋转）
func apply_impulse_at_position(impulse: Vector3, position: Vector3) -> void:
    apply_impulse(impulse, position - global_position)

# 施加扭矩
func apply_spin(torque: Vector3) -> void:
    apply_torque(torque)
```

## 可推动物体

```gdscript
extends RigidBody3D

@export var push_force: float = 10.0

func _on_body_entered(body: Node3D) -> void:
    if body is CharacterBody3D:
        # 计算推力方向
        var push_dir := (global_position - body.global_position).normalized()
        push_dir.y = 0
        apply_central_impulse(push_dir * push_force)
```

## 爆炸效果

```gdscript
func explode(origin: Vector3, force: float, radius: float) -> void:
    var bodies := get_tree().get_nodes_in_group("physics_objects")

    for body in bodies:
        if body is RigidBody3D:
            var distance := body.global_position.distance_to(origin)
            if distance < radius:
                var direction := (body.global_position - origin).normalized()
                var strength := (1.0 - distance / radius) * force
                body.apply_central_impulse(direction * strength)
```

## 可拾取物体

```gdscript
extends RigidBody3D

var is_held: bool = false
var holder: Node3D = null

func pick_up(by: Node3D) -> void:
    is_held = true
    holder = by
    freeze = true  # 禁用物理
    collision_layer = 0

func drop(throw_velocity: Vector3 = Vector3.ZERO) -> void:
    is_held = false
    holder = null
    freeze = false
    collision_layer = 1
    linear_velocity = throw_velocity

func _physics_process(_delta: float) -> void:
    if is_held and holder:
        global_position = holder.global_position + holder.global_transform.basis.z * -2
```

## 冻结模式

```gdscript
# 完全冻结
freeze = true
freeze_mode = FREEZE_MODE_STATIC  # 变成静态物体

# 只冻结运动学
freeze_mode = FREEZE_MODE_KINEMATIC  # 可移动但不受物理影响
```

## 碰撞检测

```gdscript
extends RigidBody3D

func _ready() -> void:
    # 启用接触监控
    contact_monitor = true
    max_contacts_reported = 4

    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    # 检测碰撞强度
    var collision_velocity := linear_velocity.length()
    if collision_velocity > 10.0:
        # 高速碰撞
        emit_particles()
        play_impact_sound()
```

## 常见场景结构

```
PhysicsObject (RigidBody3D)
├── MeshInstance3D
├── CollisionShape3D
└── AudioStreamPlayer3D (碰撞音效)

Crate (RigidBody3D)
├── MeshInstance3D
├── CollisionShape3D (BoxShape3D)
└── BreakParticles (GPUParticles3D)
```

## 模式选择

| 模式 | 用途 |
|------|------|
| RigidBody3D (Dynamic) | 完全物理模拟 |
| RigidBody3D (Kinematic) | 代码控制移动，有物理响应 |
| StaticBody3D | 不移动的物体 |
| CharacterBody3D | 角色控制 |

## 性能优化

```gdscript
# 休眠设置
can_sleep = true
sleeping = false  # 开始时唤醒

# 连续碰撞检测（快速移动物体）
continuous_cd = true

# 简化形状
# 使用简单的 BoxShape3D/SphereShape3D 而非 ConvexPolygonShape3D
```
