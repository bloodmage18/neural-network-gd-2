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
				weights_array[i].append(randf_range(-1.0, 1.0)) # Initialize weights

		biases_array.resize(n_nodes)
		for i in range(n_nodes):
			biases_array[i] = randf_range(-1.0, 1.0) # Initialize biases

		node_array.resize(n_nodes)

	func forward(inputs_array: Array):
		node_array.fill(0.0) # Reset node values

		for i in range(n_nodes):
			for j in range(n_inputs):
				node_array[i] += weights_array[i][j] * inputs_array[j]
			node_array[i] += biases_array[i]

	func activation():
		for i in range(n_nodes):
			node_array[i] = max(0.0, node_array[i]) # ReLU activation

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


# Example Usage (in a Node's script):
func _ready():
	var nn = NN.new([2, 4, 4, 2]) # Example network shape
	var inputs = [0.5, 0.8]
	var output = nn.brain(inputs)
	print(output)
