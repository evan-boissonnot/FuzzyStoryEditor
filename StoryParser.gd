extends Node

const EMPTY := -1

#onready var graph_edit : GraphEdit = $"../VBox/HBox2/StoryGraphEdit"

func graph_to_array(graph_edit : GraphEdit, event_nodes : Array) -> Array:
	var nodes := []
	
	for i in event_nodes:
		
		var n := i as EventNode
		
		var node := {
			"metadata": {
				"node_name": n.name,
				"position": n.offset,
				"size": n.rect_size,
#				"rect": Rect2(n.offset, n.rect_size)
			},
			"node_type": "EventNode",
			"node_id": int(n.get_node_id()),
			
#			"next_id": EMPTY
		}
		
		if "CheckpointNode".is_subsequence_ofi(n.name):
			node["node_type"] = "CheckpointNode"
			node["checkpoint"] = n.get_checkpoint_text()
			
			node["next_id"] = EMPTY
			
			for c in graph_edit.get_connection_list():
				if c.from == n.name:
					var target : EventNode = graph_edit.get_node(c.to)
					node["next_id"] = target.get_node_id()
					
			
		elif "ConditionNode".is_subsequence_ofi(n.name):
			node["node_type"] = "ConditionNode"
			# make sure we store a value even if not connected
			node["next_id_true"] = EMPTY
			node["next_id_false"] = EMPTY
			
			for c in graph_edit.get_connection_list():
				if c.from == n.name:
					var target : EventNode = graph_edit.get_node(c.to)
					# it skips the port 0 if it's not open, and turns port 1 into 0, and so on
					if c.from_port == 0:
						node["next_id_true"] = target.get_node_id()
					elif c.from_port == 1:
						node["next_id_false"] = target.get_node_id()
		
		elif "FunctionCallNode".is_subsequence_ofi(n.name):
			node["node_type"] = "FunctionCallNode"
			node["class"] = n.get_class_text()
			node["function"] = n.get_function_text()
			
#			var p = str2var(n.get_params_text())
#			var p = Array((n.get_params_text()))
			var params_string : String = n.get_params_text()
			var params : Array = []
			
			if params_string != "":
				var p = str2var(n.get_params_text())
#				print("Type: %s, Value: %s" % [typeof(p), p])
				
				# if we can convert to an array, just save it
				if typeof(p) == TYPE_ARRAY:
					params = p
				# not an array, so just append the value into an array
				else:
					if typeof(p) == TYPE_STRING:
						# might be an error, if intended to be an array
						assert(!("[".is_subsequence_ofi(p) or "]".is_subsequence_ofi(p)))
					params.append(p)
			
#			for x in params:
			node["params"] = params
#			print("Type: %s value: %s" % [typeof(p), p])
			
			node["next_id"] = EMPTY
			
			for c in graph_edit.get_connection_list():
				if c.from == n.name:
					var target : EventNode = graph_edit.get_node(c.to)
					node["next_id"] = target.get_node_id()
			
		elif "DialogNode".is_subsequence_ofi(n.name):
			node["node_type"] = "DialogNode"
		
		elif "RandomNode".is_subsequence_ofi(n.name):
			node["node_type"] = "RandomNode"
			
			var outcomes := []
			
			# make sure we store a value even if not connected
			for o in n.get_connection_output_count():
				outcomes.append(EMPTY)
			
			for c in graph_edit.get_connection_list():
				if c.from == n.name:
					var target : EventNode = graph_edit.get_node(c.to)
					outcomes[c.from_port] = target.get_node_id()
			node["outcomes"] = outcomes
		
		nodes.append(node)
	
	
#	print(nodes)
	return nodes
