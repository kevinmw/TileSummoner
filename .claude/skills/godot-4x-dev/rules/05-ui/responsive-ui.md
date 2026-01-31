# 响应式 UI

## 锚点预设

```gdscript
# 常用预设
Control.PRESET_TOP_LEFT      # 左上角
Control.PRESET_TOP_RIGHT     # 右上角
Control.PRESET_BOTTOM_LEFT   # 左下角
Control.PRESET_BOTTOM_RIGHT  # 右下角
Control.PRESET_CENTER        # 居中
Control.PRESET_CENTER_TOP    # 顶部居中
Control.PRESET_CENTER_BOTTOM # 底部居中
Control.PRESET_CENTER_LEFT   # 左侧居中
Control.PRESET_CENTER_RIGHT  # 右侧居中
Control.PRESET_FULL_RECT     # 全屏
Control.PRESET_HCENTER_WIDE  # 水平居中，上下拉伸
Control.PRESET_VCENTER_WIDE  # 垂直居中，左右拉伸

func _ready() -> void:
    set_anchors_preset(Control.PRESET_FULL_RECT)
    set_anchors_and_offsets_preset(Control.PRESET_CENTER)
```

## 多分辨率策略

### 项目设置

```
# project.godot
[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"  # 或 "viewport"
window/stretch/aspect="expand"       # 或 "keep", "keep_width", "keep_height"
```

### 拉伸模式

| 模式 | 效果 |
|------|------|
| disabled | 不拉伸，1:1 像素 |
| canvas_items | 拉伸 2D 画布，保持像素清晰 |
| viewport | 拉伸整个视口 |

### 宽高比模式

| 模式 | 效果 |
|------|------|
| ignore | 忽略宽高比，拉伸填满 |
| keep | 保持宽高比，可能有黑边 |
| keep_width | 保持宽度，高度可变 |
| keep_height | 保持高度，宽度可变 |
| expand | 扩展视口，无黑边 |

## 安全区域

```gdscript
# 获取安全区域（避开刘海、状态栏等）
func _ready() -> void:
    var safe_area: Rect2i = DisplayServer.get_display_safe_area()

    # 调整 UI 边距
    var margin := $MarginContainer
    margin.add_theme_constant_override("margin_top", safe_area.position.y)
    margin.add_theme_constant_override("margin_left", safe_area.position.x)
```

## 响应式布局技巧

### 根据屏幕尺寸调整

```gdscript
func _ready() -> void:
    get_viewport().size_changed.connect(_on_viewport_size_changed)
    _on_viewport_size_changed()

func _on_viewport_size_changed() -> void:
    var viewport_size := get_viewport_rect().size
    var aspect_ratio := viewport_size.x / viewport_size.y

    if aspect_ratio > 1.5:
        # 宽屏布局
        setup_wide_layout()
    else:
        # 窄屏/移动端布局
        setup_narrow_layout()

func setup_wide_layout() -> void:
    $Sidebar.visible = true
    $Content.set_anchors_preset(Control.PRESET_HCENTER_WIDE)

func setup_narrow_layout() -> void:
    $Sidebar.visible = false
    $Content.set_anchors_preset(Control.PRESET_FULL_RECT)
```

### 字体大小适配

```gdscript
func _ready() -> void:
    update_font_sizes()

func update_font_sizes() -> void:
    var base_size := 16
    var scale := get_viewport_rect().size.y / 1080.0

    $TitleLabel.add_theme_font_size_override("font_size", int(32 * scale))
    $BodyLabel.add_theme_font_size_override("font_size", int(base_size * scale))
```

## HUD 响应式布局

```gdscript
extends Control

@onready var health_bar: Control = $HealthBar
@onready var minimap: Control = $Minimap
@onready var inventory: Control = $Inventory

func _ready() -> void:
    # 血条 - 左上角，有边距
    health_bar.set_anchors_preset(Control.PRESET_TOP_LEFT)
    health_bar.offset_left = 20
    health_bar.offset_top = 20

    # 小地图 - 右上角
    minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    minimap.offset_right = -20
    minimap.offset_top = 20

    # 背包 - 右下角
    inventory.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    inventory.offset_right = -20
    inventory.offset_bottom = -20
```

## 触摸适配

```gdscript
func _ready() -> void:
    if DisplayServer.is_touchscreen_available():
        setup_touch_ui()
    else:
        setup_desktop_ui()

func setup_touch_ui() -> void:
    # 增大按钮尺寸
    for button in get_tree().get_nodes_in_group("ui_buttons"):
        button.custom_minimum_size = Vector2(60, 60)

    # 显示虚拟摇杆
    $VirtualJoystick.visible = true

func setup_desktop_ui() -> void:
    $VirtualJoystick.visible = false
```

## SubViewportContainer 缩放

```gdscript
# 使用 SubViewport 保持像素完美
# SubViewportContainer
# └── SubViewport (viewport_size = 320x180)
#     └── 游戏内容

extends SubViewportContainer

func _ready() -> void:
    stretch = true
    # 整数缩放
    var scale := mini(
        int(get_viewport_rect().size.x / $SubViewport.size.x),
        int(get_viewport_rect().size.y / $SubViewport.size.y)
    )
    $SubViewport.size = Vector2i(320 * scale, 180 * scale)
```
