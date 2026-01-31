# 音频播放器

## AudioStreamPlayer 类型

| 类型 | 用途 |
|------|------|
| AudioStreamPlayer | 非定位音频（UI、音乐） |
| AudioStreamPlayer2D | 2D 空间音频 |
| AudioStreamPlayer3D | 3D 空间音频 |

## 基础播放

```gdscript
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
    audio.stream = preload("res://assets/audio/music.ogg")
    audio.volume_db = 0.0
    audio.play()

func play_sound(sound: AudioStream) -> void:
    audio.stream = sound
    audio.play()

func stop_sound() -> void:
    audio.stop()
```

## 音频属性

```gdscript
# 音量（分贝）
audio.volume_db = 0.0    # 原始音量
audio.volume_db = -10.0  # 降低 10dB
audio.volume_db = -80.0  # 几乎静音

# 音调
audio.pitch_scale = 1.0  # 原始音调
audio.pitch_scale = 1.5  # 高音
audio.pitch_scale = 0.5  # 低音

# 循环（在资源中设置）
# 或使用信号
audio.finished.connect(_on_audio_finished)

func _on_audio_finished() -> void:
    audio.play()  # 手动循环

# 音频总线
audio.bus = "Music"  # 使用 Music 总线
```

## AudioStreamPlayer2D

```gdscript
extends AudioStreamPlayer2D

func _ready() -> void:
    # 最大听觉距离
    max_distance = 1000.0

    # 衰减
    attenuation = 1.0  # 线性衰减

    # 区域掩码（用于 Area2D 音频效果）
    area_mask = 1
```

## AudioStreamPlayer3D

```gdscript
extends AudioStreamPlayer3D

func _ready() -> void:
    # 距离相关
    max_distance = 50.0
    unit_size = 10.0  # 单位距离的分贝衰减

    # 衰减模型
    attenuation_model = ATTENUATION_INVERSE_DISTANCE

    # 多普勒效果
    doppler_tracking = DOPPLER_TRACKING_IDLE_STEP

    # 方向性
    emission_angle_enabled = true
    emission_angle_degrees = 45.0
```

## 一次性音效

```gdscript
# 播放并自动释放
func play_sfx(sound: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = sound
    player.bus = "SFX"
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
```

## 音效池

```gdscript
class_name AudioPool
extends Node

@export var pool_size: int = 8
@export var audio_bus: String = "SFX"

var _players: Array[AudioStreamPlayer] = []

func _ready() -> void:
    for i in pool_size:
        var player := AudioStreamPlayer.new()
        player.bus = audio_bus
        add_child(player)
        _players.append(player)

func play(stream: AudioStream, volume_db: float = 0.0) -> AudioStreamPlayer:
    for player in _players:
        if not player.playing:
            player.stream = stream
            player.volume_db = volume_db
            player.play()
            return player
    # 所有播放器都在使用中
    return null

func play_random_pitch(stream: AudioStream, min_pitch: float = 0.9, max_pitch: float = 1.1) -> void:
    var player := play(stream)
    if player:
        player.pitch_scale = randf_range(min_pitch, max_pitch)
```

## 音乐播放器

```gdscript
class_name MusicPlayer
extends AudioStreamPlayer

@export var fade_duration: float = 1.0

var _target_volume: float = 0.0

func play_music(music: AudioStream, fade: bool = true) -> void:
    if fade and playing:
        await fade_out()

    stream = music
    if fade:
        volume_db = -80.0
        play()
        await fade_in()
    else:
        volume_db = _target_volume
        play()

func fade_out() -> void:
    var tween := create_tween()
    tween.tween_property(self, "volume_db", -80.0, fade_duration)
    await tween.finished
    stop()

func fade_in() -> void:
    var tween := create_tween()
    tween.tween_property(self, "volume_db", _target_volume, fade_duration)
    await tween.finished

func set_volume(volume: float) -> void:
    _target_volume = linear_to_db(volume)
    volume_db = _target_volume
```

## 随机音效

```gdscript
@export var footstep_sounds: Array[AudioStream] = []
var _last_sound_index: int = -1

func play_random_footstep() -> void:
    if footstep_sounds.is_empty():
        return

    var index := randi() % footstep_sounds.size()
    # 避免连续播放相同音效
    while index == _last_sound_index and footstep_sounds.size() > 1:
        index = randi() % footstep_sounds.size()

    _last_sound_index = index
    audio_pool.play_random_pitch(footstep_sounds[index])
```

## 音量转换

```gdscript
# 线性 (0-1) 转分贝
func linear_to_db(linear: float) -> float:
    return 20.0 * log(linear) / log(10.0) if linear > 0 else -80.0

# 分贝转线性
func db_to_linear(db: float) -> float:
    return pow(10.0, db / 20.0)

# 使用示例
var volume_slider_value := 0.75  # 滑块值 0-1
audio.volume_db = linear_to_db(volume_slider_value)
```
