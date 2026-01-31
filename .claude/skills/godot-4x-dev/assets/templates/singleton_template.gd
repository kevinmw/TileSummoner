# AutoLoad 单例模板
# 使用方法：
# 1. 创建新脚本继承此模板或直接使用
# 2. 项目 → 项目设置 → AutoLoad → 添加此脚本
# 3. 设置节点名称（如 GameManager）
class_name SingletonTemplate
extends Node

## 信号 - 根据需要添加
signal game_started
signal game_paused
signal game_resumed
signal game_over


## 游戏状态
var is_paused: bool = false
var is_game_over: bool = false


## 生命周期
func _ready() -> void:
	# 暂停时仍然运行
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 初始化
	_initialize()


func _initialize() -> void:
	# 在此添加初始化逻辑
	pass


## 游戏状态控制

func start_game() -> void:
	is_game_over = false
	is_paused = false
	game_started.emit()


func pause_game() -> void:
	if is_paused:
		return

	is_paused = true
	get_tree().paused = true
	game_paused.emit()


func resume_game() -> void:
	if not is_paused:
		return

	is_paused = false
	get_tree().paused = false
	game_resumed.emit()


func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()


func end_game() -> void:
	is_game_over = true
	game_over.emit()


func restart_game() -> void:
	is_paused = false
	is_game_over = false
	get_tree().paused = false
	get_tree().reload_current_scene()


## 场景管理

func change_scene(scene_path: String) -> void:
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)


func change_scene_packed(scene: PackedScene) -> void:
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_packed(scene)


## 退出游戏

func quit_game() -> void:
	get_tree().quit()


# =============================================================================
# 事件总线模板 - 可作为独立单例使用
# =============================================================================
# class_name EventBus
# extends Node
#
# # 游戏事件
# signal player_spawned(player: Node2D)
# signal player_died
# signal enemy_killed(enemy: Node2D)
# signal level_completed(level_id: int)
#
# # UI 事件
# signal score_updated(new_score: int)
# signal health_updated(current: int, maximum: int)
# signal show_notification(message: String)


# =============================================================================
# 音频管理器模板 - 可作为独立单例使用
# =============================================================================
# class_name AudioManager
# extends Node
#
# @onready var music_player: AudioStreamPlayer = $MusicPlayer
# var sfx_players: Array[AudioStreamPlayer] = []
#
# func _ready() -> void:
#     # 创建音效播放器池
#     for i in 8:
#         var player := AudioStreamPlayer.new()
#         player.bus = "SFX"
#         add_child(player)
#         sfx_players.append(player)
#
# func play_music(stream: AudioStream) -> void:
#     music_player.stream = stream
#     music_player.play()
#
# func play_sfx(stream: AudioStream) -> void:
#     for player in sfx_players:
#         if not player.playing:
#             player.stream = stream
#             player.play()
#             return
