# Tween 补间动画

## 基础使用

```gdscript
func fade_in() -> void:
    var tween := create_tween()
    tween.tween_property(self, "modulate:a", 1.0, 0.5)

func move_to(target: Vector2) -> void:
    var tween := create_tween()
    tween.tween_property(self, "position", target, 1.0)
```

## Tween 方法

```gdscript
var tween := create_tween()

# 属性动画
tween.tween_property(node, "property", end_value, duration)

# 方法调用
tween.tween_callback(func(): print("done"))

# 等待
tween.tween_interval(1.0)  # 等待 1 秒

# 方法插值
tween.tween_method(update_progress, 0.0, 1.0, 2.0)

func update_progress(value: float) -> void:
    progress_bar.value = value * 100
```

## 串联动画

```gdscript
func animate_ui() -> void:
    var tween := create_tween()

    # 顺序执行
    tween.tween_property($Panel, "modulate:a", 1.0, 0.3)
    tween.tween_property($Label, "modulate:a", 1.0, 0.3)
    tween.tween_callback(enable_input)

    # 等待完成
    await tween.finished
    print("Animation complete!")
```

## 并行动画

```gdscript
func animate_parallel() -> void:
    var tween := create_tween()

    # parallel() 使后续动画同时开始
    tween.parallel().tween_property($Sprite, "position", Vector2(100, 0), 0.5)
    tween.parallel().tween_property($Sprite, "rotation", PI, 0.5)
    tween.parallel().tween_property($Sprite, "scale", Vector2(2, 2), 0.5)

# 或使用 set_parallel
func animate_all_parallel() -> void:
    var tween := create_tween()
    tween.set_parallel(true)

    tween.tween_property($A, "position", Vector2.ZERO, 1.0)
    tween.tween_property($B, "position", Vector2.ZERO, 1.0)
    tween.tween_property($C, "position", Vector2.ZERO, 1.0)
```

## 缓动函数

```gdscript
func animate_with_easing() -> void:
    var tween := create_tween()

    tween.tween_property(self, "position", target, 1.0)\
        .set_trans(Tween.TRANS_SINE)\
        .set_ease(Tween.EASE_OUT)
```

### 过渡类型 (Trans)

| 类型 | 效果 |
|------|------|
| TRANS_LINEAR | 线性 |
| TRANS_SINE | 正弦 |
| TRANS_QUINT | 五次方 |
| TRANS_QUART | 四次方 |
| TRANS_QUAD | 二次方 |
| TRANS_EXPO | 指数 |
| TRANS_ELASTIC | 弹性 |
| TRANS_CUBIC | 三次方 |
| TRANS_CIRC | 圆形 |
| TRANS_BOUNCE | 弹跳 |
| TRANS_BACK | 回弹 |
| TRANS_SPRING | 弹簧 |

### 缓动类型 (Ease)

| 类型 | 效果 |
|------|------|
| EASE_IN | 慢入 |
| EASE_OUT | 慢出 |
| EASE_IN_OUT | 慢入慢出 |
| EASE_OUT_IN | 慢出慢入 |

## 循环和次数

```gdscript
# 循环播放
var tween := create_tween()
tween.set_loops()  # 无限循环
tween.tween_property(self, "rotation", TAU, 2.0)

# 指定次数
tween.set_loops(3)  # 循环 3 次

# 往返动画（乒乓）
tween.tween_property($Sprite, "position:x", 100, 0.5)
tween.tween_property($Sprite, "position:x", 0, 0.5)
tween.set_loops()
```

## 控制 Tween

```gdscript
var tween: Tween

func start_animation() -> void:
    tween = create_tween()
    tween.tween_property(self, "position", target, 2.0)

func pause_animation() -> void:
    if tween:
        tween.pause()

func resume_animation() -> void:
    if tween:
        tween.play()

func stop_animation() -> void:
    if tween:
        tween.kill()
```

## 常见动画效果

### 弹跳出现

```gdscript
func bounce_in() -> void:
    scale = Vector2.ZERO
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2.ONE, 0.5)\
        .set_trans(Tween.TRANS_ELASTIC)\
        .set_ease(Tween.EASE_OUT)
```

### 淡入淡出

```gdscript
func fade_out_and_free() -> void:
    var tween := create_tween()
    tween.tween_property(self, "modulate:a", 0.0, 0.3)
    tween.tween_callback(queue_free)
```

### 震动效果

```gdscript
func shake(intensity: float = 10.0, duration: float = 0.3) -> void:
    var original_pos := position
    var tween := create_tween()
    var shake_count := 10

    for i in shake_count:
        var offset := Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(self, "position", original_pos + offset, duration / shake_count)

    tween.tween_property(self, "position", original_pos, duration / shake_count)
```

### 脉冲效果

```gdscript
func pulse() -> void:
    var tween := create_tween()
    tween.set_loops()
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)\
        .set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "scale", Vector2.ONE, 0.3)\
        .set_trans(Tween.TRANS_SINE)
```

## 自定义插值

```gdscript
func custom_interpolation() -> void:
    var tween := create_tween()
    tween.tween_method(
        interpolate_color,
        Color.RED,
        Color.BLUE,
        1.0
    )

func interpolate_color(color: Color) -> void:
    $Sprite.modulate = color
```
