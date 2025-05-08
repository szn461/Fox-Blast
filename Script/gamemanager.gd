extends Node2D

@export var slime_scene:PackedScene
@export var bigslime_scene:PackedScene
@export var spawn_timer:Timer
@export var bigslime_timer:Timer
@export var score:int=0
@export var score_label:Label
@export var gameover_label:Label
var game_time: float = 0.0
var is_bigslime_spawning: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.timeout.connect(_spawn_slime)# 初始化大史莱姆 Timer（间隔比普通史莱姆长）
	bigslime_timer.wait_time = 10.0  # 10秒生成一次大史莱姆
	bigslime_timer.autostart = false  # 不自动开始


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	game_time += delta  # 更新游戏时间
	spawn_timer.wait_time-=0.2*delta
	spawn_timer.wait_time=clamp(spawn_timer.wait_time,1,3)
	if game_time >= 1.0 and not is_bigslime_spawning:
		is_bigslime_spawning = true
		bigslime_timer.start()  # 启动大史莱姆生成
		bigslime_timer.timeout.connect(_spawn_bigslime)  # 连接生成函数
	score_label.text="Score : "+str(score)

func _spawn_slime() -> void:
	var slime_node=slime_scene.instantiate()
	slime_node.position=position+Vector2(260,randf_range(40,115))
	get_tree().current_scene.add_child(slime_node)

func _spawn_bigslime() -> void:
	var bigslime_node = bigslime_scene.instantiate()
	bigslime_node.position=position + Vector2(260, randf_range(22,90))
	get_tree().current_scene.add_child(bigslime_node)
	
func show_game_over():
	gameover_label.visible=true
