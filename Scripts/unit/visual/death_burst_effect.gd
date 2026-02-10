# Scripts/unit/visual/death_burst_effect.gd
class_name DeathBurstEffect
extends Node2D

## 死亡爆散粒子效果
## 程序化粒子，从中心向外扩散然后消失

# ============ 信号 ============

signal finished

# ============ 配置 ============

## 粒子数量
@export var particle_count: int = 12

## 动画时长（秒）
@export var duration: float = 0.4

## 最小速度
@export var min_speed: float = 150.0

## 最大速度
@export var max_speed: float = 300.0

## 最小粒子大小
@export var min_size: float = 3.0

## 最大粒子大小
@export var max_size: float = 8.0

# ============ 状态 ============

## 粒子数据数组
var _particles: Array[Dictionary] = []

## 已播放时间
var _elapsed: float = 0.0

## 粒子颜色
var _color: Color = Color.WHITE

## 是否正在播放
var _is_playing: bool = false

# ============ 公共方法 ============

## 播放爆散效果
func play(color: Color) -> void:
	_color = color
	_generate_particles()
	_is_playing = true


# ============ 生命周期 ============

func _process(delta: float) -> void:
	if not _is_playing:
		return

	_elapsed += delta
	var progress := _elapsed / duration

	if progress >= 1.0:
		_is_playing = false
		finished.emit()
		return

	# 更新粒子
	for p in _particles:
		p.pos += p.vel * delta
		p.vel *= 0.95  # 减速
		p.alpha = 1.0 - progress
		p.size *= 0.98

	queue_redraw()


func _draw() -> void:
	if not _is_playing:
		return

	for p in _particles:
		var c := _color
		c.a = p.alpha
		draw_circle(p.pos, p.size, c)


# ============ 私有方法 ============

## 生成粒子
func _generate_particles() -> void:
	_particles.clear()
	for i in particle_count:
		var angle := randf() * TAU
		var speed := randf_range(min_speed, max_speed)
		_particles.append({
			"pos": Vector2.ZERO,
			"vel": Vector2.from_angle(angle) * speed,
			"size": randf_range(min_size, max_size),
			"alpha": 1.0
		})
