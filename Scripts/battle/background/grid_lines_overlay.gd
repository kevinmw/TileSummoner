extends Node2D
class_name GridLinesOverlay

## 网格线覆盖层
## 绘制装饰性的背景网格线


# ============ 导出变量 ============

## 线条颜色
@export var line_color: Color = Color(0.87, 0.70, 0.16, 0.03)

## 线条间距（像素）
@export var spacing: int = 50

## 线条宽度
@export var line_width: float = 1.0

## 区域尺寸
@export var area_size: Vector2 = Vector2(1280, 720)


# ============ 生命周期 ============

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_horizontal_lines()
	_draw_vertical_lines()


# ============ 绘制 ============

## 绘制水平线
func _draw_horizontal_lines() -> void:
	var y := 0
	while y < area_size.y:
		draw_line(
			Vector2(0, y),
			Vector2(area_size.x, y),
			line_color,
			line_width
		)
		y += spacing


## 绘制垂直线
func _draw_vertical_lines() -> void:
	var x := 0
	while x < area_size.x:
		draw_line(
			Vector2(x, 0),
			Vector2(x, area_size.y),
			line_color,
			line_width
		)
		x += spacing
