extends CharacterBody2D

@export var move_speed: float = 50
@export var animator: AnimatedSprite2D
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.6
@export var roll_cd: float = 0.6
@export var roll_distance: float = 50  # 滚动固定距离
@export var roll_duration: float = 0.3  # 滚动动画持续时间

var is_game_over: bool = false
var can_fire: bool = true
var can_roll: bool = true
var is_rolling: bool = false
var roll_direction: Vector2 = Vector2.ZERO  # 存储滚动方向
var roll_start_pos: Vector2 = Vector2.ZERO  # 滚动起始位置
var roll_timer: float = 0.0  # 滚动计时器

func _ready():
	$firerate.wait_time = fire_rate
	$firerate.timeout.connect(_on_fire_rate_timeout)
	$rollcd.wait_time = roll_cd
	$rollcd.timeout.connect(_on_rollcd_timeout)

func _physics_process(delta: float) -> void:
	if is_game_over:
		animator.play("lose")
		$run.stop()
		return
	
	# 滚动期间强制移动
	if is_rolling:
		_handle_roll_movement(delta)
		return  # 跳过其他逻辑
	
	# 正常移动和动画
	velocity = Input.get_vector("left", "right", "up", "down") * move_speed
	if velocity == Vector2.ZERO:
		animator.play("idle")
		$run.stop()
	else:
		animator.play("run")
		if not $run.playing:
			$run.play()
	
	# 射击逻辑
	if Input.is_action_just_pressed("fire") and can_fire:
		_on_fire()
	
	# 滚动逻辑
	if Input.is_action_just_pressed("roll") and can_roll:
		roll()
	
	move_and_slide()

func _handle_roll_movement(delta: float) -> void:
	roll_timer += delta
	var progress = min(roll_timer / roll_duration, 1.0)  # 滚动进度 (0~1)
	
	# 计算当前帧的移动距离（线性插值）
	var current_distance = roll_distance * progress
	var target_pos = roll_start_pos + roll_direction * current_distance
	velocity = (target_pos - position) / delta  # 转换为速度
	
	move_and_slide()
	
	# 滚动结束判断
	if progress >= 1.0:
		is_rolling = false
		velocity = Vector2.ZERO

func roll() -> void:
	if is_game_over:
		return
	# 获取当前输入方向（如果无输入则默认向右）
	roll_direction = Input.get_vector("left", "right", "up", "down").normalized()
	if roll_direction == Vector2.ZERO:
		roll_direction = Vector2.RIGHT  # 默认向右滚动
	
	# 初始化滚动状态
	roll_start_pos = position
	roll_timer = 0.0
	is_rolling = true
	can_roll = false
	animator.play("roll")
	$roll.play()
	$rollcd.start()
	print("Rolling with direction: ", roll_direction)

func _on_rollcd_timeout():
	can_roll = true
	is_rolling = false

func _on_fire() -> void:
	if is_game_over or is_rolling:  # 滚动期间禁止射击
		return
	can_fire = false
	$firerate.start()
	$fire.play()	
	var bullet_node = bullet_scene.instantiate()
	bullet_node.position = position + Vector2(6, 6)
	get_tree().current_scene.add_child(bullet_node)

func game_over():
	if not is_game_over:
		is_game_over = true
		$gameover.play()
		get_tree().current_scene.show_game_over()
		$restart.start()

func _on_fire_rate_timeout():
	can_fire = true
	
func reload() -> void:
	get_tree().reload_current_scene()
