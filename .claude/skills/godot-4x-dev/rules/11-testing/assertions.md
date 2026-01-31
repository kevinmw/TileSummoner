# 断言方法速查

## 基础断言

### 布尔断言

```gdscript
assert_bool(value).is_true()
assert_bool(value).is_false()
assert_bool(value).is_equal(expected)
assert_bool(value).is_not_equal(expected)
```

### 整数断言

```gdscript
assert_int(value).is_equal(expected)
assert_int(value).is_not_equal(expected)
assert_int(value).is_less(expected)
assert_int(value).is_less_equal(expected)
assert_int(value).is_greater(expected)
assert_int(value).is_greater_equal(expected)
assert_int(value).is_between(from, to)
assert_int(value).is_zero()
assert_int(value).is_not_zero()
assert_int(value).is_negative()
assert_int(value).is_positive()
```

### 浮点数断言

```gdscript
assert_float(value).is_equal(expected)
assert_float(value).is_equal_approx(expected, tolerance)
assert_float(value).is_less(expected)
assert_float(value).is_greater(expected)
assert_float(value).is_between(from, to)
assert_float(value).is_zero()
assert_float(value).is_not_zero()
```

### 字符串断言

```gdscript
assert_str(value).is_equal(expected)
assert_str(value).is_not_equal(expected)
assert_str(value).is_empty()
assert_str(value).is_not_empty()
assert_str(value).contains(substring)
assert_str(value).not_contains(substring)
assert_str(value).starts_with(prefix)
assert_str(value).ends_with(suffix)
assert_str(value).has_length(length)
```

## 集合断言

### 数组断言

```gdscript
assert_array(array).is_empty()
assert_array(array).is_not_empty()
assert_array(array).has_size(size)
assert_array(array).contains(element)
assert_array(array).not_contains(element)
assert_array(array).contains_exactly([a, b, c])
assert_array(array).contains_same_elements([a, b, c])  # 忽略顺序
```

### 字典断言

```gdscript
assert_dict(dict).is_empty()
assert_dict(dict).is_not_empty()
assert_dict(dict).has_size(size)
assert_dict(dict).contains_key(key)
assert_dict(dict).contains_keys([key1, key2])
assert_dict(dict).contains_key_value(key, value)
```

## 对象断言

### 空值检查

```gdscript
assert_that(value).is_null()
assert_that(value).is_not_null()
```

### 类型检查

```gdscript
assert_object(object).is_instanceof(ClassName)
assert_object(object).is_not_instanceof(ClassName)
```

### 相等性

```gdscript
assert_object(object).is_equal(expected)
assert_object(object).is_not_equal(expected)
assert_object(object).is_same(expected)      # 引用相等
assert_object(object).is_not_same(expected)
```

## 向量断言

### Vector2

```gdscript
assert_vector2(vec).is_equal(expected)
assert_vector2(vec).is_equal_approx(expected, tolerance)
assert_vector2(vec).is_not_equal(expected)
```

### Vector3

```gdscript
assert_vector3(vec).is_equal(expected)
assert_vector3(vec).is_equal_approx(expected, tolerance)
assert_vector3(vec).is_not_equal(expected)
```

## 信号断言

### 基础信号

```gdscript
# 检查信号是否被发射
await assert_signal(object).is_emitted("signal_name")
await assert_signal(object).is_not_emitted("signal_name")

# 带参数检查
await assert_signal(object).is_emitted("signal_name", [arg1, arg2])
```

### 信号监控

```gdscript
func test_health_changed_signal() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 100

    # 开始监控信号
    var monitor := monitor_signals(health)

    health.take_damage(30)

    # 验证信号发射
    await assert_signal(health).is_emitted("health_changed")

    # 获取信号参数
    var args := monitor.get_signal_args("health_changed")
    assert_array(args).contains([70, 100])
```

### 超时控制

```gdscript
# 设置等待超时（默认 2000ms）
await assert_signal(object).wait_until(5000).is_emitted("signal_name")
```

## 异常断言

### 捕获错误

```gdscript
func test_invalid_input_throws_error() -> void:
    var callable := func():
        some_function(-1)  # 应该抛出错误

    await assert_error(callable).is_push_error("Invalid input")
```

### 无错误

```gdscript
func test_valid_input_no_error() -> void:
    var callable := func():
        some_function(10)

    await assert_error(callable).is_success()
```

## 自定义断言

### 链式断言

```gdscript
func test_player_stats() -> void:
    var player := auto_free(Player.new())

    assert_int(player.health).is_greater(0).is_less_equal(100)
    assert_str(player.name).is_not_empty().has_length(3)
```

### 自定义失败消息

```gdscript
func test_with_message() -> void:
    var value := get_some_value()

    assert_int(value)\
        .override_failure_message("值应该在有效范围内")\
        .is_between(0, 100)
```

## 常用断言模式

### 测试状态变化

```gdscript
func test_take_damage_reduces_health() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 100

    var initial := health.current_health

    health.take_damage(30)

    assert_int(health.current_health).is_less(initial)
    assert_int(health.current_health).is_equal(70)
```

### 测试边界条件

```gdscript
func test_health_boundaries() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100

    # 下边界
    health.current_health = 0
    health.take_damage(10)
    assert_int(health.current_health).is_equal(0)

    # 上边界
    health.current_health = 100
    health.heal(10)
    assert_int(health.current_health).is_equal(100)
```

### 测试集合内容

```gdscript
func test_inventory_operations() -> void:
    var inventory := auto_free(Inventory.new())

    inventory.add_item("sword")
    inventory.add_item("shield")

    assert_array(inventory.items)\
        .has_size(2)\
        .contains("sword")\
        .contains("shield")
```
