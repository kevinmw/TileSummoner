# AutoLoad 全局单例

## 什么是 AutoLoad

AutoLoad 是 Godot 的全局单例系统，脚本在游戏启动时自动加载，全局可访问。

## 设置 AutoLoad

1. 项目 → 项目设置 → AutoLoad
2. 添加脚本路径和节点名称
3. 确保"启用"勾选

## 常见 AutoLoad 模式

### 游戏管理器

```gdscript
# res://src/autoloads/game_manager.gd
extends Node

signal score_changed(new_score: int)
signal game_over

var score: int = 0:
    set(value):
        score = value
        score_changed.emit(score)

var is_paused: bool = false

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS  # 暂停时仍运行

func add_score(amount: int) -> void:
    score += amount

func pause_game() -> void:
    is_paused = true
    get_tree().paused = true

func resume_game() -> void:
    is_paused = false
    get_tree().paused = false

func restart_game() -> void:
    score = 0
    get_tree().reload_current_scene()
```

### 音频管理器

```gdscript
# res://src/autoloads/audio_manager.gd
extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_pool: Array[AudioStreamPlayer] = []

const SFX_POOL_SIZE: int = 8

func _ready() -> void:
    # 创建音效播放器池
    for i in SFX_POOL_SIZE:
        var player = AudioStreamPlayer.new()
        add_child(player)
        sfx_pool.append(player)

func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", -40, fade_duration)
    await tween.finished
    music_player.stream = stream
    music_player.play()
    tween = create_tween()
    tween.tween_property(music_player, "volume_db", 0, fade_duration)

func play_sfx(stream: AudioStream) -> void:
    for player in sfx_pool:
        if not player.playing:
            player.stream = stream
            player.play()
            return
```

### 事件总线

```gdscript
# res://src/autoloads/event_bus.gd
extends Node

# 游戏事件
signal player_died
signal enemy_killed(enemy: Node2D)
signal level_completed(level_id: int)
signal item_collected(item_data: ItemData)

# UI 事件
signal show_dialog(text: String)
signal update_health_bar(current: int, max: int)
```

### 场景管理器

```gdscript
# res://src/autoloads/scene_manager.gd
extends Node

signal scene_changed(scene_name: String)

var current_scene: Node = null

func _ready() -> void:
    current_scene = get_tree().current_scene

func change_scene(path: String) -> void:
    call_deferred("_deferred_change_scene", path)

func _deferred_change_scene(path: String) -> void:
    current_scene.free()
    var new_scene = load(path)
    current_scene = new_scene.instantiate()
    get_tree().root.add_child(current_scene)
    get_tree().current_scene = current_scene
    scene_changed.emit(path)

func change_scene_with_transition(path: String) -> void:
    # 添加过渡动画
    var tween = create_tween()
    tween.tween_property(get_tree().root, "modulate", Color.BLACK, 0.3)
    await tween.finished
    change_scene(path)
    tween = create_tween()
    tween.tween_property(get_tree().root, "modulate", Color.WHITE, 0.3)
```

## 使用 AutoLoad

```gdscript
# 任意脚本中直接使用 AutoLoad 名称
func _on_coin_collected() -> void:
    GameManager.add_score(100)
    AudioManager.play_sfx(coin_sound)

func _on_player_died() -> void:
    EventBus.player_died.emit()
```

## AutoLoad 注意事项

1. **不要存储节点引用** - 场景切换后引用失效
2. **使用信号通信** - 避免紧耦合
3. **process_mode** - 需要暂停时运行设为 ALWAYS
4. **谨慎使用** - 过多全局状态难以维护

## 推荐 AutoLoad 列表

| 名称 | 用途 |
|------|------|
| GameManager | 游戏状态、分数、生命 |
| AudioManager | 音乐、音效播放 |
| EventBus | 全局事件通信 |
| SceneManager | 场景切换、过渡 |
| SaveManager | 存档/读档 |
