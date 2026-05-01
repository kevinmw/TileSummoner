extends CanvasLayer
class_name BattleBackground

## 战斗背景主控制器
## 管理宇宙背景、星空粒子、网格线装饰


# ============ 导出变量 - 背景颜色 ============

## 背景顶部颜色
@export var bg_color_top: Color = Color("#0a0a0f")

## 背景中部颜色
@export var bg_color_mid: Color = Color("#12110c")

## 背景底部颜色
@export var bg_color_bottom: Color = Color("#0d0d12")


# ============ 导出变量 - 光晕颜色 ============

## 虚空光晕颜色
@export var glow_void: Color = Color(0.42, 0.30, 0.60, 0.15)

## 法力光晕颜色
@export var glow_mana: Color = Color(0.16, 0.80, 0.87, 0.10)

## 金币光晕颜色
@export var glow_gold: Color = Color(0.87, 0.70, 0.16, 0.05)


# ============ 导出变量 - 网格线 ============

## 网格线颜色
@export var grid_line_color: Color = Color(0.87, 0.70, 0.16, 0.03)

## 网格线间距（像素）
@export var grid_line_spacing: int = 50


# ============ 导出变量 - 星点粒子 ============

## 星点数量
@export var star_count: int = 100

## 星点最小尺寸
@export var star_size_min: float = 1.0

## 星点最大尺寸
@export var star_size_max: float = 3.0

## 星点闪烁最小周期（秒）
@export var star_twinkle_min: float = 2.0

## 星点闪烁最大周期（秒）
@export var star_twinkle_max: float = 4.0


# ============ 内部变量 ============

## 视口尺寸
var viewport_size: Vector2 = Vector2(1280, 720)

## 是否正在动画
var _is_animating: bool = false


# ============ 子节点引用 ============

## 宇宙渐变背景
var _cosmic_background: ColorRect = null

## 星空粒子系统
var _starfield: Node2D = null

## 网格线覆盖层
var _grid_overlay: Node2D = null

## 边缘渐变遮罩
var _gradient_overlays: Control = null


# ============ 生命周期 ============

func _ready() -> void:
	# 设置层级为 -1（在所有游戏内容之后）
	layer = -1

	# 获取视口尺寸
	var vp := get_viewport()
	if vp:
		viewport_size = vp.get_visible_rect().size

	_setup_components()


# ============ 初始化 ============

## 设置所有组件
func _setup_components() -> void:
	_create_cosmic_background()
	_create_starfield()
	_create_grid_overlay()
	_create_gradient_overlays()


## 创建宇宙渐变背景
func _create_cosmic_background() -> void:
	_cosmic_background = ColorRect.new()
	_cosmic_background.name = "CosmicBackground"
	_cosmic_background.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 不阻挡鼠标事件
	add_child(_cosmic_background)

	_cosmic_background.size = viewport_size
	_cosmic_background.color = bg_color_mid

	# 创建渐变 shader
	var shader_material := _create_gradient_material()
	_cosmic_background.material = shader_material


## 创建渐变材质
func _create_gradient_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.04, 0.04, 0.06, 1.0);
uniform vec4 color_mid : source_color = vec4(0.07, 0.07, 0.05, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.05, 0.05, 0.07, 1.0);
uniform vec4 glow_void_color : source_color = vec4(0.42, 0.30, 0.60, 0.15);
uniform vec4 glow_mana_color : source_color = vec4(0.16, 0.80, 0.87, 0.10);

