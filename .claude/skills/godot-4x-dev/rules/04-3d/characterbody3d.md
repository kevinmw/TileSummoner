# CharacterBody3D 角色控制器

## 基础移动

```gdscript
extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
const GRAVITY: float = 9.8

func _physics_process(delta: float) -> void:
    # 重力
    if not is_on_floor():
        velocity.y -= GRAVITY * delta

    # 跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # 获取输入方向
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()
```

## 第一人称控制器

```gdscript
extends CharacterBody3D

@export_group("Movement")
@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8

@export_group("Camera")
@export var mouse_sensitivity: float = 0.002
@export var max_look_angle: float = 89.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        # 水平旋转 - 旋转整个角色
        rotate_y(-event.relative.x * mouse_sensitivity)
        # 垂直旋转 - 只旋转头部
        head.rotate_x(-event.relative.y * mouse_sensitivity)
        head.rotation.x = clamp(head.rotation.x, deg_to_rad(-max_look_angle), deg_to_rad(max_look_angle))

    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    # 重力
    if not is_on_floor():
        velocity.y -= gravity * delta

    # 跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_force

    # 移动
    var speed := sprint_speed if Input.is_action_pressed("sprint") else move_speed
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed)
        velocity.z = move_toward(velocity.z, 0, speed)

    move_and_slide()
```

## 第三人称控制器

```gdscript
extends CharacterBody3D

@export var move_speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var gravity: float = 9.8

@onready var camera_pivot: Node3D = $CameraPivot
@onready var model: Node3D = $Model

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = 4.5

    # 相对于相机方向移动
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

    if input_dir.length() > 0:
        # 获取相机朝向（忽略 Y 轴）
        var cam_forward := -camera_pivot.global_transform.basis.z
        cam_forward.y = 0
        cam_forward = cam_forward.normalized()

        var cam_right := camera_pivot.global_transform.basis.x
        cam_right.y = 0
        cam_right = cam_right.normalized()

        # 计算移动方向
        var direction := (cam_forward * -input_dir.y + cam_right * input_dir.x).normalized()

        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed

        # 旋转模型朝向移动方向
        var target_rotation := atan2(direction.x, direction.z)
        model.rotation.y = lerp_angle(model.rotation.y, target_rotation, rotation_speed * delta)
    else:
        velocity.x = move_toward(velocity.x, 0, move_speed)
        velocity.z = move_toward(velocity.z, 0, move_speed)

    move_and_slide()
```

## 场景结构

### 第一人称
```
Player (CharacterBody3D)
├── CollisionShape3D (CapsuleShape3D)
├── Head (Node3D)
│   └── Camera3D
└── MeshInstance3D (可选 - 调试用)
```

### 第三人称
```
Player (CharacterBody3D)
├── CollisionShape3D
├── Model (Node3D)
│   └── MeshInstance3D / 骨骼模型
├── CameraPivot (Node3D)
│   └── SpringArm3D
│       └── Camera3D
└── AnimationPlayer
```

## 常用属性

```gdscript
# CharacterBody3D 属性
motion_mode = MOTION_MODE_GROUNDED
up_direction = Vector3.UP
floor_stop_on_slope = true
floor_max_angle = deg_to_rad(45)
floor_snap_length = 0.1

# 检测函数
is_on_floor()
is_on_wall()
is_on_ceiling()
get_floor_normal()
get_wall_normal()
get_slide_collision_count()
get_slide_collision(index)
```
