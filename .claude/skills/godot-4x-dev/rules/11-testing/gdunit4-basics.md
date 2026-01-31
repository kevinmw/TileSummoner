# GDUnit4 基础

## 简介

GDUnit4 是 Godot 4.x 的单元测试框架，支持 GDScript 测试。

## 安装

### 通过 AssetLib 安装

1. 在 Godot 编辑器中打开 AssetLib
2. 搜索 "GDUnit4"
3. 下载并安装到项目

### 手动安装

```
addons/
└── gdUnit4/
```

## 项目配置

### project.godot

```ini
[addons]
gdunit4/enabled=true

[gdunit4]
settings/test/test_root="res://tests"
```

## 测试生命周期

```gdscript
class_name TestExample
extends GdUnitTestSuite

# 测试套件开始前执行一次
func before() -> void:
    pass

# 每个测试方法执行前
func before_test() -> void:
    pass

# 每个测试方法执行后
func after_test() -> void:
    pass

# 测试套件结束后执行一次
func after() -> void:
    pass

# 测试方法
func test_example() -> void:
    assert_bool(true).is_true()
```

## 生命周期执行顺序

```
before()                 # 1次
├── before_test()        # 每个测试前
│   └── test_xxx()
│   └── after_test()     # 每个测试后
├── before_test()
│   └── test_yyy()
│   └── after_test()
after()                  # 1次
```

## 运行测试

### 通过编辑器

- 使用 GDUnit4 面板运行
- 右键测试文件 → Run Tests

### 通过命令行

```bash
# 运行所有测试
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests

# 运行特定测试
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests=res://tests/unit/
```

### 通过 MCP 工具

```
godot_run_tests              # 运行所有测试
godot_run_test_file <path>   # 运行特定测试文件
godot_get_test_coverage      # 获取覆盖率报告
```

## 测试套件类

```gdscript
class_name TestPlayerHealth
extends GdUnitTestSuite

# 被测试的对象
var _health_component: HealthComponent

func before_test() -> void:
    _health_component = HealthComponent.new()
    _health_component.max_health = 100
    _health_component.current_health = 100

func after_test() -> void:
    _health_component.free()

func test_take_damage_reduces_health() -> void:
    _health_component.take_damage(30)
    assert_int(_health_component.current_health).is_equal(70)

func test_take_damage_cannot_go_below_zero() -> void:
    _health_component.take_damage(150)
    assert_int(_health_component.current_health).is_equal(0)
```

## 跳过测试

```gdscript
# 跳过单个测试
func test_not_ready_yet() -> void:
    skip("功能未实现")

# 条件跳过
func test_platform_specific() -> void:
    if OS.get_name() != "Windows":
        skip("仅 Windows 平台")
    # 测试代码...
```

## 测试超时

```gdscript
# 设置超时（毫秒）
func test_long_operation(timeout := 5000) -> void:
    await get_tree().create_timer(2.0).timeout
    assert_bool(true).is_true()
```

## 参数化测试

```gdscript
func test_damage_values(
    damage: int,
    expected: int,
    test_parameters := [
        [10, 90],
        [50, 50],
        [100, 0],
        [150, 0]
    ]
) -> void:
    var health := HealthComponent.new()
    health.max_health = 100
    health.current_health = 100

    health.take_damage(damage)

    assert_int(health.current_health).is_equal(expected)
    health.free()
```

## MCP 工具

| 工具 | 说明 |
|------|------|
| `godot_run_tests` | 运行项目所有测试 |
| `godot_run_test_file` | 运行指定测试文件 |
| `godot_generate_test` | 为脚本生成测试桩 |
| `godot_get_test_coverage` | 获取测试覆盖率 |
