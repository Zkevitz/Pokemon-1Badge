### Pokemon game (clone). 

Jeux pokemon 2D like en format top_down a l'efigie des jeux de 3iem et 4iem Gen 

#### Presentation
Realise avec le moteur graphique Godot Engine 4.5 le jeux reprend toutes les mecaniques emblematiques des jeux de la license pokemon (combat, objets, evolutions, ...) a travers une courte histoire dans un monde reinvente. 

#### Conception

A l'instar des jeux pokemon le projet fonctionne princpalement sur de la donné cela signifie que tout ce qui tiens de la logique de jeux (pokemon, combat, stat, ...) est definis dans des structures de donné (Ressources Godot) plus tot quand dans le code du jeu 

les composants principalement Data driver sont :
1. Pokemon 
	1. Statistique
	2. Sprite
2. Capacité (move)
	1. Statistique
	3. Effets
	2. Animation
3. Objets (items)
	1. Statistique
	2. Sprite 
	2. effets

en dehors de cela j'ai opté pour pour une approche moderne de conception des PNJ par composition. 

#### Installation 


public : le jeux n'etant pas encore terminé il n'y a pas de date de release a l'heure actuelle 

open source : 
: 	- git clone du projet 
	- ouverture dans Godot version 4.5


#### Fonctionnalité

- combat tour par tour (logique combat similaire au jeux pokemon officiel) 
- integrations de 30Pokemons (statistique, sprite, comportement)
- intergrations de 16CT (statistique, implementation dans la logique de combat et animations)
- quelques objets de base (potion, pokeball)
- Pokeheal machine (similaire au centre pokemon)
- 2 Zones au design unique

#### Contributions 

Ce projet est actuellement en développement personnel.
Les suggestions et retours sont toutefois les bienvenus via les issues.

#### Crédits 

A realisé

