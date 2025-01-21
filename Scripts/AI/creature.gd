extends CharacterBody2D

@export var neural_network_script: SimpleNeuralNetwork #Script
@export var movement_script: creature_movement #Script
@export var agent_prefab: PackedScene
@export var view_distance: float = 20.0
@export var size: float = 1.0
@export var energy: float = 20.0
@export var energy_gained: float = 10.0
@export var reproduction_energy: float = 0.0
@export var reproduction_energy_gained: float = 1.0
@export var reproduction_energy_threshold: float = 10.0
@export var mutation_amount: float = 0.8
@export var mutation_chance: float = 0.2
@export var num_raycasts: int = 5
@export var angle_between_raycasts: float = 30.0

var nn: Object
var movement: Object
var distances: Array
var is_mutated: bool = false
var elapsed: float = 0.0
var life_span: float = 0.0
var is_dead: bool = false

func _ready():
	neural_network_script = SimpleNeuralNetwork.new()
	movement_script = creature_movement.new()
	nn = neural_network_script.NN.new([6, 8, 8, 2]) # Example network shape (adjust as needed)
	movement = movement_script#.new()
	add_child(movement) #add movement script as child
	distances.resize(num_raycasts)
	scale = Vector2(size, size)

func _physics_process(delta):
	if not is_mutated:
		mutate_creature()
		is_mutated = true
		energy = 20

	manage_energy(delta)
	if is_dead:
		return
	# Raycast-based food detection
	for i in range(num_raycasts):
		var angle = ((2.0 * i + 1.0 - num_raycasts) * angle_between_raycasts / 2.0)
		var ray_direction = Vector2.RIGHT.rotated(deg_to_rad(angle))
		var ray_start = global_position #+ Vector2.UP * 0.1 #2D so no need to offset
		var space_state = get_world_2d().get_direct_space_state()
		var query = PhysicsRayQueryParameters2D.new()
		query.from = ray_start
		query.to = ray_start + ray_direction * view_distance
		query.collide_with_areas = true
		query.collide_with_bodies = true
		var result = space_state.intersect_ray(query)

		if result:
			if result.collider.is_in_group("food"):
				distances[i] = result.distance / view_distance
				# Debug draw ray (optional)
				draw_line(ray_start, ray_start + ray_direction * result.distance, Color.RED, 2)
			else:
				distances[i] = 1.0
				draw_line(ray_start, ray_start + ray_direction * view_distance, Color.BLUE, 2)
		else:
			distances[i] = 1.0
			draw_line(ray_start, ray_start + ray_direction * view_distance, Color.GREEN, 2)

	var inputs_to_nn = distances
	var outputs_from_nn = nn.brain(inputs_to_nn)

	var fb = outputs_from_nn[0]
	var lr = outputs_from_nn[1]

	movement.move(fb, lr)

func _on_area_entered(area):
	if area.is_in_group("food"):
		energy += energy_gained
		reproduction_energy += reproduction_energy_gained
		area.queue_free() # Destroy the food

func manage_energy(delta):
	elapsed += delta
	life_span += delta
	if elapsed >= 1.0:
		elapsed -= 1.0
		energy -= 1.0

		if reproduction_energy >= reproduction_energy_threshold:
			reproduction_energy = 0.0
			reproduce()

	if energy <= 0.0 or global_position.y < -1000: #consider changing this to a death area
		is_dead = true
		queue_free()
		#queue_free()

func mutate_creature():
	if mutation_amount > 0:
		mutation_amount += randf_range(-1.0, 1.0) / 100.0
		mutation_chance += randf_range(-1.0, 1.0) / 100.0

	mutation_amount = max(mutation_amount, 0.0)
	mutation_chance = max(mutation_chance, 0.0)

	nn.mutate_network(mutation_amount, mutation_chance) # You'll need to add this to your NN script

func reproduce():
	for _i in range(1): # Number of children
		var child = agent_prefab.instantiate()
		get_parent().add_child(child)
		child.global_position = global_position + Vector2(randf_range(-10.0, 11.0), randf_range(-10.0, 11.0))
		child.get_node("NN").layers = nn.copy_layers() # You'll need to add copy_layers to your NN scripts
