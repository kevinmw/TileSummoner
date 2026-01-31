---
name: godot-4x-dev
description: Godot 4.x game development patterns and best practices. Activates for GDScript (.gd), scenes (.tscn), resources (.tres).
---

# Godot 4.x 开发指南

## 知识索引

### 核心规范
- [项目结构](rules/00-core/project-structure.md) | [命名规范](rules/00-core/naming-conventions.md) | [GDScript风格](rules/00-core/gdscript-style.md)

### 基础概念
- [节点与场景](rules/01-fundamentals/nodes-and-scenes.md) | [信号系统](rules/01-fundamentals/signals.md)
- [资源管理](rules/01-fundamentals/resources.md) | [全局单例](rules/01-fundamentals/autoloads.md)

### GDScript
- [类型提示](rules/02-scripting/type-hints.md) | [@export](rules/02-scripting/export-vars.md) | [@onready](rules/02-scripting/onready-pattern.md)
- [枚举常量](rules/02-scripting/enums-constants.md) | [协程](rules/02-scripting/coroutines-async.md)

### 游戏开发
- **2D**: [精灵动画](rules/03-2d/sprite-animation.md) | [角色控制](rules/03-2d/characterbody2d.md) | [TileMap](rules/03-2d/tilemap.md)
- **3D**: [角色控制](rules/04-3d/characterbody3d.md) | [刚体](rules/04-3d/rigidbody3d.md) | [相机](rules/04-3d/camera3d.md)
- **UI**: [Control节点](rules/05-ui/control-nodes.md) | [容器](rules/05-ui/containers.md) | [主题](rules/05-ui/themes.md)

### 设计模式
- [状态机](rules/09-patterns/state-machine.md) | [对象池](rules/09-patterns/object-pooling.md) | [组件系统](rules/09-patterns/component-system.md)

### 测试 (GDUnit4)
- [GDUnit4 基础](rules/11-testing/gdunit4-basics.md) | [测试结构](rules/11-testing/test-structure.md) | [TDD 工作流](rules/11-testing/tdd-workflow.md)
- [断言方法](rules/11-testing/assertions.md) | [Mock/Stub](rules/11-testing/mocking-stubbing.md)
- [异步测试](rules/11-testing/async-testing.md) | [场景测试](rules/11-testing/scene-testing.md)

## MCP 工具集成

### 场景与项目操作
- **godot-mcp**: `create_scene`, `add_node`, `save_scene`, `run_project`, `stop_project`, `get_debug_output`

### 代码质量检查
- **godot-ultimate**: `lint_file`, `lint_project`, `validate_code`, `auto_fix`, `format_file`

### 项目分析
- **godot-ultimate**: `project_health`, `detect_dead_code`, `analyze_signal_flow`, `complexity_heatmap`, `validate_scenes`, `analyze_dependencies`

### 测试
- **godot-ultimate**: `run_tests`, `run_test_file`, `generate_test`, `get_test_coverage`

详细用法：
| 工具 | 说明 | 使用场景 |
|------|------|----------|
| `godot_generate_test` | 为源文件生成测试桩 | TDD RED 阶段 |
| `godot_run_test_file` | 运行指定测试文件 | 开发中快速验证 |
| `godot_run_tests` | 运行项目所有测试 | 提交前验收 |
| `godot_get_test_coverage` | 获取测试覆盖率报告 | 质量检查 |

### 文档查询
- **godot-ultimate**: `get_api_docs`, `search_docs`, `get_game_patterns`, `get_performance_guide`

### 代码生成
- **godot-ultimate**: `generate_from_template`, `generate_feature`, `smart_complete`

### Shader 开发
- **godot-ultimate**: `analyze_shader`, `lint_shader`, `lint_all_shaders`, `shader_performance`, `get_shader_docs`

---

## 自动触发规则

### 代码编写后
- 新建/修改 `.gd` 文件 → `godot_lint_file` 检查代码质量
- 新建/修改 `.gdshader` → `godot_lint_shader` 检查着色器

### 代码审查时
- 分析依赖 → `godot_analyze_dependencies`
- 检查信号流 → `godot_analyze_signal_flow`

### 测试时
- 运行测试 → `godot_run_tests`
- 生成测试 → `godot_generate_test`

### TDD 开发时
当使用 TDD 工作流程开发新功能时：
1. **RED**: `godot_generate_test` 生成测试桩 → 编写测试 → `godot_run_test_file` 确认失败
2. **GREEN**: 编写代码 → `godot_run_test_file` 确认通过 → `godot_lint_file` 检查质量
3. **REFACTOR**: 重构代码 → `godot_run_test_file` 确保不破坏
4. **验收**: `godot_run_tests` 运行全部测试 → `godot_get_test_coverage` 检查覆盖率

### 调试时
- 运行项目 → `godot-mcp:run_project`
- 获取输出 → `godot-mcp:get_debug_output`

### 查询文档时
- API 问题 → `godot_get_api_docs`
- 模式问题 → `godot_get_game_patterns`

---

## 开发工作流程

### TDD 工作流（推荐）

```
┌─────────┐    失败    ┌─────────┐    通过    ┌──────────┐
│  RED    │ ────────→ │  GREEN  │ ────────→ │ REFACTOR │
│ 写测试  │           │  写代码  │           │   重构   │
└─────────┘           └─────────┘           └────┬─────┘
     ↑                                           │
     └───────────────── 下一功能 ←───────────────┘
```

1. **RED**: 使用 `generate_test` 生成测试桩，编写失败的测试
2. **GREEN**: 编写最小代码使测试通过，使用 `lint_file` 检查
3. **REFACTOR**: 改进代码，确保测试仍通过
4. **验收**: `run_tests` 全部测试 + `get_test_coverage` 覆盖率 > 80%

### 传统功能开发
1. 使用 `generate_from_template` 生成基础代码
2. 编写代码后使用 `lint_file` 检查
3. 使用 `generate_test` 生成测试
4. 使用 `run_tests` 验证

### 项目维护
1. 使用 `project_health` 检查健康度
2. 使用 `detect_dead_code` 清理死代码
3. 使用 `validate_scenes` 验证场景引用

## 代码模板

### 游戏代码模板
- [2D角色控制器](assets/templates/character_controller_2d.gd)
- [状态机](assets/templates/state_machine.gd)
- [单例模板](assets/templates/singleton_template.gd)

### 测试模板
- [通用测试模板](assets/templates/test_template.gd)
- [场景测试模板](assets/templates/test_scene_template.gd)
- [状态机测试模板](assets/templates/test_state_machine_template.gd)

## 快速参考

```gdscript
# 节点引用
@onready var sprite: Sprite2D = $Sprite2D

# 导出变量
@export var speed: float = 200.0
@export_range(0, 100) var health: int = 100

# 信号
signal health_changed(new_value: int)

# 状态机枚举
enum State { IDLE, RUN, JUMP, FALL }
var current_state: State = State.IDLE
```
