extends Node2D
class_name BattleCameraController

## 战斗相机控制器
## 处理战斗地图中的点击缩放功能
## 使用 Phantom Camera 插件实现平滑过渡


# ============ 信号 ============

## 开始缩放到目标位置时发射
signal zoom_started(target_position: Vector2)

## 缩放过渡完成时发射
signal zoom_completed()

## 重置缩放时发射
signal zoom_reset()


# ============ 常量 ============

const DEFAULT_PRIORITY: int = 0
const ZOOM_PRIORITY: int = 10
const ZOOMED_ZOOM: Vector2 = Vector2(1.5, 1.5)


# ============ 导出属性 ============

## 默认相机（未缩放状态）
@export var default_camera: PhantomCamera2D

## 缩放相机（缩放状态）
@export var zoom_camera: PhantomCamera2D

## 虚拟跟随目标节点
@export var follow_target: Node2D


# ============ 私有变量 ============

var _is_zoomed: bool = false
var _zoom_tween_connected: bool = false


# ============ 生命周期 ============

func _ready() -> void:
	_connect_zoom_camera_signals()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_handle_click(mouse_event.global_position)


# ============ 公共方法 ============

## 缩放到指定世界坐标位置
func zoom_to_position(world_position: Vector2) -> void:
	if not follow_target:
		push_error("[BattleCameraController] follow_target is null")
		return

	if not zoom_camera:
		push_error("[BattleCameraController] zoom_camera is null")
		return

	# 更新跟随目标位置
	follow_target.global_position = world_position

	# 激活缩放相机
	zoom_camera.priority = ZOOM_PRIORITY
	_is_zoomed = true

	# 发射信号
	zoom_started.emit(world_position)


## 重置缩放，返回默认相机视角
func reset_zoom() -> void:
	if not zoom_camera:
		push_error("[BattleCameraController] zoom_camera is null")
		return

	# 停用缩放相机
	zoom_camera.priority = DEFAULT_PRIORITY
	_is_zoomed = false

	# 发射信号
	zoom_reset.emit()


## 返回当前是否处于缩放状态
func is_zoomed() -> bool:
	return _is_zoomed


## 获取当前缩放目标位置
func get_current_zoom_position() -> Vector2:
	if follow_target:
		return follow_target.global_position
	return Vector2.ZERO


# ============ 私有方法 ============

## 处理鼠标点击事件
func _handle_click(screen_position: Vector2) -> void:
	# 将屏幕坐标转换为世界坐标
	var world_position := _screen_to_world(screen_position)

	if _is_zoomed:
		# 如果已经缩放，则重置
		reset_zoom()
	else:
		# 缩放到点击位置
		zoom_to_position(world_position)


## 屏幕坐标转世界坐标
func _screen_to_world(screen_position: Vector2) -> Vector2:
	var canvas_transform := get_canvas_transform()
	return canvas_transform.affine_inverse() * screen_position


## 连接缩放相机信号
func _connect_zoom_camera_signals() -> void:
	if not zoom_camera:
		return

	if not _zoom_tween_connected and not zoom_camera.tween_completed.is_connected(_on_zoom_tween_completed):
		zoom_camera.tween_completed.connect(_on_zoom_tween_completed)
		_zoom_tween_connected = true


## 缩放过渡完成回调
func _on_zoom_tween_completed() -> void:
	if _is_zoomed:
		zoom_completed.emit()
