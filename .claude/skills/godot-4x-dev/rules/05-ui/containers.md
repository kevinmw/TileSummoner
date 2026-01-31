# 容器布局系统

## 容器类型概览

| 容器 | 用途 |
|------|------|
| HBoxContainer | 水平排列 |
| VBoxContainer | 垂直排列 |
| GridContainer | 网格排列 |
| MarginContainer | 添加边距 |
| CenterContainer | 居中子节点 |
| PanelContainer | 背景面板 |
| ScrollContainer | 可滚动区域 |
| HSplitContainer | 水平分割 |
| VSplitContainer | 垂直分割 |
| TabContainer | 标签页 |

## HBoxContainer / VBoxContainer

```gdscript
# HBoxContainer - 水平排列
@onready var hbox: HBoxContainer = $HBoxContainer

func _ready() -> void:
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    hbox.add_theme_constant_override("separation", 10)  # 间距

# VBoxContainer - 垂直排列
@onready var vbox: VBoxContainer = $VBoxContainer

func add_menu_item(text: String) -> Button:
    var button := Button.new()
    button.text = text
    vbox.add_child(button)
    return button
```

## GridContainer

```gdscript
@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
    grid.columns = 4  # 4 列

    # 设置间距
    grid.add_theme_constant_override("h_separation", 5)
    grid.add_theme_constant_override("v_separation", 5)

func populate_inventory(items: Array[Item]) -> void:
    # 清空现有
    for child in grid.get_children():
        child.queue_free()

    # 添加物品槽
    for item in items:
        var slot := create_item_slot(item)
        grid.add_child(slot)
```

## MarginContainer

```gdscript
@onready var margin: MarginContainer = $MarginContainer

func _ready() -> void:
    # 设置各边边距
    margin.add_theme_constant_override("margin_left", 20)
    margin.add_theme_constant_override("margin_right", 20)
    margin.add_theme_constant_override("margin_top", 10)
    margin.add_theme_constant_override("margin_bottom", 10)
```

## ScrollContainer

```gdscript
@onready var scroll: ScrollContainer = $ScrollContainer

func _ready() -> void:
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

func scroll_to_bottom() -> void:
    await get_tree().process_frame  # 等待布局更新
    scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
```

## 尺寸标志

```gdscript
# 子节点的尺寸行为
control.size_flags_horizontal = Control.SIZE_FILL  # 填充可用空间
control.size_flags_horizontal = Control.SIZE_EXPAND  # 扩展
control.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN  # 收缩到开始
control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # 收缩居中
control.size_flags_horizontal = Control.SIZE_SHRINK_END  # 收缩到结束

# 组合使用
control.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL

# 权重（多个 expand 元素时）
control.size_flags_stretch_ratio = 2.0  # 占据 2 倍空间
```

## 常见布局模式

### 居中菜单

```
CenterContainer (全屏)
└── VBoxContainer
    ├── Label (标题)
    ├── Button (开始游戏)
    ├── Button (设置)
    └── Button (退出)
```

### HUD 布局

```
Control (全屏)
├── MarginContainer (左上角)
│   └── HBoxContainer
│       ├── TextureRect (头像)
│       └── ProgressBar (血条)
│
├── MarginContainer (右上角)
│   └── Label (分数)
│
└── MarginContainer (底部居中)
    └── HBoxContainer
        ├── TextureRect (技能1)
        ├── TextureRect (技能2)
        └── TextureRect (技能3)
```

### 物品网格

```
PanelContainer
└── MarginContainer
    └── ScrollContainer
        └── GridContainer (columns=5)
            ├── ItemSlot
            ├── ItemSlot
            └── ...
```

## 动态添加子节点

```gdscript
func create_dynamic_menu(items: Array[String]) -> void:
    for item_text in items:
        var button := Button.new()
        button.text = item_text
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.pressed.connect(_on_menu_item_pressed.bind(item_text))
        vbox.add_child(button)

func _on_menu_item_pressed(item: String) -> void:
    print("Selected: ", item)
```

## 容器嵌套技巧

```gdscript
# 创建带边距的居中面板
func create_dialog_panel() -> Control:
    var center := CenterContainer.new()
    var panel := PanelContainer.new()
    var margin := MarginContainer.new()
    var content := VBoxContainer.new()

    center.add_child(panel)
    panel.add_child(margin)
    margin.add_child(content)

    margin.add_theme_constant_override("margin_left", 20)
    margin.add_theme_constant_override("margin_right", 20)
    margin.add_theme_constant_override("margin_top", 15)
    margin.add_theme_constant_override("margin_bottom", 15)

    return center
```
