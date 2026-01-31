# 通用单元测试模板
# 用法：复制此模板，替换 <ClassName> 为实际类名
class_name Test<ClassName>
extends GdUnitTestSuite

## 被测试对象 (SUT = System Under Test)
var _sut: <ClassName>


## 生命周期方法

# 测试套件开始前执行一次
func before() -> void:
	pass


# 每个测试方法执行前
func before_test() -> void:
	_sut = auto_free(<ClassName>.new())
	# 初始化被测对象的属性
	# _sut.some_property = initial_value


# 每个测试方法执行后
func after_test() -> void:
	# auto_free 会自动清理，通常不需要额外代码
	pass


# 测试套件结束后执行一次
func after() -> void:
	pass


## 测试方法
## 命名格式：test_<行为>_<条件>_<预期结果>

# 示例：基础功能测试
func test_initial_state_is_correct() -> void:
	var instance := auto_free(<ClassName>.new())

	# assert_xxx(actual).is_equal(expected)
	pass


# 示例：行为测试
func test_method_name_does_expected_behavior() -> void:
	# Arrange - 准备
	# _sut 已在 before_test 中初始化

	# Act - 执行
	# _sut.method_to_test()

	# Assert - 断言
	# assert_xxx(_sut.property).is_equal(expected)
	pass


# 示例：边界条件测试
func test_method_with_zero_input_handles_correctly() -> void:
	# _sut.method(0)
	# assert_xxx(...).is_equal(...)
	pass


# 示例：异常情况测试
func test_method_with_invalid_input_does_nothing() -> void:
	# var initial := _sut.property
	# _sut.method(-1)  # 无效输入
	# assert_xxx(_sut.property).is_equal(initial)  # 状态未改变
	pass


# 示例：信号测试
func test_action_emits_signal() -> void:
	# _sut.some_action()
	# await assert_signal(_sut).is_emitted("signal_name")
	pass


# 示例：参数化测试
func test_parameterized(
	input: int,
	expected: int,
	test_parameters := [
		[10, 90],
		[50, 50],
		[100, 0],
	]
) -> void:
	# _sut.method(input)
	# assert_int(_sut.property).is_equal(expected)
	pass
