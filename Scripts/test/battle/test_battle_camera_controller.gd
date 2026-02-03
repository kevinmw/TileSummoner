class_name TestBattleCameraController
extends GdUnitTestSuite

## BattleCameraController 测试套件
## 测试范围：
## 1. 基础实例化和继承
## 2. 相机引用
## 3. 优先级设置
## 4. 缩放功能
## 5. 重置功能
## 6. 信号发射
## 7. 配置验证


# ============ 常量 ============

const DEFAULT_PRIORITY := 0
const ZOOM_PRIORITY := 10
const ZOOMED_ZOOM := Vector2(1.5, 1.5)
const DEFAULT_ZOOM := Vector2(1.0, 1.0)


# ============ 辅助方法 ============

## 创建测试用 BattleCameraController 实例（带完整场景结构）
func _create_controller_with_scene() -> BattleCameraController:
	# 创建根节点
	var root := Node2D.new()
	add_child(root)
	auto_free(root)

	# 创建 Camera2D
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	root.add_child(camera)

	# 创建跟随目标
	var follow_target := Node2D.new()
	follow_target.name = "CameraTargetMarker"
	root.add_child(follow_target)

	# 创建默认 PhantomCamera2D
	var default_pcam := PhantomCamera2D.new()
	default_pcam.name = "DefaultPCam"
	default_pcam.priority = DEFAULT_PRIORITY
	default_pcam.zoom = DEFAULT_ZOOM
	root.add_child(default_pcam)

	# 创建缩放 PhantomCamera2D
	var zoom_pcam := PhantomCamera2D.new()
	zoom_pcam.name = "ZoomPCam"
	zoom_pcam.priority = DEFAULT_PRIORITY
	zoom_pcam.zoom = ZOOMED_ZOOM
	zoom_pcam.follow_mode = PhantomCamera2D.FollowMode.SIMPLE
	zoom_pcam.follow_target = follow_target
	root.add_child(zoom_pcam)

	# 创建控制器
	var controller := BattleCameraController.new()
	controller.name = "BattleCameraController"
	controller.default_camera = default_pcam
	controller.zoom_camera = zoom_pcam
	controller.follow_target = follow_target
	root.add_child(controller)

	return controller


## 创建简单的控制器实例（无场景结构）
func _create_controller_simple() -> BattleCameraController:
	var controller := BattleCameraController.new()
	add_child(controller)
	auto_free(controller)
	return controller


# ============ 基础测试 (1-5) ============

## 测试1：控制器可实例化
func test_controller_instantiation() -> void:
	var controller := _create_controller_simple()

	assert_that(controller).is_not_null()


## 测试2：控制器继承 Node2D
func test_controller_extends_node2d() -> void:
	var controller := _create_controller_simple()

	assert_that(controller).is_instanceof(Node2D)


## 测试3：default_camera 引用存在
func test_default_camera_reference() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.default_camera).is_not_null()
	assert_that(controller.default_camera).is_instanceof(PhantomCamera2D)


## 测试4：zoom_camera 引用存在
func test_zoom_camera_reference() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.zoom_camera).is_not_null()
	assert_that(controller.zoom_camera).is_instanceof(PhantomCamera2D)


## 测试5：follow_target 引用存在
func test_follow_target_reference() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.follow_target).is_not_null()
	assert_that(controller.follow_target).is_instanceof(Node2D)


# ============ 优先级测试 (6-9) ============

## 测试6：默认相机优先级为 0
func test_default_camera_priority_is_zero() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.default_camera.priority).is_equal(DEFAULT_PRIORITY)


## 测试7：缩放相机优先级初始为 0
func test_zoom_camera_initial_priority_is_zero() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.zoom_camera.priority).is_equal(DEFAULT_PRIORITY)


## 测试8：缩放相机初始不激活
func test_zoom_camera_initially_not_active() -> void:
	var controller := _create_controller_with_scene()
	await await_idle_frame()

	# 缩放相机优先级为 0，与默认相机相同，但默认相机应该激活
	assert_that(controller.is_zoomed()).is_false()


## 测试9：默认状态下 is_zoomed 返回 false
func test_is_zoomed_returns_false_initially() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.is_zoomed()).is_false()


# ============ 缩放功能测试 (10-15) ============

## 测试10：zoom_to_position 更新跟随目标位置
func test_zoom_to_position_updates_follow_target() -> void:
	var controller := _create_controller_with_scene()
	var target_pos := Vector2(200, 300)

	controller.zoom_to_position(target_pos)

	assert_that(controller.follow_target.global_position).is_equal(target_pos)


