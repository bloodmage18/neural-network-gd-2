class_name SimpleNeuralNetwork extends Node # Or a more appropriate node type like Node2D

class Layer:
	var weights_array: Array
	var biases_array: Array
	var node_array: Array

	var n_nodes: int
	var n_inputs: int

	func _init(n_inputs: int, n_nodes: int):
		self.n_nodes = n_nodes
		self.n_inputs = n_inputs

		weights_array.resize(n_nodes)
		for i in range(n_nodes):
			weights_array[i] = []
			for j in range(n_inputs):
				weights_array[i].append(randf_range(-1.0, 1.0))

		biases_array.resize(n_nodes)
		for i in range(n_nodes):
			biases_array[i] = randf_range(-1.0, 1.0)

		node_array.resize(n_nodes)

	func forward(inputs_array: Array):
		node_array.fill(0.0)
		#print(inputs_array.size()) #debugging
		for i in range(n_nodes):
			for j in range(n_inputs):
				node_array[i] += weights_array[i][j] * inputs_array[j]
			node_array[i] += biases_array[i]

	func activation():
		for i in range(n_nodes):
			node_array[i] = max(0.0, node_array[i])

	func copy():
		var new_layer = Layer.new(n_inputs, n_nodes)
		new_layer.weights_array = weights_array.duplicate(true)
		new_layer.biases_array = biases_array.duplicate(true)
		return new_layer

class NN:
	var layers: Array
	var network_shape: Array

	func _init(shape: Array):
		network_shape = shape
		layers = []
		for i in range(network_shape.size() - 1):
			layers.append(Layer.new(network_shape[i], network_shape[i + 1]))

	func brain(inputs: Array) -> Array:
		for i in range(layers.size()):
			if i == 0:
				layers[i].forward(inputs)
				layers[i].activation()
			elif i == layers.size() - 1:
				layers[i].forward(layers[i - 1].node_array)
			else:
				layers[i].forward(layers[i - 1].node_array)
				layers[i].activation()

		return layers[layers.size() - 1].node_array

	func mutate_network(mutation_amount: float, mutation_chance: float):
		for layer in layers:
			for i in range(layer.weights_array.size()):
				for j in range(layer.weights_array[i].size()):
					if randf() < mutation_chance:
						layer.weights_array[i][j] += randf_range(-mutation_amount, mutation_amount)

			for i in range(layer.biases_array.size()):
				if randf() < mutation_chance:
					layer.biases_array[i] += randf_range(-mutation_amount, mutation_amount)

	func copy_layers() -> Array:
		var new_layers = []
		for layer in layers:
			new_layers.append(layer.copy())
		return new_layers
