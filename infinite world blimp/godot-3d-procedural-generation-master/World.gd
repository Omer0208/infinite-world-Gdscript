extends Spatial

const chunk_size = 64
const chunk_ammount = 16

var noise
var biomeNoise
var chunks = {}
var unready_chunks = {}
var thread

func _ready():
	randomize()
	biomeNoise = OpenSimplexNoise.new()
	noise = OpenSimplexNoise.new()
	var myseed = randi()
	noise.seed = myseed
	biomeNoise.seed = myseed
	noise.octaves = 5
	biomeNoise.octaves = 3
	noise.period = 50
	biomeNoise.period = 200
	
	thread = Thread.new()
	
func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	if not thread.is_active():
		thread.start(self, "load_chunk", [thread, x, z])
		unready_chunks[key] = 1
		
func load_chunk(arr):
	var thread_my = arr[0]
	var x = arr[1]
	var z = arr[2]
	
	var chunk = Chunk.new(biomeNoise, noise, x * chunk_size, z * chunk_size,  chunk_size)
	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)
	
	call_deferred("load_done", chunk, thread_my)
	
func load_done(chunk, _thread):
	add_child(chunk)
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	_thread.wait_to_finish()
	
func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key):
		return chunks.get(key)
	return null
	
func _process(_delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	
func update_chunks():
	var player_translation = $Player.translation
	var p_x	= int(player_translation.x / chunk_size)
	var p_z = int(player_translation.z / chunk_size)
	
	for x in range(p_x - chunk_ammount * 0.5, p_x + chunk_ammount * 0.5):
		for z in range(p_z - chunk_ammount * 0.5, p_z + chunk_ammount * 0.5):
			add_chunk(x, z)
			var chunk = get_chunk(x,z)
			if chunk != null:
				chunk.should_remove = false
				
			
func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)

func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true


