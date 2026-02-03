# Scripts/unit/visual/shape_renderer.gd
class_name ShapeRenderer
extends Node2D

## 几何形状渲染器
## 根据单位模式和体型绘制对应的几何形状
## 血量以边框填充比例显示

# ============ 导出变量 ============

## 单位模式（决定形状）
@export var unit_mode: UnitEnums.UnitMode = UnitEnums.UnitMode.WARRIOR:
	set(value):
		unit_mode = value
		queue_redraw()

## 单位体型（决定大小）
@export var unit_size: UnitEnums.UnitSize = UnitEnums.UnitSize.MEDIUM:
	set(value):
		unit_size = value
		queue_redraw()

## 填充颜色
@export var fill_color: Color = Color.WHITE:
	set(value):
		fill_color = value
		queue_redraw()

## 边框颜色（阵营色）
@export var border_color: Color = Color.DODGER_BLUE:
	set(value):
		border_color = value
		queue_redraw()

## 血量百分比（0-1）
@export_range(0.0, 1.0) var health_percent: float = 1.0:
	set(value):
		health_percent = clampf(value, 0.0, 1.0)
		queue_redraw()

## 边框宽度
@export var border_width: float = 3.0

## 每格像素数
@export var pixels_per_tile: float = 80.0

# ============ 常量 ============

## 圆形近似的多边形段数
const CIRCLE_SEGMENTS: int = 32


# ============ 公共方法 ============

## 获取当前半径（像素）
func get_radius() -> float:
	return UnitConfig.get_size_radius(unit_size) * pixels_per_tile


## 获取形状点集
func get_shape_points() -> PackedVector2Array:
	var radius := get_radius()
	var sides := UnitConfig.get_shape_sides(unit_mode)

	if sides == 0:
		# 圆形用多边形近似
		return _create_circle_points(radius, CIRCLE_SEGMENTS)
	else:
		return _create_polygon_points(radius, sides)


# ============ 绘制方法 ============

func _draw() -> void:
	var points := get_shape_points()

	if points.is_empty():
		return

	# 绘制填充
	draw_colored_polygon(points, fill_color)

	# 绘制边框（血量比例）
	_draw_health_border(points)


func _draw_health_border(points: PackedVector2Array) -> void:
	if points.is_empty():
		return

	var total_length := _calculate_perimeter(points)
	var health_length := total_length * health_percent

	var current_length := 0.0
	for i in range(points.size()):
		var start := points[i]
		var end := points[(i + 1) % points.size()]
		var segment_length := start.distance_to(end)

		if current_length + segment_length <= health_length:
			# 整段都在血量范围内
			draw_line(start, end, border_color, border_width)
		elif current_length < health_length:
			# 部分在范围内
			var remaining := health_length - current_length
			var ratio := remaining / segment_length
			var mid := start.lerp(end, ratio)
			draw_line(start, mid, border_color, border_width)

		current_length += segment_length


# ============ 辅助方法 ============

func _create_polygon_points(radius: float, sides: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var angle_offset := -PI / 2  # 从顶部开始

	# 菱形需要旋转45度
	if UnitConfig.needs_rotation(unit_mode):
		angle_offset += PI / 4

	for i in range(sides):
		var angle := angle_offset + TAU * i / sides
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	return points


func _create_circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(segments):
		var angle := TAU * i / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


func _calculate_perimeter(points: PackedVector2Array) -> float:
	var total := 0.0
	for i in range(points.size()):
		var start := points[i]
		var end := points[(i + 1) % points.size()]
		total += start.distance_to(end)
	return total
