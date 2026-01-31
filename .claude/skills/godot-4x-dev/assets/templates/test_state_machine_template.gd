# 状态机测试模板
# 用法：复制此模板，替换 <Character> 和状态名称
class_name Test<Character>StateMachine
extends GdUnitTestSuite

## 场景引用
var _scene: PackedScene
var _character: CharacterBody2D
var _state_machine: StateMachine


## 生命周期方法

func before() -> void:
	_scene = load("res://path/to/<character>.tscn")


func before_test() -> void:
	_character = auto_free(_scene.instantiate())
	add_child(_character)

	_state_machine = _character.get_node("StateMachine")

	await _character.ready


func after_test() -> void:
	_cleanup_input()


func _cleanup_input() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("attack")


## 初始状态测试

func test_initial_state_is_idle() -> void:
	assert_str(_state_machine.current_state.name).is_equal("Idle")


func test_idle_state_has_zero_velocity() -> void:
	assert_vector2(_character.velocity).is_equal(Vector2.ZERO)


## 状态转换测试

func test_idle_to_run_on_movement_input() -> void:
	# 初始状态
	assert_str(_state_machine.current_state.name).is_equal("Idle")

	# 模拟移动输入
	Input.action_press("move_right")
	await await_physics_frame()

	# 验证转换
	assert_str(_state_machine.current_state.name).is_equal("Run")

	Input.action_release("move_right")


func test_run_to_idle_on_stop() -> void:
	# 先进入 Run 状态
	Input.action_press("move_right")
	await await_physics_frame()
	assert_str(_state_machine.current_state.name).is_equal("Run")

	# 停止移动
	Input.action_release("move_right")
	await await_physics_frame()

	# 验证回到 Idle
	assert_str(_state_machine.current_state.name).is_equal("Idle")


func test_idle_to_jump_on_jump_input() -> void:
	# 确保在地面
	await _wait_until_grounded()

	# 跳跃
	Input.action_press("jump")
	await await_physics_frame()
	Input.action_release("jump")

	# 验证进入 Jump 状态
	assert_str(_state_machine.current_state.name).is_equal("Jump")


func test_jump_to_fall_when_descending() -> void:
	await _wait_until_grounded()

	# 跳跃
	Input.action_press("jump")
	await await_physics_frame()
	Input.action_release("jump")

	# 等待到达顶点开始下落
	await _wait_until_falling()

	assert_str(_state_machine.current_state.name).is_equal("Fall")


func test_fall_to_idle_on_landing() -> void:
	await _wait_until_grounded()

	# 跳跃
	Input.action_press("jump")
	await await_physics_frame()
	Input.action_release("jump")

	# 等待落地
	await _wait_until_grounded()

	assert_str(_state_machine.current_state.name).is_equal("Idle")


## 状态行为测试

func test_run_state_moves_character() -> void:
	var initial_x := _character.position.x

	Input.action_press("move_right")

	for i in 10:
		await await_physics_frame()

	Input.action_release("move_right")

	assert_float(_character.position.x).is_greater(initial_x)


func test_jump_state_applies_upward_velocity() -> void:
	await _wait_until_grounded()

	Input.action_press("jump")
	await await_physics_frame()
	Input.action_release("jump")

	assert_float(_character.velocity.y).is_less(0)


func test_run_state_flips_sprite() -> void:
	var sprite: Sprite2D = _character.get_node("Sprite2D")

	# 向右移动
	Input.action_press("move_right")
	await await_physics_frame()
	assert_bool(sprite.flip_h).is_false()
	Input.action_release("move_right")

	# 向左移动
	Input.action_press("move_left")
	await await_physics_frame()
	assert_bool(sprite.flip_h).is_true()
	Input.action_release("move_left")


## 信号测试

func test_state_change_emits_signal() -> void:
	Input.action_press("move_right")

	await assert_signal(_state_machine).is_emitted("state_changed")

	Input.action_release("move_right")


## 边界条件测试

func test_cannot_jump_while_airborne() -> void:
	await _wait_until_grounded()

	# 第一次跳跃
	Input.action_press("jump")
	await await_physics_frame()
	Input.action_release("jump")

	assert_str(_state_machine.current_state.name).is_equal("Jump")

	# 尝试二次跳跃
	Input.action_press("jump")
	await await_physics_frame()
	Input.action_release("jump")

	# 仍应处于 Jump 或 Fall 状态
	var state_name := _state_machine.current_state.name
	assert_bool(state_name == "Jump" or state_name == "Fall").is_true()


## 辅助方法

func _wait_until_grounded() -> void:
	while not _character.is_on_floor():
		await await_physics_frame()


func _wait_until_falling() -> void:
	while _character.velocity.y <= 0:
		await await_physics_frame()


func _wait_physics_frames(count: int) -> void:
	for i in count:
		await await_physics_frame()
