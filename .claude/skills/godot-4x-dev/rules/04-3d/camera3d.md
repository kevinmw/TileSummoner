# Camera3D 相机系统

## 基础设置

```gdscript
extends Camera3D

func _ready() -> void:
    # 设为当前相机
    make_current()

    # 基本属性
    fov = 75.0  # 视野角度
    near = 0.1  # 近裁剪面
    far = 1000.0  # 远裁剪面

    # 投影类型
    projection = PROJECTION_PERSPECTIVE  # 或 PROJECTION_ORTHOGONAL
```

## 第一人称相机

```gdscript
extends Node3D  # 作为 Head 节点

@export var mouse_sensitivity: float = 0.002
@export var max_vertical_angle: float = 89.0

var _rotation_x: float = 0.0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        # 水平旋转（旋转父节点 - 角色）
        get_parent().rotate_y(-event.relative.x * mouse_sensitivity)

        # 垂直旋转（旋转自身 - 头部）
        _rotation_x -= event.relative.y * mouse_sensitivity
        _rotation_x = clamp(_rotation_x, deg_to_rad(-max_vertical_angle), deg_to_rad(max_vertical_angle))
        rotation.x = _rotation_x
```

## 第三人称相机（SpringArm3D）

```gdscript
# 场景结构:
# Player
# └── CameraPivot (Node3D)
#     └── SpringArm3D
#         └── Camera3D

extends Node3D  # CameraPivot

@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -60.0
@export var max_pitch: float = 60.0

@onready var spring_arm: SpringArm3D = $SpringArm3D

var _yaw: float = 0.0
var _pitch: float = 0.0

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    spring_arm.spring_length = 5.0
    spring_arm.collision_mask = 1  # 碰撞层

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        _yaw -= event.relative.x * mouse_sensitivity
        _pitch -= event.relative.y * mouse_sensitivity
        _pitch = clamp(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _process(_delta: float) -> void:
    rotation = Vector3(_pitch, _yaw, 0)
```

## 轨道相机

```gdscript
extends Node3D

@export var target: Node3D
@export var distance: float = 10.0
@export var rotation_speed: float = 0.01
@export var zoom_speed: float = 0.5
@export var min_distance: float = 2.0
@export var max_distance: float = 20.0

@onready var camera: Camera3D = $Camera3D

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
        rotate_y(-event.relative.x * rotation_speed)
        rotate_object_local(Vector3.RIGHT, -event.relative.y * rotation_speed)

    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            distance = max(distance - zoom_speed, min_distance)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            distance = min(distance + zoom_speed, max_distance)

func _process(_delta: float) -> void:
    if target:
        global_position = target.global_position
    camera.position.z = distance
```

## 相机震动

```gdscript
extends Camera3D

var _trauma: float = 0.0
var _max_offset: Vector3 = Vector3(0.5, 0.5, 0.0)
var _max_rotation: Vector3 = Vector3(5.0, 5.0, 2.0)
var _noise := FastNoiseLite.new()
var _noise_y: float = 0.0

func _ready() -> void:
    _noise.seed = randi()
    _noise.frequency = 2.0

func _process(delta: float) -> void:
    _trauma = max(_trauma - delta, 0.0)

    if _trauma > 0:
        _noise_y += delta * 30
        var shake := _trauma * _trauma  # 二次衰减

        h_offset = _max_offset.x * shake * _noise.get_noise_2d(_noise_y, 0)
        v_offset = _max_offset.y * shake * _noise.get_noise_2d(0, _noise_y)

        rotation_degrees.x = _max_rotation.x * shake * _noise.get_noise_2d(_noise_y, 100)
        rotation_degrees.y = _max_rotation.y * shake * _noise.get_noise_2d(100, _noise_y)
        rotation_degrees.z = _max_rotation.z * shake * _noise.get_noise_2d(_noise_y, 200)
    else:
        h_offset = 0
        v_offset = 0
        rotation_degrees = Vector3.ZERO

func add_trauma(amount: float) -> void:
    _trauma = min(_trauma + amount, 1.0)
```

## 相机切换

```gdscript
var cameras: Array[Camera3D] = []

func switch_to_camera(camera: Camera3D, smooth: bool = true) -> void:
    if smooth:
        var tween := create_tween()
        # 平滑过渡位置和旋转
        tween.parallel().tween_property(camera, "global_position", camera.global_position, 0.5)
        await tween.finished

    camera.make_current()
```

## 环境与后处理

```gdscript
extends Camera3D

@onready var environment: Environment = $WorldEnvironment.environment

func _ready() -> void:
    # 色调映射
    environment.tonemap_mode = Environment.TONE_MAPPER_ACES

    # 辉光
    environment.glow_enabled = true
    environment.glow_intensity = 0.5

    # 景深
    attributes.dof_blur_far_enabled = true
    attributes.dof_blur_far_distance = 20.0
```
