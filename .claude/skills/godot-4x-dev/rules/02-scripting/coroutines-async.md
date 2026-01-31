# 协程与异步

## await 基础

`await` 暂停函数执行，直到信号发射或协程完成。

```gdscript
func play_death_sequence() -> void:
    # 等待动画完成
    animation_player.play("death")
    await animation_player.animation_finished

    # 等待 2 秒
    await get_tree().create_timer(2.0).timeout

    # 重新开始游戏
    get_tree().reload_current_scene()
```

## 等待信号

```gdscript
# 等待任意信号
await some_node.some_signal

# 等待带参数的信号
await health_component.died

# 等待按钮点击
await $Button.pressed

# 等待场景树信号
await get_tree().process_frame  # 下一帧
await get_tree().physics_frame  # 下一物理帧
```

## 等待时间

```gdscript
# 使用 SceneTree 定时器
await get_tree().create_timer(1.5).timeout

# 创建可控定时器
var timer := get_tree().create_timer(2.0)
await timer.timeout
```

## 协程函数

```gdscript
# 返回值的协程
func load_game_async() -> bool:
    show_loading_screen()

    await get_tree().create_timer(0.5).timeout
    var data = load_save_file()

    await get_tree().create_timer(0.5).timeout
    apply_save_data(data)

    hide_loading_screen()
    return true

# 调用协程
func _on_load_button_pressed() -> void:
    var success: bool = await load_game_async()
    if success:
        print("Game loaded!")
```

## 常见模式

### 顺序动画

```gdscript
func intro_sequence() -> void:
    await fade_in_title()
    await get_tree().create_timer(1.0).timeout
    await show_menu_items()
    enable_input()

func fade_in_title() -> void:
    var tween := create_tween()
    tween.tween_property($Title, "modulate:a", 1.0, 0.5)
    await tween.finished
```

### 等待多个条件

```gdscript
# 等待任一信号
func wait_for_any() -> void:
    var result = await Promise.race([
        button_a.pressed,
        button_b.pressed,
        get_tree().create_timer(5.0).timeout
    ])
```

### 对话系统

```gdscript
func show_dialog(texts: Array[String]) -> void:
    dialog_box.visible = true

    for text in texts:
        dialog_label.text = ""
        for character in text:
            dialog_label.text += character
            await get_tree().create_timer(0.03).timeout

        # 等待玩家按键继续
        await continue_pressed

    dialog_box.visible = false

signal continue_pressed

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        continue_pressed.emit()
```

### 敌人 AI 行为

```gdscript
func ai_behavior() -> void:
    while is_alive:
        await patrol()
        if target_in_range():
            await chase_target()
            await attack()
        await get_tree().create_timer(0.5).timeout

func patrol() -> void:
    # 移动到巡逻点
    move_to(patrol_points[current_point])
    await navigation_agent.navigation_finished
    current_point = (current_point + 1) % patrol_points.size()
```

## 注意事项

```gdscript
# ⚠️ 协程中节点可能被删除
func delayed_action() -> void:
    await get_tree().create_timer(2.0).timeout
    # 检查节点是否仍有效
    if not is_instance_valid(self):
        return
    do_something()

# ⚠️ 避免无限等待
func wait_with_timeout() -> void:
    var timer := get_tree().create_timer(5.0)
    # 使用 Promise 模式或检查条件
    while not condition_met and not timer.time_left <= 0:
        await get_tree().process_frame

# ⚠️ 协程不能在 _init 中使用
# _init 中不能使用 await
```

## Tween 与 await

```gdscript
func animate_ui() -> void:
    var tween := create_tween()
    tween.tween_property($Panel, "position", target_pos, 0.3)
    tween.tween_property($Panel, "modulate:a", 1.0, 0.2)
    await tween.finished

    print("Animation complete!")
```
