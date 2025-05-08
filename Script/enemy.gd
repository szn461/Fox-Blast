extends Area2D

# Called when the node enters the scene tree for the first time.
@export var slime_speed:float=-50
var is_dead:bool=false
@export var animator:AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_dead:
		position+=Vector2(slime_speed,0)*delta
	if position.x<-267:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	#if body is CharacterBody2D and not is_dead:避免死后碰撞触发
	if body is CharacterBody2D and body.is_in_group("player"):
		var player = body
		if "is_rolling" in player and player.is_rolling:
			return
		body.game_over()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		area.queue_free()
		is_dead=true
		get_tree().current_scene.score+=1
		$die.play()
		animator.play("die")
		await get_tree().create_timer(0.6).timeout
		queue_free()
