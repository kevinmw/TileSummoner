# Godot 4.x 项目结构规范

## 标准目录结构

```
project_name/
├── project.godot          # 项目配置文件
├── .godot/                # 自动生成，加入 .gitignore
│
├── scripts/               # 源代码
│   ├── autoloads/         # 全局单例
│   ├── characters/        # 角色脚本和场景
│   ├── enemies/           # 敌人
│   ├── ui/                # UI 场景和脚本
│   ├── systems/           # 游戏系统（存档、音频等）
│   └── utils/             # 工具类
│
├── assets/                # 资源文件
│   ├── sprites/           # 2D 图片
│   ├── models/            # 3D 模型
│   ├── audio/             # 音效和音乐
│   │   ├── sfx/
│   │   └── music/
│   ├── fonts/             # 字体
│   └── shaders/           # 着色器
│
├── resources/             # .tres 资源文件
│   ├── themes/            # UI 主题
│   └── data/              # 游戏数据
│
├── scenes/                # 游戏场景
│   ├── levels/            # 关卡
│   └── menus/             # 菜单
│
└── tests/                 # GdUnit4 测试
    ├── unit/              # 单元测试（纯逻辑）
    │   ├── characters/
    │   ├── systems/
    │   └── utils/
    ├── integration/       # 集成测试（多组件）
    └── scene/             # 场景测试（完整场景）
```

## 测试目录规范

测试目录结构应**镜像**源代码结构：

```
scripts/characters/player.gd      →  tests/unit/characters/player_test.gd
scripts/systems/health.gd         →  tests/unit/systems/health_test.gd
scripts/utils/math_utils.gd       →  tests/unit/utils/math_utils_test.gd
```

### 测试文件命名

| 类型 | 源文件 | 测试文件 |
|------|--------|----------|
| 单元测试 | `player.gd` | `player_test.gd` |
| 场景测试 | `player.tscn` | `player_scene_test.gd` |

### 测试类型选择

| 测试类型 | 目录 | 用途 |
|----------|------|------|
| 单元测试 | `tests/unit/` | 测试单个类/函数，无外部依赖 |
| 集成测试 | `tests/integration/` | 测试多组件协作 |
| 场景测试 | `tests/scene/` | 测试完整场景行为 |

## 命名规则

| 类型 | 格式 | 示例 |
|------|------|------|
| 文件夹 | snake_case | `player_animations/` |
| 场景文件 | snake_case.tscn | `player.tscn` |
| 脚本文件 | snake_case.gd | `player_controller.gd` |
| 资源文件 | snake_case.tres | `player_stats.tres` |

## 场景与脚本配对

```
characters/
├── player/
│   ├── player.tscn        # 场景
│   ├── player.gd          # 主脚本（附加到根节点）
│   └── player_state_machine.gd  # 辅助脚本
```

## .gitignore 必要条目

```gitignore
.godot/
*.import
export_presets.cfg
*.translation
```

## MCP 工具

- `godot_get_project_info`: 获取项目结构信息
- `godot_validate_project`: 验证项目配置