## 测试11：zoom_to_position 激活缩放相机
func test_zoom_to_position_activates_zoom_camera() -> void:
	var controller := _create_controller_with_scene()

	controller.zoom_to_position(Vector2(100, 100))

	assert_that(controller.zoom_camera.priority).is_equal(ZOOM_PRIORITY)


## 测试12：缩放相机缩放级别为 1.5x
func test_zoom_camera_zoom_level() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.zoom_camera.zoom).is_equal(ZOOMED_ZOOM)


## 测试13：初始状态 is_zoomed 返回 false
func test_initial_is_zoomed_false() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.is_zoomed()).is_false()


## 测试14：缩放后 is_zoomed 返回 true
func test_is_zoomed_returns_true_after_zoom() -> void:
	var controller := _create_controller_with_scene()

	controller.zoom_to_position(Vector2(100, 100))

	assert_that(controller.is_zoomed()).is_true()


## 测试15：get_current_zoom_position 返回正确位置
func test_get_current_zoom_position() -> void:
	var controller := _create_controller_with_scene()
	var target_pos := Vector2(150, 250)

	controller.zoom_to_position(target_pos)

	assert_that(controller.get_current_zoom_position()).is_equal(target_pos)


# ============ 重置功能测试 (16-18) ============

## 测试16：reset_zoom 停用缩放相机
func test_reset_zoom_deactivates_zoom_camera() -> void:
	var controller := _create_controller_with_scene()

	controller.zoom_to_position(Vector2(100, 100))
	controller.reset_zoom()

	assert_that(controller.zoom_camera.priority).is_equal(DEFAULT_PRIORITY)


## 测试17：reset_zoom 后 is_zoomed 返回 false
func test_reset_zoom_is_zoomed_false() -> void:
	var controller := _create_controller_with_scene()

	controller.zoom_to_position(Vector2(100, 100))
	controller.reset_zoom()

	assert_that(controller.is_zoomed()).is_false()


## 测试18：reset_zoom 恢复默认相机
func test_reset_zoom_restores_default_camera() -> void:
	var controller := _create_controller_with_scene()

	controller.zoom_to_position(Vector2(100, 100))
	controller.reset_zoom()

	# 默认相机优先级应保持为 0
	assert_that(controller.default_camera.priority).is_equal(DEFAULT_PRIORITY)
	# 缩放相机优先级应回到 0
	assert_that(controller.zoom_camera.priority).is_equal(DEFAULT_PRIORITY)


# ============ 信号测试 (19-21) ============

## 测试19：zoom_to_position 发射 zoom_started 信号
func test_zoom_started_signal() -> void:
	var controller := _create_controller_with_scene()
	var target_pos := Vector2(200, 200)

	var monitor := monitor_signals(controller)
	controller.zoom_to_position(target_pos)

	assert_signal(monitor).is_emitted("zoom_started", [target_pos])


## 测试20：缩放完成发射 zoom_completed 信号
func test_zoom_completed_signal() -> void:
	var controller := _create_controller_with_scene()

	var monitor := monitor_signals(controller)
	controller.zoom_to_position(Vector2(100, 100))

	# 等待过渡完成（PhantomCamera 默认过渡时间）
	await await_millis(1500)

	assert_signal(monitor).is_emitted("zoom_completed")


## 测试21：reset_zoom 发射 zoom_reset 信号
func test_zoom_reset_signal() -> void:
	var controller := _create_controller_with_scene()
	controller.zoom_to_position(Vector2(100, 100))

	var monitor := monitor_signals(controller)
	controller.reset_zoom()

	assert_signal(monitor).is_emitted("zoom_reset")


# ============ 配置测试 (22-24) ============

## 测试22：缩放相机 follow_mode 为 SIMPLE
func test_zoom_camera_follow_mode() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.zoom_camera.follow_mode).is_equal(PhantomCamera2D.FollowMode.SIMPLE)


## 测试23：缩放相机有过渡资源
func test_zoom_camera_has_tween_resource() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.zoom_camera.tween_resource).is_not_null()


## 测试24：默认相机缩放为 1.0x
func test_default_camera_zoom_level() -> void:
	var controller := _create_controller_with_scene()

	assert_that(controller.default_camera.zoom).is_equal(DEFAULT_ZOOM)
