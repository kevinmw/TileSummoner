extends Node2D
class_name BattleGridContainer

## 战斗棋盘容器
## 负责绘制棋盘背景和边框
## 提供地块位置计算


# ============ 常量 ============

## 列数
const COLS: int = 7

## 行数
const ROWS: int = 9

## 地块尺寸
const TILE_SIZE: Vector2 = Vector2(80, 80)

## 地块间隙
const TILE_GAP: float = 6.0

## 内边距
const PADDING: float = 12.0


# ============ 导出变量 ============

## 背景颜色
@export var bg_color: Color = Color("#1A1E26", 0.6)

## 边框颜色
@export var border_color: Color = Color(0.4, 0.4, 0.45, 0.3)

## 边框宽度
@export var border_width: float = 2.0

## 圆角半径
@export var corner_radius: float = 16.0


# ============ 生命周期 ============

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	_draw_background()
	_draw_border()


# ============ 绘制方法 ============

## 绘制圆角背景
func _draw_background() -> void:
	var size := get_total_size()
	var rect := Rect2(Vector2.ZERO, size)

	# Godot 4.x 没有内置的圆角矩形，使用 draw_rect 近似
	# 或者可以用多边形逼近圆角
	if corner_radius > 0:
		_draw_rounded_rect(rect, bg_color, corner_radius, true)
	else:
		draw_rect(rect, bg_color)


## 绘制边框
func _draw_border() -> void:
	var size := get_total_size()
	var rect := Rect2(Vector2.ZERO, size)

	if corner_radius > 0:
		_draw_rounded_rect(rect, border_color, corner_radius, false)
	else:
		draw_rect(rect, border_color, false, border_width)


## 绘制圆角矩形
func _draw_rounded_rect(rect: Rect2, color: Color, radius: float, filled: bool) -> void:
	var points := _create_rounded_rect_points(rect, radius)

	if filled:
		draw_polygon(points, [color])
	else:
		draw_polyline(points, color, border_width)


## 创建圆角矩形点集
func _create_rounded_rect_points(rect: Rect2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var r := minf(radius, minf(rect.size.x, rect.size.y) / 2.0)

	# 圆弧分段数
	const SEGMENTS: int = 8

	# 左上角
	for i in range(SEGMENTS + 1):
		var angle := PI + PI / 2.0 * (float(i) / SEGMENTS)
		points.append(rect.position + Vector2(r, r) + Vector2(cos(angle), sin(angle)) * r)

	# 右上角
	for i in range(SEGMENTS + 1):
		var angle := PI * 1.5 + PI / 2.0 * (float(i) / SEGMENTS)
		points.append(rect.position + Vector2(rect.size.x - r, r) + Vector2(cos(angle), sin(angle)) * r)

	# 右下角
	for i in range(SEGMENTS + 1):
		var angle := PI / 2.0 * (float(i) / SEGMENTS)
		points.append(rect.position + Vector2(rect.size.x - r, rect.size.y - r) + Vector2(cos(angle), sin(angle)) * r)

	# 左下角
	for i in range(SEGMENTS + 1):
		var angle := PI / 2.0 + PI / 2.0 * (float(i) / SEGMENTS)
		points.append(rect.position + Vector2(r, rect.size.y - r) + Vector2(cos(angle), sin(angle)) * r)

	# 闭合路径
	points.append(points[0])

	return points


# ============ 尺寸计算 ============

## 获取总尺寸
func get_total_size() -> Vector2:
	var width := float(COLS) * TILE_SIZE.x + float(COLS - 1) * TILE_GAP + 2 * PADDING
	var height := float(ROWS) * TILE_SIZE.y + float(ROWS - 1) * TILE_GAP + 2 * PADDING
	return Vector2(width, height)


## 获取指定格子的位置（相对于容器左上角）
func get_tile_position(col: int, row: int) -> Vector2:
	var x := PADDING + float(col) * (TILE_SIZE.x + TILE_GAP) + TILE_SIZE.x / 2.0
	var y := PADDING + float(row) * (TILE_SIZE.y + TILE_GAP) + TILE_SIZE.y / 2.0
	return Vector2(x, y)


## 获取居中偏移（使容器中心对齐原点）
func get_center_offset() -> Vector2:
	var size := get_total_size()
	return -size / 2.0


## 获取指定格子的居中位置（相对于容器中心）
func get_tile_centered_position(col: int, row: int) -> Vector2:
	return get_tile_position(col, row) + get_center_offset()
