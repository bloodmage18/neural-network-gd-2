extends Area2D

var is_consumed: bool = false

func _ready():
	if !self.is_in_group("Food"):
		print(self.name , " i am not in food")

func _consume():
	is_consumed = true
	queue_free()
