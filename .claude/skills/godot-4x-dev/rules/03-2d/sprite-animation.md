# 精灵与动画

## Sprite2D 基础

```gdscript
extends Sprite2D

# 基本属性
texture = preload("res://assets/sprites/player.png")
centered = true
offset = Vector2.ZERO
flip_h = false  # 水平翻转
flip_v = false  # 垂直翻转

# 区域模式（从 spritesheet 截取）
region_enabled = true
region_rect = Rect2(0, 0, 32, 32)

# 帧数（spritesheet）
hframes = 4  # 水平帧数
vframes = 2  # 垂直帧数
frame = 0    # 当前帧索引
```

## AnimatedSprite2D

```gdscript
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
    # 根据状态切换动画
    if velocity.x != 0:
        animated_sprite.play("run")
        animated_sprite.flip_h = velocity.x < 0
    else:
        animated_sprite.play("idle")

    if not is_on_floor():
        if velocity.y < 0:
            animated_sprite.play("jump")
        else:
            animated_sprite.play("fall")
```

## SpriteFrames 配置

在编辑器中创建 SpriteFrames 资源：
1. 新建 AnimatedSprite2D 节点
2. 在 Inspector 中创建新 SpriteFrames
3. 添加动画并设置帧

```gdscript
# 代码中访问 SpriteFrames
var frames: SpriteFrames = animated_sprite.sprite_frames

# 获取动画信息
var anim_names: PackedStringArray = frames.get_animation_names()
var frame_count: int = frames.get_frame_count("idle")
var fps: float = frames.get_animation_speed("idle")
```

## 动画信号

```gdscript
func _ready() -> void:
    animated_sprite.animation_finished.connect(_on_animation_finished)
    animated_sprite.frame_changed.connect(_on_frame_changed)

func _on_animation_finished() -> void:
    if animated_sprite.animation == "attack":
        animated_sprite.play("idle")

func _on_frame_changed() -> void:
    # 在特定帧触发效果（如攻击判定）
    if animated_sprite.animation == "attack" and animated_sprite.frame == 2:
        deal_damage()
```

## AnimationPlayer 动画

更复杂的动画使用 AnimationPlayer：

```gdscript
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    anim.animation_finished.connect(_on_anim_finished)

func play_animation(anim_name: String) -> void:
    if anim.has_animation(anim_name):
        anim.play(anim_name)

func _on_anim_finished(anim_name: StringName) -> void:
    match anim_name:
        "death":
            queue_free()
        "attack":
            play_animation("idle")
```

## 动画队列

```gdscript
func attack_combo() -> void:
    anim.play("attack1")
    anim.queue("attack2")
    anim.queue("attack3")
    anim.queue("idle")
```

## 翻转精灵

```gdscript
# 使用 flip_h
func update_facing(direction: float) -> void:
    if direction != 0:
        sprite.flip_h = direction < 0

# 使用 scale（保持碰撞体同步）
func update_facing_scale(direction: float) -> void:
    if direction != 0:
        var new_scale_x: float = -1.0 if direction < 0 else 1.0
        scale.x = abs(scale.x) * new_scale_x
```

## 常见场景结构

```
Player (CharacterBody2D)
├── Sprite2D           # 或 AnimatedSprite2D
├── AnimationPlayer    # 复杂动画控制
├── CollisionShape2D
└── Hitbox (Area2D)    # 攻击判定
```

## 动画最佳实践

1. **命名规范**: `idle`, `run`, `jump`, `fall`, `attack`, `hurt`, `death`
2. **循环设置**: `idle`, `run` 循环播放；`attack`, `death` 单次播放
3. **帧率**: 通常 8-12 FPS 足够，快速动作可提高
4. **原点对齐**: Sprite 原点通常设在脚底中心
