# 异步测试

## 等待帧

### await_idle_frame

```gdscript
func test_deferred_operation() -> void:
    var node := auto_free(Node.new())
    add_child(node)

    node.call_deferred("set_name", "NewName")

    # 等待下一帧
    await await_idle_frame()

    assert_str(node.name).is_equal("NewName")
```

### await_process_frame

```gdscript
func test_process_update() -> void:
    var player := auto_free(Player.new())
    add_child(player)

    player.start_moving()

    # 等待多帧
    for i in 10:
        await await_process_frame()

    assert_vector2(player.position).is_not_equal(Vector2.ZERO)
```

## 等待信号

### 基础信号等待

```gdscript
func test_signal_emission() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 100

    health.take_damage(30)

    await assert_signal(health).is_emitted("health_changed")
```

### 带超时的信号等待

```gdscript
func test_delayed_signal() -> void:
    var timer := auto_free(Timer.new())
    add_child(timer)
    timer.one_shot = true
    timer.wait_time = 0.5
    timer.start()

    # 等待信号，最多 1 秒
    await assert_signal(timer).wait_until(1000).is_emitted("timeout")
```

### 验证信号参数

```gdscript
func test_signal_with_args() -> void:
    var health := auto_free(HealthComponent.new())
    health.max_health = 100
    health.current_health = 100

    health.take_damage(30)

    # 验证信号参数
    await assert_signal(health).is_emitted("health_changed", [70, 100])
```

## 等待条件

### await_until

```gdscript
func test_state_transition() -> void:
    var enemy := auto_free(Enemy.new())
    add_child(enemy)

    enemy.start_patrol()

    # 等待状态变化
    await await_until(func(): return enemy.state == Enemy.State.PATROL, 2000)

    assert_int(enemy.state).is_equal(Enemy.State.PATROL)
```

### 自定义等待

```gdscript
func test_animation_completion() -> void:
    var player := auto_free(player_scene.instantiate())
    add_child(player)

    player.play_attack_animation()

    # 等待动画结束
    await player.animation_player.animation_finished

    assert_bool(player.is_attacking).is_false()
```

## 协程测试

### 测试异步函数

```gdscript
func test_async_load() -> void:
    var loader := auto_free(AsyncLoader.new())

    var result := await loader.load_data_async()

    assert_that(result).is_not_null()
    assert_dict(result).contains_key("data")
```

### 测试序列操作

```gdscript
func test_sequence() -> void:
    var sequence := auto_free(ActionSequence.new())
    add_child(sequence)

    sequence.add_action(MoveAction.new(Vector2(100, 0)))
    sequence.add_action(WaitAction.new(0.5))
    sequence.add_action(MoveAction.new(Vector2(0, 100)))

    sequence.start()
    await sequence.completed

    assert_vector2(sequence.position).is_equal_approx(Vector2(100, 100), 1.0)
```

## Timer 测试

### 模拟时间流逝

```gdscript
func test_cooldown() -> void:
    var ability := auto_free(Ability.new())
    ability.cooldown_time = 2.0
    add_child(ability)

    ability.use()
    assert_bool(ability.is_on_cooldown()).is_true()

    # 模拟时间流逝
    await get_tree().create_timer(2.1).timeout

    assert_bool(ability.is_on_cooldown()).is_false()
```

### 加速时间

```gdscript
func test_with_time_scale() -> void:
    var original_scale := Engine.time_scale
    Engine.time_scale = 10.0  # 加速 10 倍

    var timer_component := auto_free(TimerComponent.new())
    add_child(timer_component)
    timer_component.start(5.0)

    await timer_component.finished

    Engine.time_scale = original_scale
```

## 输入模拟

### 模拟按键

```gdscript
func test_jump_input() -> void:
    var player := auto_free(player_scene.instantiate())
    add_child(player)

    # 模拟按下跳跃键
    var event := InputEventKey.new()
    event.keycode = KEY_SPACE
    event.pressed = true
    Input.parse_input_event(event)

    await await_process_frame()

    assert_float(player.velocity.y).is_less(0)

    # 释放按键
    event.pressed = false
    Input.parse_input_event(event)
```

### 模拟动作

```gdscript
func test_move_input() -> void:
    var player := auto_free(player_scene.instantiate())
    add_child(player)

    # 模拟动作输入
    Input.action_press("move_right")

    for i in 10:
        await await_process_frame()

    Input.action_release("move_right")

    assert_float(player.position.x).is_greater(0)
```

## 测试超时

### 设置方法超时

```gdscript
# 参数形式设置超时（毫秒）
func test_long_operation(timeout := 5000) -> void:
    var result := await long_running_task()
    assert_that(result).is_not_null()
```

### 全局超时配置

```ini
# project.godot
[gdunit4]
settings/test/test_timeout=4000
```

## 常见模式

### 测试状态机转换

```gdscript
func test_state_machine_transitions() -> void:
    var fsm := auto_free(StateMachine.new())
    add_child(fsm)

    fsm.transition_to("Idle")
    await await_idle_frame()
    assert_str(fsm.current_state.name).is_equal("Idle")

    Input.action_press("move_right")
    await await_process_frame()

    assert_str(fsm.current_state.name).is_equal("Run")

    Input.action_release("move_right")
```

### 测试动画事件

```gdscript
func test_attack_animation_triggers_damage() -> void:
    var player := auto_free(player_scene.instantiate())
    var enemy := auto_free(enemy_scene.instantiate())
    add_child(player)
    add_child(enemy)

    var initial_health := enemy.health

    player.attack()
    await player.animation_player.animation_finished

    assert_int(enemy.health).is_less(initial_health)
```

## 最佳实践

1. **设置合理超时**: 避免测试无限等待
2. **清理输入状态**: 测试结束时释放所有按键
3. **使用 auto_free**: 确保节点被正确清理
4. **避免真实等待**: 尽可能模拟时间而非真实等待
