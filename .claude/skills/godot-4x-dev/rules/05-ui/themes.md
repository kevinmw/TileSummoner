# 主题系统

## 主题资源

主题 (Theme) 是一个资源文件，包含 UI 控件的样式定义。

## 创建主题

1. 在 FileSystem 中右键 → New Resource → Theme
2. 保存为 `.tres` 文件
3. 在 Inspector 中编辑或通过代码设置

## 应用主题

```gdscript
# 应用到整个场景
func _ready() -> void:
    var theme := preload("res://resources/themes/game_theme.tres")
    get_tree().root.theme = theme

# 应用到单个 Control
$Panel.theme = preload("res://resources/themes/panel_theme.tres")

# 设置默认主题（project.godot）
# [gui]
# theme/custom="res://resources/themes/main_theme.tres"
```

## StyleBox 类型

| 类型 | 用途 |
|------|------|
| StyleBoxEmpty | 无样式 |
| StyleBoxFlat | 纯色/渐变背景 |
| StyleBoxTexture | 纹理背景 |
| StyleBoxLine | 线条边框 |

## 代码创建 StyleBox

```gdscript
func create_panel_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new()

    # 背景
    style.bg_color = Color(0.1, 0.1, 0.1, 0.9)

    # 边框
    style.border_width_left = 2
    style.border_width_top = 2
    style.border_width_right = 2
    style.border_width_bottom = 2
    style.border_color = Color(0.3, 0.3, 0.3)

    # 圆角
    style.corner_radius_top_left = 8
    style.corner_radius_top_right = 8
    style.corner_radius_bottom_left = 8
    style.corner_radius_bottom_right = 8

    # 内边距
    style.content_margin_left = 10
    style.content_margin_top = 10
    style.content_margin_right = 10
    style.content_margin_bottom = 10

    # 阴影
    style.shadow_color = Color(0, 0, 0, 0.3)
    style.shadow_size = 4
    style.shadow_offset = Vector2(2, 2)

    return style
```

## 主题覆盖

```gdscript
# 覆盖单个控件的样式
@onready var button: Button = $Button

func _ready() -> void:
    # 覆盖 StyleBox
    var hover_style := StyleBoxFlat.new()
    hover_style.bg_color = Color.BLUE
    button.add_theme_stylebox_override("hover", hover_style)

    # 覆盖颜色
    button.add_theme_color_override("font_color", Color.WHITE)
    button.add_theme_color_override("font_hover_color", Color.YELLOW)

    # 覆盖字体
    var font := preload("res://assets/fonts/custom_font.ttf")
    button.add_theme_font_override("font", font)

    # 覆盖字体大小
    button.add_theme_font_size_override("font_size", 24)

    # 覆盖常量
    button.add_theme_constant_override("outline_size", 2)
```

## Button 主题属性

```gdscript
# Button 的完整样式集
theme.set_stylebox("normal", "Button", normal_style)
theme.set_stylebox("hover", "Button", hover_style)
theme.set_stylebox("pressed", "Button", pressed_style)
theme.set_stylebox("disabled", "Button", disabled_style)
theme.set_stylebox("focus", "Button", focus_style)

theme.set_color("font_color", "Button", Color.WHITE)
theme.set_color("font_hover_color", "Button", Color.YELLOW)
theme.set_color("font_pressed_color", "Button", Color.GRAY)
theme.set_color("font_disabled_color", "Button", Color.DIM_GRAY)

theme.set_font("font", "Button", custom_font)
theme.set_font_size("font_size", "Button", 16)
```

## 完整主题创建示例

```gdscript
func create_game_theme() -> Theme:
    var theme := Theme.new()

    # 默认字体
    var font := preload("res://assets/fonts/main_font.ttf")
    theme.default_font = font
    theme.default_font_size = 16

    # Panel 样式
    var panel_style := create_panel_style()
    theme.set_stylebox("panel", "PanelContainer", panel_style)

    # Button 样式
    var btn_normal := StyleBoxFlat.new()
    btn_normal.bg_color = Color(0.2, 0.2, 0.3)
    btn_normal.corner_radius_top_left = 4
    btn_normal.corner_radius_top_right = 4
    btn_normal.corner_radius_bottom_left = 4
    btn_normal.corner_radius_bottom_right = 4

    var btn_hover := btn_normal.duplicate()
    btn_hover.bg_color = Color(0.3, 0.3, 0.5)

    var btn_pressed := btn_normal.duplicate()
    btn_pressed.bg_color = Color(0.1, 0.1, 0.2)

    theme.set_stylebox("normal", "Button", btn_normal)
    theme.set_stylebox("hover", "Button", btn_hover)
    theme.set_stylebox("pressed", "Button", btn_pressed)

    # Label 样式
    theme.set_color("font_color", "Label", Color.WHITE)
    theme.set_font_size("font_size", "Label", 18)

    return theme
```

## 主题继承

```gdscript
# 子控件会继承父控件的主题
# Control (有 theme)
# └── VBoxContainer
#     └── Button (使用父级 theme)

# 覆盖继承的主题
$Button.theme = another_theme
```
