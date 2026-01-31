# 通用状态机模板
# 使用方法：作为子节点添加到角色，将 State 节点作为状态机的子节点
class_name StateMachine
extends Node

## 信号
signal state_changed(from_state: StringName, to_state: StringName)

## 配置
@export var initial_state: State

## 内部变量
var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	await owner.ready

	# 收集所有 State 子节点
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self

	# 设置初始状态
	if initial_state:
		current_state = initial_state
		current_state.enter()
	elif states.size() > 0:
		current_state = states.values()[0]
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


## 状态转换
func transition_to(state_name: StringName) -> void:
	if not states.has(state_name):
		push_error("StateMachine: State not found: " + state_name)
		return

	if current_state and current_state.name == state_name:
		return  # 已经在该状态

	var previous_state_name := current_state.name if current_state else &""

	if current_state:
		current_state.exit()

	current_state = states[state_name]
	current_state.enter()

	state_changed.emit(previous_state_name, state_name)


## 查询方法
func get_current_state_name() -> StringName:
	return current_state.name if current_state else &""


func is_in_state(state_name: StringName) -> bool:
	return current_state and current_state.name == state_name


# =============================================================================
# 状态基类
# =============================================================================
class_name State
extends Node

## 引用
var state_machine: StateMachine


## 虚方法 - 子类重写

# 进入状态时调用
func enter() -> void:
	pass


# 退出状态时调用
func exit() -> void:
	pass


# 每帧调用（_process）
func update(_delta: float) -> void:
	pass


# 每物理帧调用（_physics_process）
func physics_update(_delta: float) -> void:
	pass


# 输入事件处理
func handle_input(_event: InputEvent) -> void:
	pass


## 辅助方法
func transition_to(state_name: StringName) -> void:
	state_machine.transition_to(state_name)
