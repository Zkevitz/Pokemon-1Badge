extends Sprite2D

@onready var particles := $GPUParticles2D

func _ready() -> void:
	# Dupliquer le material pour éviter de modifier la ressource partagée
	material = material.duplicate()
	
	# Récupérer la couleur de teinte du shader
	var tint_color = material.get_shader_parameter("tint_color")
	
	# Configurer les particules
	setup_particles(tint_color)

func setup_particles(tint_color: Color) -> void:
	if not particles:
		push_warning("Aucun noeud GPUParticles2D trouvé !")
		return
	
	# S'assurer que les particules ont un ProcessMaterial
	if not particles.process_material:
		particles.process_material = ParticleProcessMaterial.new()
	
	# Dupliquer le material pour éviter de modifier la ressource partagée
	particles.process_material = particles.process_material.duplicate()
	
	var process_mat = particles.process_material as ParticleProcessMaterial
	
	# Configuration de base des particules
	particles.emitting = true
	#particles.amount = 50  # Nombre de particules
	#particles.lifetime = 2.0  # Durée de vie d'une particule
	#particles.preprocess = 0.5
	#particles.explosiveness = 0.0
	particles.randomness = 0.5
	
	# Configuration du ProcessMaterial
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = Vector3(texture.get_width() / 2.0, 5.0, 0.0)
	
	# Direction et gravité
	process_mat.direction = Vector3(0, 1, 0)  # Vers le bas
	process_mat.spread = 10.0  # Légère dispersion
	process_mat.gravity = Vector3(0, 98.0, 0)  # Gravité vers le bas
	
	# Vitesse initiale
	process_mat.initial_velocity_min = 50.0
	process_mat.initial_velocity_max = 100.0
	
	# Taille des particules
	process_mat.scale_min = 0.5
	process_mat.scale_max = 1.5
	
	# Couleur
	process_mat.color = tint_color
	
	# Fade out à la fin de la vie
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))  # Début : opaque
	gradient.add_point(1.0, Color(1, 1, 1, 0))  # Fin : transparent
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	
	process_mat.color_ramp = gradient_texture
	
	print("Particules configurées avec succès!")
