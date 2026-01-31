# Mock 与 Stub 技术

## 概念区分

| 技术 | 用途 | 验证方式 |
|------|------|----------|
| **Mock** | 替换依赖，验证交互 | 验证方法被调用 |
| **Stub** | 提供预设返回值 | 不验证调用 |
| **Spy** | 监控真实对象 | 记录调用历史 |

## Mock 创建

### 基础 Mock

```gdscript
func test_player_uses_weapon() -> void:
    # 创建 Weapon 的 Mock
    var mock_weapon := mock(Weapon)

    var player := auto_free(Player.new())
    player.weapon = mock_weapon

    player.attack()

    # 验证 attack 方法被调用
    verify(mock_weapon).attack()
```

### Mock 配置

```gdscript
func test_weapon_damage() -> void:
    var mock_weapon := mock(Weapon)

    # 配置返回值
    do_return(50).on(mock_weapon).get_damage()

    var player := auto_free(Player.new())
    player.weapon = mock_weapon

    var damage := player.calculate_attack_damage()

    assert_int(damage).is_equal(50)
```

## Stub 使用

### 返回固定值

```gdscript
func test_with_stub() -> void:
    var stub_service := mock(DataService)

    # Stub: 返回预设数据
    do_return({"name": "Player", "level": 10}).on(stub_service).load_data()

    var player := auto_free(Player.new())
    player.data_service = stub_service
    player.load_from_service()

    assert_str(player.name).is_equal("Player")
    assert_int(player.level).is_equal(10)
```

### 返回不同值

```gdscript
func test_sequential_returns() -> void:
    var stub_rng := mock(RandomService)

    # 每次调用返回不同值
    do_return(1).on(stub_rng).get_random()
    do_return(5).on(stub_rng).get_random()
    do_return(3).on(stub_rng).get_random()

    assert_int(stub_rng.get_random()).is_equal(1)
    assert_int(stub_rng.get_random()).is_equal(5)
    assert_int(stub_rng.get_random()).is_equal(3)
```

## Spy 监控

### 监控真实对象

```gdscript
func test_with_spy() -> void:
    var real_weapon := Weapon.new()
    var spy_weapon := spy(real_weapon)

    var player := auto_free(Player.new())
    player.weapon = spy_weapon

    player.attack()
    player.attack()

    # 验证调用次数
    verify(spy_weapon, 2).attack()

    spy_weapon.free()
```

## 验证调用

### 验证方法被调用

```gdscript
# 至少调用一次
verify(mock).some_method()

# 调用指定次数
verify(mock, 2).some_method()

# 从未调用
verify(mock, 0).some_method()
verify_no_interactions(mock)
```

### 验证参数

```gdscript
func test_damage_calculation() -> void:
    var mock_target := mock(Enemy)

    var player := auto_free(Player.new())
    player.attack_target(mock_target, 50)

    # 验证方法使用特定参数调用
    verify(mock_target).take_damage(50)
```

### 参数匹配器

```gdscript
# 任意值
verify(mock).method(any())

# 任意整数
verify(mock).method(any_int())

# 任意字符串
verify(mock).method(any_string())

# 大于某值
verify(mock).method(arg_that(func(x): return x > 10))
```

## 常见模式

### 隔离外部依赖

```gdscript
# 被测试类依赖网络服务
class_name TestPlayerSync
extends GdUnitTestSuite

var _player: Player
var _mock_network: NetworkService

func before_test() -> void:
    _mock_network = mock(NetworkService)
    _player = auto_free(Player.new())
    _player.network = _mock_network

func test_sync_sends_position() -> void:
    _player.position = Vector2(100, 200)

    _player.sync_to_server()

    verify(_mock_network).send_position(Vector2(100, 200))
```

### 模拟异步操作

```gdscript
func test_async_load() -> void:
    var mock_loader := mock(ResourceLoader)

    # 模拟异步返回
    do_return(preload("res://test_resource.tres")).on(mock_loader).load_async()

    var manager := auto_free(ResourceManager.new())
    manager.loader = mock_loader

    var result := await manager.load_resource("test")

    assert_that(result).is_not_null()
```

### 验证信号触发调用

```gdscript
func test_signal_triggers_handler() -> void:
    var emitter := auto_free(SignalEmitter.new())
    var mock_handler := mock(SignalHandler)

    emitter.something_happened.connect(mock_handler.on_something)

    emitter.trigger_something()

    verify(mock_handler).on_something()
```

## 最佳实践

### 只 Mock 边界

```gdscript
# 好：Mock 外部服务
var mock_api := mock(ExternalAPI)

# 避免：Mock 被测试的类本身
# var mock_player := mock(Player)  # 不要这样
```

### Mock 接口而非实现

```gdscript
# 定义接口
class_name IDataStorage
extends RefCounted

func save(_data: Dictionary) -> bool:
    return false

func load() -> Dictionary:
    return {}

# Mock 接口
var mock_storage := mock(IDataStorage)
```

### 清理 Mock

```gdscript
func after_test() -> void:
    # GDUnit4 的 auto_free 会自动清理
    # 手动创建的 mock 需要 free()
    pass
```

## Mock 限制

- 不能 Mock `static` 方法
- 不能 Mock `final` 类
- 不能 Mock 内置类型（int, String 等）
- 节点 Mock 需要添加到场景树才能接收生命周期回调
