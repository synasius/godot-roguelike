extends Node

export var inner_grid_size = Vector2(8, 8)
export var perim_thickness = Vector2(1, 1)
export var count_obstacles = Vector2(2, 7)
export var count_items = Vector2(3, 6)
export var count_enemies = Vector2(2, 2)
var __tile_collection
var __grid

class TileCollection:
	var item = {}
	var tile_size

func fetch_tiles(tile_set_filepath, size_node_name):
	"""
	Initialize __tile_collection instance from a TileSet node.
	The size is retrieved from the `size_node_name` node inside
	the tile set.
	"""
	self.__tile_collection = TileCollection.new()
	var tile_set = load(tile_set_filepath).instance()
	for node in tile_set.get_children():
		self.__tile_collection.item[node.get_name().to_lower()] = node
	self.__tile_collection.tile_size = (tile_set.get_node(size_node_name) \
												.get_texture() \
												.get_size())

func get_tile_size():
	"""
	Returns the size of a single tile.
	"""
	return self.__tile_collection.tile_size

func get_size():
	"""
	Returns the size of the board.
	"""
	return (2 * (self.perim_thickness + Vector2(1, 1)) + self.inner_grid_size) \
			* self.__tile_collection.tile_size

func __rand_tile(tile_set):
	"""
	Extract a random children from the input `tile_set`.
	"""
	var tiles = tile_set.get_children()
	var index = int(rand_range(0, tiles.size()))
	return tiles[index]

func __add_tile(tile, xy):
	"""
	A tile is added to the grid at position xy of the inner grid.
	Outer walls and perimeter thickins are taken into account.
	"""
	var tile_dup = tile.duplicate()
	# To get the correct position we must multiply its grid coordinates by tile_size
	tile_dup.set_pos((self.perim_thickness + Vector2(1, 1) + xy) * self.__tile_collection.tile_size)
	self.add_child(tile_dup)

func __add_base_tiles():
	"""
	Add base tiles to the grid: walls on the outer perimeter
	and floors elsewhere.
	"""
	var bounds = {
		xmin = -self.perim_thickness.x - 1,
		xmax = self.inner_grid_size.x + self.perim_thickness.x,
		ymin = -self.perim_thickness.y - 1,
		ymax = self.inner_grid_size.y + self.perim_thickness.y
	}
	for x in range(bounds.xmin, bounds.xmax + 1):
		for y in range(bounds.ymin, bounds.ymax + 1):
			var tile
			if (x == bounds.xmin or x == bounds.xmax or y == bounds.ymin or y == bounds.ymax):
				tile = self.__rand_tile(self.__tile_collection.item.walls)
			else:
				tile = self.__rand_tile(self.__tile_collection.item.floors)
			self.__add_tile(tile, Vector2(x, y))

func __add_other_tiles(tile_set, count=Vector2(1, 1)):
	"""
	Add a random amount of tiles into the inner grid.
	`count` vector represents the minimum (x) and maximum (y) amount.
	"""
	var n = int(rand_range(count.x, count.y))
	for i in range(n):
		var index = int(rand_range(0, self.__grid.size()))
		var xy = self.__grid[index]

		var tile = self.__rand_tile(tile_set)
		self.__add_tile(tile, xy)
		self.__grid.remove(index)

func make_board():
	randomize()

	# initialize the grid with all the available positions
	self.__grid = []
	for x in range(0, self.inner_grid_size.x):
		for y in range(0, self.inner_grid_size.y):
			self.__grid.push_back(Vector2(x, y))

	self.__add_base_tiles()
	self.__add_other_tiles(self.__tile_collection.item.obstacles, count_obstacles)
	self.__add_other_tiles(self.__tile_collection.item.items, count_items)
	self.__add_other_tiles(self.__tile_collection.item.enemies, count_enemies)

	self.__add_tile(self.__tile_collection.item.exit, Vector2(self.inner_grid_size.x, -1))
	self.__add_tile(self.__tile_collection.item.player, Vector2(-1, self.inner_grid_size.y))