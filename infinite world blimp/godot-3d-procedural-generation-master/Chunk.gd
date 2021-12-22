extends Spatial
class_name Chunk

var mesh_instance
var noise
var biome_Noise
var x
var z
var chunk_size
var should_remove = true
var ocean = false
var random = false


func _init(_biomeNoise, _noise, _x, _z, _chunck_size):
	self.noise = _noise
	self.biome_Noise = _biomeNoise
	self.x = _x
	self.z = _z
	self.chunk_size = _chunck_size
	
func _ready():
	generate_chunk()
	
func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.5
	plane_mesh.subdivide_width = chunk_size * 0.5
	
	plane_mesh.material = load("res://materials/world.material")
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane,0)
	if error != 0:
		print("Error code: " + str(error))
		
		
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	mesh_instance = MeshInstance.new()
	mesh_instance.mesh = plane_mesh
	plane_mesh.material = preload("res://materials/water1.material")
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		var terrain_noise = biome_Noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z)
		noise.octaves = 4
		noise.period = 60
		if terrain_noise < 0:
			vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * terrain_noise * 150 + 5
		elif terrain_noise < 0.7:
			vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * terrain_noise - (terrain_noise * 100) + 5
			#if 
			#add_child(mesh_instance)
		else:
			vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * terrain_noise * 10 + 5
			# plains - * terrain_noise * 20,
			# hills - * terrain_noise * 150,
			# ocean * terrain_noise - (terrain_noise * 100)
			
		data_tool.set_vertex(i, vertex)
		
		

		
		
	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)
		
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
	
	
