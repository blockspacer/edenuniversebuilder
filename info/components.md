# Chunk System
	chunk : holds 16 x 16 x 16 block data
		- rendered (bool) : triggers the system to render
		- position (vector3) : the position of the chunk
		- address (int) : the world file address
		- gen_seed (int) : the generator seed
		- block_data (dictonary) : the block data {vector3:id}
		- blocks_loaded (int) the number of blocks loaded
		- mesh (array_mesh) : the mesh generated
		- vertex_data (array) : the vertex data used to create the mesh
		- shape (polygon_shape) : the shape used to create the hitboxes
		- materials (dictonary) : the texture data to use
		- entities (dictonary) : the entity data of non-blocks
		- object
		- method

# Client System
	player : first person camera
		- rendered (bool) : triggers the system to render
		- position (vector3) : the translation of the player
		- username (string) : the players username
		- object (object) : the callback object

# Download System

# Input System
	text_input : reads text keypresses to the 'text' var
		- rendered (bool) : triggers the system to render
		- text (string) : input
		- object (object) : object that has callback method
		- method (method) : calls this method when KEY_ENTER is received

	joystick (2) : processes touch movement
		- rendered (bool) : triggers the system to render

# Interface System
	terminal : displays text
		- rendered (bool) : triggers the system to render
		- position (vector2) : the position of the terminal
		- debug (bool) : if true, shows debug logs
		- text (string) : the text to display

	hud : container of hud elements
		- rendered (bool) : triggers the system to render
		- components (dictonary) : embedded components

	vertical_container : arranges child components vertically
		- rendered (bool)
		- min_size (Vector2)
		- components (dictonary)

	horizontal_container : arranges child components horizontally
		- rendered (bool)
		- min_size (Vector2)
		- components (dictonary)
