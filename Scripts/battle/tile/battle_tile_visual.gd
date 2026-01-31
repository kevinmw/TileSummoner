extends Node2D
class_name BattleTileVisual

## 战斗地块视觉渲染
## 负责绘制地块的背景、图标和边框
## 支持内凹阴影效果、地形图标显示、hover 发光


# ============ 常量 ============

const INSET_SHADER_PATH := "res://Scripts/battle/tile/tile_inset.gdshader"
const HOVER_GLOW_ENERGY := 1.5


# ============ 导出变量 ============

## 地块尺寸
@export var tile_size: Vector2 = Vector2(80, 80)

## 边框宽度
@export var border_width: float = 2.0

## 圆角半径
@export var corner_radius: float = 8.0

## 圆角分段数（越大越平滑）
@export var corner_segments: int = 8

## 图标目标尺寸
@export var icon_size: Vector2 = Vector2(36, 36)

## hover 时的亮度倍数
@export var hover_brightness: float = 1.15


# ============ 颜色配置 ============

## 主颜色
var main_color: Color = Color.GRAY

## 边框颜色
var border_color: Color = Color(0.3, 0.3, 0.3, 0.8)

## 强调色
var accent_color: Color = Color.WHITE

## hover 颜色（用于边框发光）
var hover_color: Color = Color(1.0, 1.0, 1.0, 1.0)

## 背景透明度
var background_alpha: float = 0.15


# ============ 私有变量 ============

var _is_hovered: bool = false
var _inset_shader: Shader = null
var _shader_material: ShaderMaterial = null


# ============ 子节点引用 ============

@onready var _background: Sprite2D = $Background
@onready var _icon: Sprite2D = $Icon
@onready var _border: Line2D = $Border


# ============ 生命周期 ============

func _ready() -> void:
	_load_inset_shader()
	_setup_background()
	_setup_border()
	_setup_icon()


func _draw() -> void:
	# 如果没有子节点，直接绘制
	if not _background and not _border:
		_draw_background()
		_draw_border()


# ============ 初始化 ============

## 加载内凹 Shader
func _load_inset_shader() -> void:
	if ResourceLoader.exists(INSET_SHADER_PATH):
		_inset_shader = load(INSET_SHADER_PATH)
		if _inset_shader:
			_shader_material = ShaderMaterial.new()
			_shader_material.shader = _inset_shader
			_shader_material.set_shader_parameter("inset_size", 15.0)
			_shader_material.set_shader_parameter("corner_radius", corner_radius)


## 设置背景
func _setup_background() -> void:
	if not _background:
		return

	# 创建默认纹理（颜色会在 _update_colors 中设置）
	var image := Image.create(int(tile_size.x), int(tile_size.y), false, Image.FORMAT_RGBA8)
	image.fill(Color.GRAY)
	var texture := ImageTexture.create_from_image(image)
	_background.texture = texture

	# 应用内凹 Shader
	if _shader_material:
		_background.material = _shader_material


## 设置边框
func _setup_border() -> void:
	if not _border:
		return

	# 生成圆角矩形点
	_border.points = _generate_rounded_rect_points()
	_border.width = border_width
	_border.default_color = border_color
	_border.joint_mode = Line2D.LINE_JOINT_ROUND
	_border.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_border.end_cap_mode = Line2D.LINE_CAP_ROUND


## 生成圆角矩形的点
func _generate_rounded_rect_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	var half_size := tile_size / 2
	var r := minf(corner_radius, minf(half_size.x, half_size.y))  # 确保圆角不超过边长一半

	# 四个角的中心点
	var corners: Array[Vector2] = [
		Vector2(half_size.x - r, -half_size.y + r),   # 右上
		Vector2(half_size.x - r, half_size.y - r),    # 右下
		Vector2(-half_size.x + r, half_size.y - r),   # 左下
		Vector2(-half_size.x + r, -half_size.y + r),  # 左上
	]

	# 每个角的起始角度（弧度）
	var start_angles: Array[float] = [
		-PI / 2,  # 右上：从上边到右边
		0.0,      # 右下：从右边到下边
		PI / 2,   # 左下：从下边到左边
		PI,       # 左上：从左边到上边
	]

	# 起始点（上边起点）
	points.append(Vector2(-half_size.x + r, -half_size.y))

	# 绘制四条边和四个圆角
	for i in range(4):
		var corner: Vector2 = corners[i]
		var start_angle: float = start_angles[i]

		# 绘制直边到圆角起点
		match i:
			0:  # 上边 -> 右上角
				points.append(Vector2(half_size.x - r, -half_size.y))
			1:  # 右边 -> 右下角
				points.append(Vector2(half_size.x, half_size.y - r))
			2:  # 下边 -> 左下角
				points.append(Vector2(-half_size.x + r, half_size.y))
			3:  # 左边 -> 左上角
				points.append(Vector2(-half_size.x, -half_size.y + r))

		# 绘制圆角弧线
		for j in range(corner_segments + 1):
			var angle := start_angle + (PI / 2) * (float(j) / corner_segments)
			var point := corner + Vector2(cos(angle), sin(angle)) * r
			points.append(point)

	# 闭合路径
	points.append(Vector2(-half_size.x + r, -half_size.y))

	return points


