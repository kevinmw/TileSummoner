# Godot 4.x 游戏开发 Skill

专业的 Godot 4.x 通用游戏开发知识库 skill，与 MCP 工具深度集成。

## 功能特性

- **完整知识库**: 45 个规则文件，涵盖 2D/3D 游戏开发
- **TDD 支持**: GDUnit4 测试框架集成，完整 TDD 工作流
- **代码模板**: 8 个可复用的代码模板（含测试模板）
- **完整示例**: 6 个游戏系统实现示例
- **MCP 集成**: 与 godot-mcp、godot-ultimate 工具配合

## 安装

### 方式一：添加到 Claude settings

将 `godot-4x-dev` 文件夹添加到 Claude settings 的 skills 目录：

```json
{
  "skills": [
    "path/to/godot-4x-dev"
  ]
}
```

### 方式二：作为项目 skill

将 `godot-4x-dev` 文件夹复制到项目根目录。

## 知识结构

```
rules/
├── 00-core/         # 核心规范 (3)
├── 01-fundamentals/ # 基础概念 (4)
├── 02-scripting/    # GDScript (5)
├── 03-2d/           # 2D 开发 (5)
├── 04-3d/           # 3D 开发 (4)
├── 05-ui/           # UI 系统 (4)
├── 06-animation/    # 动画 (3)
├── 07-physics/      # 物理 (3)
├── 08-audio/        # 音频 (2)
├── 09-patterns/     # 设计模式 (5)
├── 10-best-practices/ # 最佳实践 (4)
└── 11-testing/      # 测试 (7)

assets/
├── templates/       # 代码模板 (8)
└── examples/        # 完整示例 (6)
```

## 代码模板

| 模板 | 描述 |
|------|------|
| `character_controller_2d.gd` | 2D 平台跳跃角色控制器 |
| `character_controller_3d.gd` | 3D 第一人称控制器 |
| `state_machine.gd` | 通用状态机 |
| `singleton_template.gd` | AutoLoad 单例模板 |
| `custom_resource.gd` | 自定义 Resource 模板 |
| `test_template.gd` | 通用单元测试模板 |
| `test_scene_template.gd` | 场景测试模板 |
| `test_state_machine_template.gd` | 状态机测试模板 |

## 完整示例

| 示例 | 描述 |
|------|------|
| `player_movement.md` | 完整玩家移动系统 |
| `enemy_ai.md` | 敌人 AI 系统 |
| `inventory_system.md` | 背包系统 |
| `dialogue_system.md` | 对话系统 |
| `save_load.md` | 存档系统 |
| `tdd_health_system.md` | TDD 开发血量系统示例 |

## MCP 工具

### godot-mcp (场景/项目管理)

```
launch_editor, run_project, create_scene, add_node, save_scene
```

### godot-ultimate (代码分析/测试)

```
godot_lint_file, godot_validate_code, godot_run_tests, godot_get_api_docs
```

## 使用示例

```
用户: 帮我创建一个 2D 平台跳跃角色

Claude:
1. 加载 rules/03-2d/characterbody2d.md 规则
2. 使用 assets/templates/character_controller_2d.gd 模板
3. 调用 godot-mcp.create_scene 创建场景
4. 调用 godot-ultimate.godot_lint_file 验证代码
```

## 许可证

MIT License
