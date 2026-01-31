# 场景测试模板
# 用法：复制此模板，替换 <SceneName> 和场景路径
class_name Test<SceneName>Scene
extends GdUnitTestSuite

## 场景引用
var _scene: PackedScene
var _instance: Node


## 生命周期方法

func before() -> void:
	# 预加载场景（只执行一次）
	_scene = load("res://path/to/<scene_name>.tscn")


func before_test() -> void:
	# 每个测试创建新实例
	_instance = auto_free(_scene.instantiate())
	add_child(_instance)

	# 等待场景准备就绪
	await _instance.ready


func after_test() -> void:
	# 清理输入状态
	_cleanup_input()


func _cleanup_input() -> void:
	# 释放可能按下的按键
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")


## 场景结构测试

func test_scene_has_required_nodes() -> void:
	# 验证必要子节点存在
	assert_that(_instance.get_node_or_null("Sprite2D")).is_not_null()
	assert_that(_instance.get_node_or_null("CollisionShape2D")).is_not_null()
	# 添加更多节点检查...


func test_scene_initial_state() -> void:
	# 验证初始状态
	# assert_vector2(_instance.position).is_equal(Vector2.ZERO)
	# assert_int(_instance.health).is_equal(_instance.max_health)
	pass


## 输入测试

func test_input_moves_character() -> void:
	# 模拟按键输入
	Input.action_press("move_right")

	# 等待多个物理帧
	for i in 5:
		await await_physics_frame()

	Input.action_release("move_right")

	# 验证移动
	assert_float(_instance.velocity.x).is_greater(0)


func test_jump_input() -> void:
	# 确保在地面
	await await_physics_frame()

	# 模拟跳跃
	Input.action_press("jump")
	await await_physics_frame()
	Input.action_release("jump")

	# 验证跳跃
	assert_float(_instance.velocity.y).is_less(0)


## 碰撞测试

func test_collision_with_enemy() -> void:
	# 创建敌人
	# var enemy := auto_free(enemy_scene.instantiate())
	# add_child(enemy)
	# enemy.position = _instance.position

	# await await_physics_frame()
	# await await_physics_frame()

	# 验证碰撞效果
	# assert_int(_instance.health).is_less(initial_health)
	pass


## 动画测试

func test_animation_plays_on_action() -> void:
	# 获取动画播放器
	# var anim: AnimationPlayer = _instance.get_node("AnimationPlayer")

	# 触发动作
	# _instance.attack()

	# 验证动画
	# assert_str(anim.current_animation).is_equal("attack")
	pass


func test_animation_completion() -> void:
	# var anim: AnimationPlayer = _instance.get_node("AnimationPlayer")

	# _instance.play_animation("some_animation")
	# await anim.animation_finished

	# 验证动画后的状态
	pass


## 信号测试

func test_scene_emits_signal() -> void:
	# await assert_signal(_instance).is_emitted("signal_name")
	pass


## 物理帧辅助方法

func _wait_physics_frames(count: int) -> void:
	for i in count:
		await await_physics_frame()


## 输入模拟辅助方法

func _simulate_key_press(keycode: int) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	Input.parse_input_event(event)


func _simulate_key_release(keycode: int) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = false
	Input.parse_input_event(event)


func _simulate_mouse_click(position: Vector2, button: int = MOUSE_BUTTON_LEFT) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	event.position = position
	get_viewport().push_input(event)

	await await_idle_frame()

	event.pressed = false
	get_viewport().push_input(event)