## 设置图标
func _setup_icon() -> void:
	if not _icon:
		return
	# 图标使用原色，不修改 modulate


# ============ 颜色应用 ============

## 应用颜色配置
func apply_colors(p_main: Color, p_border: Color, p_accent: Color) -> void:
	main_color = p_main
	border_color = p_border
	accent_color = p_accent

	# 确保节点准备好后再更新颜色
	if not is_node_ready():
		await ready
	_update_colors()


## 设置 hover 颜色
func set_hover_color(color: Color) -> void:
	hover_color = color


## 更新颜色
func _update_colors() -> void:
	# 确保子节点引用有效
	if not _background:
		_background = get_node_or_null("Background")
	if not _icon:
		_icon = get_node_or_null("Icon")
	if not _border:
		_border = get_node_or_null("Border")

	# 背景使用图片纹理，不再填充纯色
	# 如果没有设置纹理，保持现有纹理
	if _background:
		# 应用内凹 Shader
		if _shader_material and not _background.material:
			_background.material = _shader_material

	if _border:
		if _is_hovered:
			_apply_hover_border()
		else:
			_border.default_color = border_color

	if _icon:
		# 图标不透明
		_icon.modulate = Color.WHITE

	queue_redraw()


## 通过 HSV 调暗颜色
func _darken_color(color: Color, value_multiplier: float) -> Color:
	var h := color.h
	var s := color.s
	var v := color.v * value_multiplier
	return Color.from_hsv(h, s, v, color.a)


## 设置图标纹理
func set_icon_texture(texture: Texture2D) -> void:
	# 确保 _icon 引用有效
	if not _icon:
		_icon = get_node_or_null("Icon")
	if _icon and texture:
		_icon.texture = texture
		_icon.modulate = Color.WHITE  # 不透明
		_apply_icon_scale()


## 应用图标缩放
func _apply_icon_scale() -> void:
	if not _icon or not _icon.texture:
		return
	var tex_size := _icon.texture.get_size()
	if tex_size.x > 0 and tex_size.y > 0:
		_icon.scale = icon_size / tex_size


## 根据地形类型设置背景纹理
func set_background_from_tile_type(tile_type: TileConstants.TileType) -> void:
	# 确保 _background 引用有效
	if not _background:
		_background = get_node_or_null("Background")
	if not _background:
		return

	var path := TileConstants.get_tile_bg_texture_path(tile_type)
	if ResourceLoader.exists(path):
		var texture := load(path) as Texture2D
		if texture:
			_background.texture = texture
			# 应用内凹 Shader
			if _shader_material and not _background.material:
				_background.material = _shader_material


## 从路径加载图标
func load_icon_from_path(path: String) -> void:
	if path.is_empty():
		return

	if ResourceLoader.exists(path):
		var texture := load(path) as Texture2D
		if texture:
			set_icon_texture(texture)


# ============ 直接绘制（后备方案）============

## 绘制背景
func _draw_background() -> void:
	var half_size := tile_size / 2
	var rect := Rect2(-half_size, tile_size)
	var bg_color := main_color
	bg_color.a = background_alpha
	draw_rect(rect, bg_color)


## 绘制边框
func _draw_border() -> void:
	var points := _generate_rounded_rect_points()
	var current_color := hover_color if _is_hovered else border_color
	draw_polyline(points, current_color, border_width)


# ============ 状态切换 ============

## 设置高亮状态
func set_highlighted(highlighted: bool) -> void:
	if highlighted:
		if _border:
			_border.default_color = accent_color
	else:
		if _border:
			_border.default_color = border_color

	queue_redraw()


## 设置悬停状态
func set_hovered(hovered: bool) -> void:
	_is_hovered = hovered

	if hovered:
		_apply_hover_border()
		modulate = Color(hover_brightness, hover_brightness, hover_brightness, 1.0)
	else:
		_restore_normal_border()
		modulate = Color.WHITE


## 应用 hover 边框效果
func _apply_hover_border() -> void:
	if _border:
		# 使用亮度 > 1.0 的颜色触发 Bloom
		var glow_color := hover_color
		glow_color.r *= HOVER_GLOW_ENERGY
		glow_color.g *= HOVER_GLOW_ENERGY
		glow_color.b *= HOVER_GLOW_ENERGY
		_border.default_color = glow_color


## 恢复正常边框
func _restore_normal_border() -> void:
	if _border:
		_border.default_color = border_color


# ============ 查询方法 ============

## 获取当前边框颜色
func get_current_border_color() -> Color:
	if _border:
		return _border.default_color
	return hover_color if _is_hovered else border_color


## 检查是否有图标纹理
func has_icon_texture() -> bool:
	return _icon and _icon.texture != null


## 获取图标透明度
func get_icon_opacity() -> float:
	if _icon:
		return _icon.modulate.a
	return 0.0


## 检查是否应用了内凹 Shader
func has_inset_shader() -> bool:
	if _background and _background.material:
		return _background.material is ShaderMaterial
	return _shader_material != null


## 设置内凹尺寸
func set_inset_size(size: float) -> void:
	if _shader_material:
		_shader_material.set_shader_parameter("inset_size", size)


## 获取内凹尺寸
func get_inset_size() -> float:
	if _shader_material:
		return _shader_material.get_shader_parameter("inset_size")
	return 0.0
