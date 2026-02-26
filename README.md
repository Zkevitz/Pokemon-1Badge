# Pokemon 1Badge

comment faire en sorte qu'un pnj se deplace d'un point A a un point B cellelule par cellule sans faire des diagonales 

Très bonne question — tu touches pile au déplacement grid “propre” façon Pokémon / Fire Emblem 👍
L’idée clé : utiliser un pathfinding sur une grille, mais interdire les diagonales, puis faire avancer le PNJ case par case.

Je te montre la méthode la plus clean en Godot 4 avec AStarGrid2D.

🧠 Principe

On construit une grille A* basée sur le TileMapLayer

On désactive les diagonales

On calcule un chemin A → B (liste de cellules)

Le PNJ avance une cellule à la fois, dans l’ordre

🧩 1. Créer la grille A*
var astar := AStarGrid2D.new()

func setup_astar():
	astar.region = tilemap.get_used_rect()	
	astar.cell_size = tilemap.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()


👉 DIAGONAL_MODE_NEVER = aucune diagonale, jamais.

🧱 2. Marquer les cases bloquées
Avec un Custom Data walkable
func update_walkable_cells():
	for cell in astar.region:
		var data = tilemap.get_cell_tile_data(cell)
		if data == null or not data.get_custom_data("walkable"):
			astar.set_point_solid(cell, true)

🧭 3. Calculer le chemin A → B
func get_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	return astar.get_id_path(from, to)


📌 Résultat :
[ (2,3), (3,3), (4,3), (4,4) ] → aucune diagonale

🚶‍♂️ 4. Avancer cellule par cellule
var path: Array[Vector2i] = []
var path_index := 0

func start_move(from: Vector2i, to: Vector2i):
	path = get_path(from, to)
	path_index = 0
	move_next_cell()

func move_next_cell():
	if path_index >= path.size():
		return

	var cell := path[path_index]
	path_index += 1

	var target_pos = tilemap.map_to_local(cell)
	create_tween().tween_property(
		self,
		"global_position",
		target_pos,
		0.2
	).finished.connect(move_next_cell)


✨ Le PNJ :

suit le chemin

avance d’une seule cellule à la fois

jamais en diagonale

🧠 Astuces importantes
🔹 Éviter le “zig-zag”
astar.default_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN

🔹 Recalculer si le monde change
update_walkable_cells()
astar.update()

🧪 Exemple d’utilisation
var start = tilemap.local_to_map(global_position)
var end = Vector2i(10, 6)

start_move(start, end)

🎯 Résultat final

✔ Déplacement cellule par cellule
✔ Aucune diagonale
✔ Chemin intelligent
✔ Animation fluide possible

Si tu veux, je peux aussi te montrer :

🔁 déplacement tour par tour

🤖 PNJ qui patrouille

🚫 éviter les autres PNJ

🎮 mouvement style Pokémon strict (pas de tween)

Dis-moi ce que tu veux creuser 👌

est ce que si mon tilemaplayer fait 800 par 800 je peux limiter la zone de l'astargrid a moins que ca taille ?

Oui — et tu as carrément intérêt à le faire 👍
Limiter la zone de l’AStarGrid2D est normal, prévu, et beaucoup plus performant que de lui donner tout un TileMapLayer de 800×800.

🧠 L’idée clé

👉 AStarGrid2D ne doit couvrir que la zone utile
👉 La grille peut être beaucoup plus petite que le TileMapLayer
👉 Tu peux même la déplacer dynamiquement autour du PNJ

✅ Méthode simple : limiter avec get_used_rect()

Si ton TileMapLayer est grand mais peu rempli :

astar.region = tilemap.get_used_rect()
astar.update()


📌 Avantage :

la grille couvre uniquement les cellules utilisées

zéro effort

⚠️ Inconvénient :

toujours trop grand si toute la map est remplie

✅ Méthode recommandée : zone locale autour du PNJ

Par exemple : 20×20 cellules autour du PNJ

func set_astar_region(center: Vector2i, radius: int):
    astar.region = Rect2i(
        center - Vector2i(radius, radius),
        Vector2i(radius * 2 + 1, radius * 2 + 1)
    )
    astar.update()


Utilisation :

var center = tilemap.local_to_map(global_position)
set_astar_region(center, 10) # 21x21 cellules


💡 Parfait pour :

PNJ locaux

foules

maps énormes

✅ Méthode hybride (la plus propre)

A* global → zones / chunks

A* local → déplacement précis

Mais pour 90% des jeux : zone locale = largement suffisant

🧱 Attention aux limites de la map

Toujours clamp la région :

func clamp_region(rect: Rect2i) -> Rect2i:
    var map_rect = tilemap.get_used_rect()

    var pos = rect.position.clamp(
        map_rect.position,
        map_rect.position + map_rect.size - rect.size
    )

    return Rect2i(pos, rect.size)

🧠 Ce qu’il faut retenir

✔ Un TileMap 800×800 ne veut PAS dire A* 800×800
✔ astar.region peut être n’importe quelle taille
✔ Plus petit = plus rapide
✔ Tu peux la déplacer à la volée

Si tu veux, je peux te montrer :

📦 système par chunks

🤖 plusieurs PNJ partageant la même grille

🔄 recalcul intelligent sans lag

⚡ optimisations concrètes en prod

Dis-moi ton cas précis (nombre de PNJ, taille réelle jouée, type de jeu) et je t’oriente au mieux 👌
