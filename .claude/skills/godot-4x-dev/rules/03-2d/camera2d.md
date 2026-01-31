# Camera2D 相机系统

## 基础设置

```gdscript
extends Camera2D

func _ready() -> void:
    # 设为当前相机
    make_current()

    # 基本属性
    zoom = Vector2(2, 2)  # 2x 放大
    offset = Vector2(0, -50)  # 偏移

    # 平滑跟随
    position_smoothing_enabled = true
    position_smoothing_speed = 5.0
```

## 跟随玩家

```gdscript
# 作为玩家子节点（最简单）
# Player (CharacterBody2D)
# └── Camera2D

# 或独立相机跟随
extends Camera2D

@export var target: Node2D
@export var follow_speed: float = 5.0

func _process(delta: float) -> void:
    if target:
        global_position = global_position.lerp(target.global_position, follow_speed * delta)
```

## 相机边界

```gdscript
extends Camera2D

func _ready() -> void:
    # 设置边界限制
    limit_left = 0
    limit_top = 0
    limit_right = 1920
    limit_bottom = 1080

    # 边界平滑
    limit_smoothed = true

# 从 TileMap 计算边界
func set_limits_from_tilemap(tilemap: TileMapLayer) -> void:
    var used_rect := tilemap.get_used_rect()
    var tile_size := tilemap.tile_set.tile_size

    limit_left = used_rect.position.x * tile_size.x
    limit_top = used_rect.position.y * tile_size.y
    limit_right = used_rect.end.x * tile_size.x
    limit_bottom = used_rect.end.y * tile_size.y
```

## 相机震动

```gdscript
extends Camera2D

var _shake_intensity: float = 0.0
var _shake_decay: float = 5.0

func _process(delta: float) -> void:
    if _shake_intensity > 0:
        offset = Vector2(
            randf_range(-_shake_intensity, _shake_intensity),
            randf_range(-_shake_intensity, _shake_intensity)
        )
        _shake_intensity = lerp(_shake_intensity, 0.0, _shake_decay * delta)
    else:
        offset = Vector2.ZERO

func shake(intensity: float = 10.0, decay: float = 5.0) -> void:
    _shake_intensity = intensity
    _shake_decay = decay
```

## 相机缩放

```gdscript
extends Camera2D

@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var zoom_speed: float = 0.1

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            zoom_camera(zoom_speed)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            zoom_camera(-zoom_speed)

func zoom_camera(amount: float) -> void:
    var new_zoom := clamp(zoom.x + amount, min_zoom, max_zoom)
    zoom = Vector2(new_zoom, new_zoom)
```

## 平滑过渡

```gdscript
extends Camera2D

func transition_to(target_pos: Vector2, duration: float = 1.0) -> void:
    var tween := create_tween()
    tween.tween_property(self, "global_position", target_pos, duration)\
        .set_trans(Tween.TRANS_SINE)\
        .set_ease(Tween.EASE_IN_OUT)
    await tween.finished

func transition_zoom(target_zoom: Vector2, duration: float = 0.5) -> void:
    var tween := create_tween()
    tween.tween_property(self, "zoom", target_zoom, duration)\
        .set_trans(Tween.TRANS_SINE)
    await tween.finished
```

## 视差背景

```gdscript
# 使用 ParallaxBackground
# ParallaxBackground
# └── ParallaxLayer
#     └── Sprite2D

# ParallaxLayer 设置
# motion_scale = Vector2(0.5, 0.5)  # 移动速度倍率
# motion_mirroring = Vector2(1920, 0)  # 无限循环
```

## 多相机切换

```gdscript
var cameras: Array[Camera2D] = []
var current_index: int = 0

func _ready() -> void:
    cameras = [
        $Camera2D_Main,
        $Camera2D_Cinematic,
        $Camera2D_Overview
    ]

func switch_camera(index: int) -> void:
    if index >= 0 and index < cameras.size():
        cameras[current_index].enabled = false
        current_index = index
        cameras[current_index].make_current()

func switch_to_camera(camera: Camera2D) -> void:
    camera.make_current()
```

## 前瞻（Look Ahead）

```gdscript
extends Camera2D

@export var look_ahead_factor: float = 50.0
var _target_offset: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
    if target:
        # 根据移动方向调整偏移
        var velocity: Vector2 = target.velocity if target.has_method("get_velocity") else Vector2.ZERO
        _target_offset = velocity.normalized() * look_ahead_factor
        offset = offset.lerp(_target_offset, 3.0 * delta)
```
