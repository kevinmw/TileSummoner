extends Node2D
class_name BattleTile

## 战斗地块节点
## 用于战斗场景中的地块实体
## 与 Tile (Control) 共享 TileBlockData 数据源


# ============ 信号 ============

## 地块被点击
signal tile_clicked(tile: BattleTile)

## 鼠标进入
signal tile_hovered(tile: BattleTile)

## 鼠标离开
signal tile_unhovered(tile: BattleTile)

## 单位进入地块
signal unit_entered(tile: BattleTile, unit: Node2D)

## 单位离开地块
signal unit_exited(tile: BattleTile, unit: Node2D)

## 虚空状态变更
signal void_state_changed(tile: BattleTile, is_void: bool)


# ============ 导出变量 ============

## 地块尺寸（像素）
@export var tile_size: Vector2 = Vector2(80, 80)

## 边框宽度
@export var border_width: float = 2.0

## 默认边框颜色
@export var default_border_color: Color = Color(0.3, 0.3, 0.3, 0.8)

## 入场动画：持续时间（秒）
@export var spawn_duration: float = 0.3

## 入场动画：初始缩放比例
@export var spawn_initial_scale: float = 0.0


# ============ 核心属性 ============

## 地块数据引用
var _data: TileBlockData = null

## 网格坐标
var grid_position: Vector2i = Vector2i.ZERO

## 虚空状态
var is_void: bool = false

## 可通行性
var is_passable: bool = true

## 当前站立单位
var occupying_unit: Node2D = null

## Tween 引用
var _tween: Tween = null


# ============ 子节点引用 ============

## 视觉层
@onready var _visual: Node2D = $Visual

## 碰撞区域
@onready var _collision: Area2D = $Collision

## 特效挂载点
@onready var _effects: Node2D = $Effects


# ============ 生命周期 ============

func _ready() -> void:
	_setup_collision()
	_setup_input()


func _exit_tree() -> void:
	if _tween:
		_tween.kill()


# ============ 初始化 ============

## 设置碰撞检测
func _setup_collision() -> void:
	if not _collision:
		return

	# 配置碰撞层
	# Layer 1: 地块
	# Mask 2: 检测单位
	_collision.collision_layer = 1
	_collision.collision_mask = 2

	# 连接信号
	if not _collision.body_entered.is_connected(_on_body_entered):
		_collision.body_entered.connect(_on_body_entered)
	if not _collision.body_exited.is_connected(_on_body_exited):
		_collision.body_exited.connect(_on_body_exited)


## 设置输入处理
func _setup_input() -> void:
	if not _collision:
		return

	if not _collision.input_event.is_connected(_on_area_input_event):
		_collision.input_event.connect(_on_area_input_event)
	if not _collision.mouse_entered.is_connected(_on_mouse_entered):
		_collision.mouse_entered.connect(_on_mouse_entered)
	if not _collision.mouse_exited.is_connected(_on_mouse_exited):
		_collision.mouse_exited.connect(_on_mouse_exited)


# ============ 数据接口（与 Tile 兼容）============

## 设置地块数据
func set_data(data: TileBlockData) -> void:
	_data = data
	# 延迟到节点准备好后再应用视觉效果
	if not is_node_ready():
		await ready
	_apply_visual_from_data()


## 获取地块数据
func get_data() -> TileBlockData:
	return _data


## 获取地块类型
func get_tile_type() -> TileConstants.TileType:
	if _data:
		return _data.tile_type
	return TileConstants.TileType.GRASSLAND


## 获取网格坐标
func get_grid_position() -> Vector2i:
	return grid_position


## 设置网格坐标
func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos


# ============ 虚空状态 ============

## 设置虚空状态
func set_void(void_state: bool) -> void:
	if is_void == void_state:
		return

	is_void = void_state
	is_passable = not void_state

	void_state_changed.emit(self, is_void)

	_update_void_visual()


## 更新虚空视觉效果
func _update_void_visual() -> void:
	if not _effects:
		return

	if is_void:
		_spawn_void_effect()
	else:
		_remove_void_effect()


