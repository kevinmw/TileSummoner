# Control 基础节点

## Control 节点层级

```
Control (所有 UI 的基类)
├── BaseButton
│   ├── Button
│   ├── CheckBox
│   ├── CheckButton
│   └── TextureButton
├── Range
│   ├── ProgressBar
│   ├── Slider (HSlider/VSlider)
│   └── SpinBox
├── TextEdit / LineEdit
├── Label / RichTextLabel
├── TextureRect
└── Container (布局容器)
```

## 锚点与边距

```gdscript
extends Control

func _ready() -> void:
    # 预设锚点
    set_anchors_preset(Control.PRESET_CENTER)  # 居中
    set_anchors_preset(Control.PRESET_FULL_RECT)  # 全屏
    set_anchors_preset(Control.PRESET_TOP_LEFT)  # 左上角

    # 手动设置锚点 (0-1 范围)
    anchor_left = 0.0
    anchor_top = 0.0
    anchor_right = 1.0
    anchor_bottom = 1.0

    # 边距（相对于锚点的偏移）
    offset_left = 10
    offset_top = 10
    offset_right = -10
    offset_bottom = -10
```

## 常用 Control 节点

### Label

```gdscript
@onready var label: Label = $Label

func _ready() -> void:
    label.text = "Score: 0"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD

func update_score(score: int) -> void:
    label.text = "Score: %d" % score
```

### Button

```gdscript
@onready var button: Button = $Button

func _ready() -> void:
    button.text = "Start Game"
    button.pressed.connect(_on_button_pressed)
    button.mouse_entered.connect(_on_button_hover)

func _on_button_pressed() -> void:
    start_game()

func _on_button_hover() -> void:
    AudioManager.play_ui_hover()
```

### ProgressBar

```gdscript
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
    health_bar.min_value = 0
    health_bar.max_value = 100
    health_bar.value = 100
    health_bar.show_percentage = false

func update_health(current: int, max_health: int) -> void:
    health_bar.max_value = max_health
    health_bar.value = current

    # 平滑过渡
    var tween := create_tween()
    tween.tween_property(health_bar, "value", current, 0.3)
```

### TextureRect

```gdscript
@onready var icon: TextureRect = $Icon

func _ready() -> void:
    icon.texture = preload("res://assets/ui/icon.png")
    icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
```

### LineEdit

```gdscript
@onready var input_field: LineEdit = $LineEdit

func _ready() -> void:
    input_field.placeholder_text = "Enter your name..."
    input_field.max_length = 20
    input_field.text_submitted.connect(_on_text_submitted)

func _on_text_submitted(text: String) -> void:
    player_name = text
    input_field.release_focus()
```

## 焦点控制

```gdscript
# 设置焦点
button.grab_focus()

# 焦点邻居（键盘导航）
button.focus_neighbor_top = $ButtonAbove.get_path()
button.focus_neighbor_bottom = $ButtonBelow.get_path()

# 焦点模式
button.focus_mode = Control.FOCUS_ALL  # 键盘和鼠标
button.focus_mode = Control.FOCUS_CLICK  # 仅鼠标
button.focus_mode = Control.FOCUS_NONE  # 禁用焦点
```

## 鼠标过滤

```gdscript
# 鼠标穿透设置
mouse_filter = Control.MOUSE_FILTER_STOP   # 捕获鼠标事件
mouse_filter = Control.MOUSE_FILTER_PASS   # 传递给子节点
mouse_filter = Control.MOUSE_FILTER_IGNORE # 忽略鼠标事件
```

## 尺寸标志

```gdscript
# 水平尺寸
size_flags_horizontal = Control.SIZE_FILL  # 填充
size_flags_horizontal = Control.SIZE_EXPAND  # 扩展
size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # 收缩到开始

# 权重（expand 时）
size_flags_stretch_ratio = 2.0  # 占据 2 倍空间
```

## 最小尺寸

```gdscript
custom_minimum_size = Vector2(100, 50)  # 最小 100x50 像素
```

## 常见场景结构

```
UI (CanvasLayer)
└── Control (全屏容器)
    ├── MarginContainer
    │   └── VBoxContainer
    │       ├── Label (标题)
    │       └── HBoxContainer
    │           ├── Button (开始)
    │           └── Button (退出)
    └── TextureRect (背景)
```
