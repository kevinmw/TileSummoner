extends Node2D
class_name StarfieldParticles

## 星空粒子系统
## 使用程序化方式创建闪烁的星点效果


# ============ 导出变量 ============

## 星点数量
@export var star_count: int = 100

## 星点最小尺寸
@export var star_size_min: float = 1.0

## 星点最大尺寸
@export var star_size_max: float = 3.0

## 闪烁最小周期（秒）
@export var twinkle_min: float = 2.0

## 闪烁最大周期（秒）
@export var twinkle_max: float = 4.0

## 区域尺寸
@export var area_size: Vector2 = Vector2(1280, 720)

## 星点颜色
@export var star_color: Color = Color(1.0, 1.0, 0.95, 0.8)


# ============ 内部变量 ============

## 星点数据数组
var _stars: Array[Dictionary] = []

## 是否正在闪烁
var _is_twinkling: bool = false


# ============ 生命周期 ============

func _ready() -> void:
	regenerate()


func _process(delta: float) -> void:
	if _is_twinkling:
		_update_twinkle(delta)
		queue_redraw()


func _draw() -> void:
	for star in _stars:
		var pos: Vector2 = star.position
		var size: float = star.size * star.brightness
		var alpha: float = star.brightness

		var color := star_color
		color.a = alpha

		draw_circle(pos, size, color)


# ============ 星点管理 ============

## 重新生成星点
func regenerate() -> void:
	_stars.clear()

	for i in range(star_count):
		var star := _create_star()
		_stars.append(star)

	queue_redraw()


## 创建单个星点
func _create_star() -> Dictionary:
	return {
		"position": Vector2(
			randf() * area_size.x,
			randf() * area_size.y
		),
		"size": randf_range(star_size_min, star_size_max),
		"brightness": randf_range(0.3, 1.0),
		"twinkle_speed": randf_range(twinkle_min, twinkle_max),
		"twinkle_phase": randf() * TAU,
	}


## 更新闪烁
func _update_twinkle(delta: float) -> void:
	for star in _stars:
		star.twinkle_phase += delta * TAU / star.twinkle_speed
		if star.twinkle_phase > TAU:
			star.twinkle_phase -= TAU

		# 使用正弦波产生平滑的闪烁效果
		star.brightness = 0.3 + 0.7 * (0.5 + 0.5 * sin(star.twinkle_phase))


# ============ 动画控制 ============

## 开始闪烁
func start_twinkle() -> void:
	_is_twinkling = true


## 停止闪烁
func stop_twinkle() -> void:
	_is_twinkling = false
