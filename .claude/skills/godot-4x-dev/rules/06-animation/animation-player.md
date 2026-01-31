# AnimationPlayer

## 基础使用

```gdscript
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    anim.animation_finished.connect(_on_animation_finished)

func play_animation(name: String) -> void:
    if anim.has_animation(name):
        anim.play(name)

func _on_animation_finished(anim_name: StringName) -> void:
    match anim_name:
        "attack":
            anim.play("idle")
        "death":
            queue_free()
```

## 动画控制

```gdscript
# 播放控制
anim.play("walk")           # 播放
anim.play("walk", -1, 2.0)  # 2 倍速播放
anim.play("walk", -1, -1.0) # 倒放
anim.play_backwards("walk") # 倒放
anim.pause()                # 暂停
anim.stop()                 # 停止
anim.stop(true)             # 停止并重置

# 状态查询
anim.is_playing()
anim.current_animation
anim.current_animation_position
anim.current_animation_length

# 跳转
anim.seek(0.5)  # 跳转到 0.5 秒
anim.seek(0.5, true)  # 跳转并更新
anim.advance(0.1)  # 前进 0.1 秒
```

## 动画队列

```gdscript
func play_combo() -> void:
    anim.play("attack1")
    anim.queue("attack2")
    anim.queue("attack3")
    anim.queue("idle")

# 清空队列
anim.clear_queue()
```

## 创建动画（代码）

```gdscript
func create_fade_animation() -> void:
    var animation := Animation.new()

    # 添加轨道
    var track_idx := animation.add_track(Animation.TYPE_VALUE)
    animation.track_set_path(track_idx, ".:modulate")

    # 添加关键帧
    animation.track_insert_key(track_idx, 0.0, Color.WHITE)
    animation.track_insert_key(track_idx, 0.5, Color.TRANSPARENT)

    # 设置长度
    animation.length = 0.5

    # 添加到动画库
    var library := anim.get_animation_library("")
    library.add_animation("fade_out", animation)
```

## 动画轨道类型

| 类型 | 用途 |
|------|------|
| TYPE_VALUE | 属性值动画 |
| TYPE_POSITION_3D | 3D 位置 |
| TYPE_ROTATION_3D | 3D 旋转 |
| TYPE_SCALE_3D | 3D 缩放 |
| TYPE_BLEND_SHAPE | 变形器 |
| TYPE_METHOD | 方法调用 |
| TYPE_BEZIER | 贝塞尔曲线 |
| TYPE_AUDIO | 音频 |
| TYPE_ANIMATION | 嵌套动画 |

## 方法调用轨道

在动画中调用方法：

```gdscript
# 在动画编辑器中：
# 1. 添加 Call Method Track
# 2. 选择目标节点
# 3. 在时间线上添加关键帧
# 4. 选择要调用的方法

# 被调用的方法
func spawn_particles() -> void:
    $Particles.emitting = true

func play_sound(sound_name: String) -> void:
    AudioManager.play_sfx(sound_name)
```

## 动画混合

```gdscript
# 交叉淡入淡出
anim.play("walk", 0.3)  # 0.3 秒混合时间

# 自定义混合时间
anim.set_blend_time("idle", "walk", 0.2)
anim.set_blend_time("walk", "run", 0.1)
```

## 动画库

```gdscript
# Godot 4.x 使用动画库组织动画
var library := AnimationLibrary.new()
library.add_animation("idle", idle_animation)
library.add_animation("walk", walk_animation)

anim.add_animation_library("character", library)

# 播放库中的动画
anim.play("character/idle")

# 默认库（空名称）
anim.play("idle")  # 等同于 anim.play("/idle")
```

## 常见使用模式

### 状态机配合

```gdscript
enum State { IDLE, WALK, ATTACK }
var current_state: State = State.IDLE

func change_state(new_state: State) -> void:
    if current_state == new_state:
        return

    current_state = new_state

    match new_state:
        State.IDLE:
            anim.play("idle")
        State.WALK:
            anim.play("walk", 0.1)
        State.ATTACK:
            anim.play("attack")
```

### 等待动画完成

```gdscript
func attack() -> void:
    anim.play("attack")
    await anim.animation_finished
    anim.play("idle")
```

## 动画信号

```gdscript
# 可用信号
animation_changed  # 动画改变时
animation_finished # 动画完成时
animation_libraries_updated # 库更新时
animation_list_changed # 动画列表改变时
animation_started  # 动画开始时
```
