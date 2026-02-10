# Scripts/ui/tile_editor/tile_palette_item.gd
class_name TilePaletteItem
extends Button

## 地块调色板项
## 用于在编辑器中显示可选择的地块类型

# ============ 节点引用 ============

@onready var icon_rect: TextureRect = $HBox/Icon
@onready var name_label: Label = $HBox/NameLabel
@onready var count_label: Label = $HBox/CountLabel

# ============ 属性 ============

## 地块数据
var tile_data: Resource = null

## 当前数量
var count: int = 0

# ============ 公共方法 ============

## 设置显示内容
func setup(data: Resource, item_count: int = 0) -> void:
	tile_data = data
	count = item_count
	_update_display()


## 更新数量
func set_count(new_count: int) -> void:
	count = new_count
	if count_label:
		count_label.text = "x%d" % count


# ============ 私有方法 ============

func _update_display() -> void:
	if not tile_data:
		return

	if name_label and tile_data.has("display_name"):
		name_label.text = tile_data.display_name

	if icon_rect and tile_data.has("icon"):
		icon_rect.texture = tile_data.icon

	if count_label:
		count_label.text = "x%d" % count
