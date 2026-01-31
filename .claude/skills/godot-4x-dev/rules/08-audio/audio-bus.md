# 音频总线

## 音频总线系统

音频总线用于组织和处理音频信号。在 `项目 → 音频` 或底部面板 `Audio` 标签中配置。

## 推荐总线结构

```
Master (主总线)
├── Music      (音乐)
├── SFX        (音效)
│   ├── UI     (UI 音效)
│   └── World  (游戏世界音效)
├── Voice      (语音)
└── Ambient    (环境音)
```

## 创建总线

1. 底部面板 → Audio
2. 点击 "Add Bus" 添加总线
3. 重命名总线
4. 设置输出（默认输出到 Master）

## 使用总线

```gdscript
# 在音频播放器中指定总线
@onready var music: AudioStreamPlayer = $MusicPlayer
@onready var sfx: AudioStreamPlayer = $SFXPlayer

func _ready() -> void:
    music.bus = "Music"
    sfx.bus = "SFX"
```

## 音量控制

```gdscript
class_name AudioManager
extends Node

func set_master_volume(volume: float) -> void:
    var bus_idx := AudioServer.get_bus_index("Master")
    AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

func set_music_volume(volume: float) -> void:
    var bus_idx := AudioServer.get_bus_index("Music")
    AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

func set_sfx_volume(volume: float) -> void:
    var bus_idx := AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

func get_music_volume() -> float:
    var bus_idx := AudioServer.get_bus_index("Music")
    return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))

func mute_bus(bus_name: String, muted: bool) -> void:
    var bus_idx := AudioServer.get_bus_index(bus_name)
    AudioServer.set_bus_mute(bus_idx, muted)

func linear_to_db(linear: float) -> float:
    return 20.0 * log(linear) / log(10.0) if linear > 0 else -80.0

func db_to_linear(db: float) -> float:
    return pow(10.0, db / 20.0)
```

## 音频效果

在总线上添加效果：

```gdscript
# 获取效果
func get_reverb_effect(bus_name: String) -> AudioEffectReverb:
    var bus_idx := AudioServer.get_bus_index(bus_name)
    for i in AudioServer.get_bus_effect_count(bus_idx):
        var effect := AudioServer.get_bus_effect(bus_idx, i)
        if effect is AudioEffectReverb:
            return effect
    return null

# 调整混响
func set_reverb(bus_name: String, room_size: float) -> void:
    var reverb := get_reverb_effect(bus_name)
    if reverb:
        reverb.room_size = room_size
```

### 常用效果

| 效果 | 用途 |
|------|------|
| AudioEffectReverb | 混响（室内/洞穴） |
| AudioEffectDelay | 延迟/回声 |
| AudioEffectChorus | 合唱效果 |
| AudioEffectDistortion | 失真 |
| AudioEffectLowPassFilter | 低通滤波（模糊音效） |
| AudioEffectHighPassFilter | 高通滤波 |
| AudioEffectLimiter | 限制器（防止爆音） |
| AudioEffectCompressor | 压缩器 |
| AudioEffectEQ | 均衡器 |

## 动态效果切换

```gdscript
# 水下效果
func enter_water() -> void:
    var sfx_bus := AudioServer.get_bus_index("SFX")

    # 添加低通滤波
    var lowpass := AudioEffectLowPassFilter.new()
    lowpass.cutoff_hz = 1000.0
    AudioServer.add_bus_effect(sfx_bus, lowpass)

func exit_water() -> void:
    var sfx_bus := AudioServer.get_bus_index("SFX")

    # 移除低通滤波
    for i in range(AudioServer.get_bus_effect_count(sfx_bus) - 1, -1, -1):
        var effect := AudioServer.get_bus_effect(sfx_bus, i)
        if effect is AudioEffectLowPassFilter:
            AudioServer.remove_bus_effect(sfx_bus, i)
```

## 保存/加载音量设置

```gdscript
func save_audio_settings() -> void:
    var settings := {
        "master": get_master_volume(),
        "music": get_music_volume(),
        "sfx": get_sfx_volume()
    }
    # 保存到文件...

func load_audio_settings(settings: Dictionary) -> void:
    if settings.has("master"):
        set_master_volume(settings.master)
    if settings.has("music"):
        set_music_volume(settings.music)
    if settings.has("sfx"):
        set_sfx_volume(settings.sfx)
```

## 暂停行为

```gdscript
# 暂停时继续播放音乐
func _ready() -> void:
    # 设置 process_mode 让音乐在暂停时继续
    music_player.process_mode = Node.PROCESS_MODE_ALWAYS

# 暂停所有 SFX
func pause_sfx(paused: bool) -> void:
    var sfx_bus := AudioServer.get_bus_index("SFX")
    AudioServer.set_bus_mute(sfx_bus, paused)
```

## 音频总线布局文件

保存为 `.tres` 文件：
```
项目 → 项目设置 → Audio → Bus → Default Bus Layout
```

```gdscript
# 运行时加载不同的总线布局
func load_bus_layout(layout_path: String) -> void:
    var layout := load(layout_path)
    AudioServer.set_bus_layout(layout)
```