void fragment() {
	vec2 uv = UV;

	// 三段式垂直渐变
	vec4 color;
	if (uv.y < 0.4) {
		color = mix(color_top, color_mid, uv.y / 0.4);
	} else if (uv.y < 0.6) {
		color = color_mid;
	} else {
		color = mix(color_mid, color_bottom, (uv.y - 0.6) / 0.4);
	}

	// 添加微弱的径向光晕
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(uv, center);

	// 虚空光晕（中心）
	float void_glow = smoothstep(0.6, 0.0, dist) * glow_void_color.a;
	color.rgb += glow_void_color.rgb * void_glow;

	// 法力光晕（顶部）
	float mana_dist = distance(uv, vec2(0.5, 0.1));
	float mana_glow = smoothstep(0.5, 0.0, mana_dist) * glow_mana_color.a;
	color.rgb += glow_mana_color.rgb * mana_glow;

	COLOR = color;
}
"""

	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("color_top", bg_color_top)
	material.set_shader_parameter("color_mid", bg_color_mid)
	material.set_shader_parameter("color_bottom", bg_color_bottom)
	material.set_shader_parameter("glow_void_color", glow_void)
	material.set_shader_parameter("glow_mana_color", glow_mana)

	return material


## 创建星空粒子系统
func _create_starfield() -> void:
	_starfield = StarfieldParticles.new()
	_starfield.name = "Starfield"
	add_child(_starfield)

	# 配置星空参数
	_starfield.star_count = star_count
	_starfield.star_size_min = star_size_min
	_starfield.star_size_max = star_size_max
	_starfield.twinkle_min = star_twinkle_min
	_starfield.twinkle_max = star_twinkle_max
	_starfield.area_size = viewport_size


## 创建网格线覆盖层
func _create_grid_overlay() -> void:
	_grid_overlay = GridLinesOverlay.new()
	_grid_overlay.name = "GridLinesOverlay"
	add_child(_grid_overlay)

	_grid_overlay.line_color = grid_line_color
	_grid_overlay.spacing = grid_line_spacing
	_grid_overlay.area_size = viewport_size


## 创建边缘渐变遮罩
func _create_gradient_overlays() -> void:
	_gradient_overlays = Control.new()
	_gradient_overlays.name = "GradientOverlays"
	_gradient_overlays.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 不阻挡鼠标事件
	add_child(_gradient_overlays)

	# 顶部渐变
	var top_gradient := _create_edge_gradient(true)
	_gradient_overlays.add_child(top_gradient)

	# 底部渐变
	var bottom_gradient := _create_edge_gradient(false)
	_gradient_overlays.add_child(bottom_gradient)


## 创建边缘渐变
func _create_edge_gradient(is_top: bool) -> ColorRect:
	var gradient := ColorRect.new()
	gradient.size = Vector2(viewport_size.x, 100)
	gradient.mouse_filter = Control.MOUSE_FILTER_IGNORE  # 不阻挡鼠标事件

	if is_top:
		gradient.position = Vector2.ZERO
		gradient.color = Color(bg_color_top.r, bg_color_top.g, bg_color_top.b, 0.5)
	else:
		gradient.position = Vector2(0, viewport_size.y - 100)
		gradient.color = Color(bg_color_bottom.r, bg_color_bottom.g, bg_color_bottom.b, 0.5)

	return gradient


# ============ 配置方法 ============

## 设置背景颜色
func set_background_colors(top: Color, mid: Color, bottom: Color) -> void:
	bg_color_top = top
	bg_color_mid = mid
	bg_color_bottom = bottom

	if _cosmic_background and _cosmic_background.material:
		var mat := _cosmic_background.material as ShaderMaterial
		mat.set_shader_parameter("color_top", top)
		mat.set_shader_parameter("color_mid", mid)
		mat.set_shader_parameter("color_bottom", bottom)


## 设置网格线参数
func set_grid_line_params(color: Color, spacing: int) -> void:
	grid_line_color = color
	grid_line_spacing = spacing

	if _grid_overlay:
		_grid_overlay.line_color = color
		_grid_overlay.spacing = spacing
		_grid_overlay.queue_redraw()


## 设置星点参数
func set_star_params(count: int, size_min: float, size_max: float,
		twinkle_min: float = 2.0, twinkle_max: float = 4.0) -> void:
	star_count = count
	star_size_min = size_min
	star_size_max = size_max
	star_twinkle_min = twinkle_min
	star_twinkle_max = twinkle_max

	if _starfield:
		_starfield.star_count = count
		_starfield.star_size_min = size_min
		_starfield.star_size_max = size_max
		_starfield.twinkle_min = twinkle_min
		_starfield.twinkle_max = twinkle_max
		_starfield.regenerate()


## 设置视口尺寸
func set_viewport_size(size: Vector2) -> void:
	viewport_size = size

	if _cosmic_background:
		_cosmic_background.size = size
	if _starfield:
		_starfield.area_size = size
		_starfield.regenerate()
	if _grid_overlay:
		_grid_overlay.area_size = size
		_grid_overlay.queue_redraw()


# ============ 动画控制 ============

## 开始动画
func start_animations() -> void:
	_is_animating = true
	if _starfield:
		_starfield.start_twinkle()


## 停止动画
func stop_animations() -> void:
	_is_animating = false
	if _starfield:
		_starfield.stop_twinkle()


## 是否正在动画
func is_animating() -> bool:
	return _is_animating


# ============ 组件访问器 ============

## 获取宇宙背景
func get_cosmic_background() -> ColorRect:
	return _cosmic_background


## 获取星空粒子
func get_starfield() -> Node2D:
	return _starfield


## 获取网格覆盖层
func get_grid_overlay() -> Node2D:
	return _grid_overlay
