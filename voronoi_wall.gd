extends Node3D
@export var yes: XRController3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var delaunay = Delaunay.new(Rect2(0,0,1200,700))
	var rng = RandomNumberGenerator.new()
	
	for i in range(10):
		for j in range(10):
			delaunay.add_point(Vector2(1200/10 * i, 700/10 * j))
			print(1200/10 * i, " ", 700/10 * j)
			
			
	var triangles: Array = delaunay.triangulate()
	var d_voronoi: Array = delaunay.make_voronoi(triangles)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	
	var meshes: Array = []
	
	for i in range(d_voronoi.size()):
		var vertices = PackedVector3Array()
		var cur_voronoi: Delaunay.VoronoiSite = d_voronoi[i]
		var cur_node: XRToolsPickable = XRToolsPickable.new()
		cur_node.freeze = true
		

		
		if (delaunay.is_border_site(cur_voronoi)):
			continue
		
		var left_side: Array = []
		var right_side: Array = []
		var left_center: Vector3 = Vector3(cur_voronoi.center.x/1200,cur_voronoi.center.y/1200, 0.0)
		var right_center: Vector3 = Vector3(cur_voronoi.center.x/1200,cur_voronoi.center.y/1200, 0.05)
		
		for point in cur_voronoi.polygon:
			left_side.append(Vector3(point.x/1200, point.y/1200, 0.0))
			right_side.append(Vector3(point.x/1200, point.y/1200, 0.05))
			print(point.x, " ", point.y)
		
		# Handling left-side
		print(left_side.size(), " ", right_side.size());
		for j in range(left_side.size()):
			var triangle1 = left_side[(j)%left_side.size()]
			var triangle2 = left_side[(j+1)%left_side.size()]
			
			vertices.append(triangle2)
			vertices.append(left_center)
			vertices.append(triangle1)
		
		# Handling right-side
		for j in range(right_side.size()):
			var triangle1 = right_side[(j)%right_side.size()]
			var triangle2 = right_side[(j+1)%right_side.size()]
			
			vertices.append(triangle1)
			vertices.append(right_center)
			vertices.append(triangle2)
		
		# Handling middle
		for j in range(right_side.size()):
			var left_triangle1 = left_side[(j)%left_side.size()]
			var left_triangle2 = left_side[(j+1)%left_side.size()]
			var right_triangle1 = right_side[(j)%right_side.size()]
			var right_triangle2 = right_side[(j+1)%right_side.size()]
			
			vertices.append(right_triangle1)
			vertices.append(right_triangle2)
			vertices.append(left_triangle1)
			
			vertices.append(left_triangle2)
			vertices.append(left_triangle1)
			vertices.append(right_triangle2)
		
		var collision_mesh: CollisionPolygon3D = CollisionPolygon3D.new()
		var collision_arr: PackedVector2Array = []
		
		for point in cur_voronoi.polygon:
			var point2d: Vector2 = Vector2(point.x/1200, point.y/1200)
			collision_arr.append(point2d)
		
		collision_mesh.depth = 0.05
		collision_mesh.polygon = collision_arr
		cur_node.add_child(collision_mesh)
		
		
		
		
		
		var arr_mesh = ArrayMesh.new();
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var m = MeshInstance3D.new()
		m.mesh = arr_mesh
		
		cur_node.add_child(m)
		add_child(cur_node)
	
	pass # Replace with function body.

func children():
	for child in get_children():
		if child is XRToolsPickable:
			child.freeze = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if yes.is_button_pressed("trigger"):
		children()
	pass