## 生成虚空特效
func _spawn_void_effect() -> void:
	var void_effect := VoidTileEffect.new()
	void_effect.set_size(tile_size)
	_effects.add_child(void_effect)
	void_effect.play_intro()


## 移除虚空特效
func _remove_void_effect() -> void:
	for child in _effects.get_children():
		if child.has_method("is_void_effect"):
			child.queue_free()


# ============ 单位占用 ============

## 检查是否被占用
func is_occupied() -> bool:
	return occupying_unit != null


## 设置占用单位
func set_occupying_unit(unit: Node2D) -> void:
	if occupying_unit == unit:
		return

	var _old_unit := occupying_unit
	occupying_unit = unit

	if unit:
		unit_entered.emit(self, unit)


## 清除占用单位
func clear_occupying_unit() -> void:
	if not occupying_unit:
		return

	var old_unit := occupying_unit
	occupying_unit = null
	unit_exited.emit(self, old_unit)


# ============ 视觉更新 ============

## 从数据应用视觉效果
func _apply_visual_from_data() -> void:
	if not _data:
		return

	# 更新动画参数
	if _data.spawn_duration > 0:
		spawn_duration = _data.spawn_duration
	if _data.spawn_initial_scale >= 0:
		spawn_initial_scale = _data.spawn_initial_scale

	# 视觉更新由 BattleTileVisual 子节点处理
	_update_visual_colors()


## 更新视觉颜色
func _update_visual_colors() -> void:
	# 确保 _visual 引用有效
	if not _visual:
		_visual = get_node_or_null("Visual")

	if not _visual or not _data:
		return

	# 设置背景图片
	if _visual.has_method("set_background_from_tile_type"):
		_visual.set_background_from_tile_type(_data.tile_type)

	# 如果有 BattleTileVisual 脚本，调用其更新方法
	if _visual.has_method("apply_colors"):
		_visual.apply_colors(_data.main_color, _data.border_color, _data.accent_color)

	# 设置 hover 颜色
	if _visual.has_method("set_hover_color"):
		_visual.set_hover_color(_data.hover_color)

	# 加载图标
	if _visual.has_method("load_icon_from_path") and not _data.icon_path.is_empty():
		_visual.load_icon_from_path(_data.icon_path)


# ============ 动画 ============

## 播放入场动画（缩放弹出效果）
func play_spawn_animation(delay: float = 0.0) -> void:
	if _tween:
		_tween.kill()

	# 初始状态
	scale = Vector2.ONE * spawn_initial_scale
	modulate.a = 0.0

	if delay > 0:
		await get_tree().create_timer(delay).timeout

	_tween = create_tween()
	_tween.set_parallel(true)

	# 缩放动画（弹性效果）
	_tween.tween_property(self, "scale", Vector2.ONE, spawn_duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

	# 透明度动画（快速淡入）
	_tween.tween_property(self, "modulate:a", 1.0, spawn_duration * 0.5)\
		.set_ease(Tween.EASE_OUT)


# ============ 信号发射辅助方法（用于测试）============

## 发射点击信号
func emit_clicked() -> void:
	tile_clicked.emit(self)


## 发射悬停信号
func emit_hovered() -> void:
	tile_hovered.emit(self)


## 发射取消悬停信号
func emit_unhovered() -> void:
	tile_unhovered.emit(self)


# ============ 输入事件处理 ============

## Area2D 输入事件
func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			tile_clicked.emit(self)


## 鼠标进入
func _on_mouse_entered() -> void:
	tile_hovered.emit(self)
	# 通知 Visual 更新悬停状态
	if _visual and _visual.has_method("set_hovered"):
		_visual.set_hovered(true)


## 鼠标离开
func _on_mouse_exited() -> void:
	tile_unhovered.emit(self)
	# 通知 Visual 更新悬停状态
	if _visual and _visual.has_method("set_hovered"):
		_visual.set_hovered(false)


# ============ 碰撞事件处理 ============

## 物体进入
func _on_body_entered(body: Node2D) -> void:
	# 检查是否为单位
	if body.is_in_group("units"):
		set_occupying_unit(body)


## 物体离开
func _on_body_exited(body: Node2D) -> void:
	if body == occupying_unit:
		clear_occupying_unit()
