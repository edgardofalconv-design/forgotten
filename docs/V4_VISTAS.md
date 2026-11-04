# Personajes V4: vistas para revisión

**Renders técnicos de Blender, no capturas de Roblox Studio.** Se generan desde `assets/v4/character-geometry.json`, fuente de las superficies propias usadas por el juego. Blender aproxima la cabeza nativa y su sombreado; la cara de autoría del render representa la sonrisa clásica que el juego toma del recurso integrado de Roblox.

Yellow Guy sigue la descripción escrita del usuario: piel amarilla, cabello dorado elevado, rostro confiado, chaqueta negra abierta, camiseta azul y pantalones oscuros. No se recibió la nueva imagen 3. Las proporciones y el rostro proceden de `assets/v4/rig-proportions.json` y `faces.json`.

Junkbot y Deathspeaker muestran alternativas propias provisionales. Al jugar se intenta cargar sus originales. El cabello Bacon también puede sustituirse por Pal Hair oficial. Estas imágenes no verifican el catálogo ni Studio.

![Vista conjunta](../dist/v4/previews/01-personajes-v4.png)

## Pelotocino

![Frontal, lateral y trasera](../dist/v4/previews/02-pelotocino-tres-vistas.png)

## Yellow Guy

![Frontal, lateral y trasera](../dist/v4/previews/03-yellowguy-tres-vistas.png)

## Junkbot — alternativa propia

![Frontal, lateral y trasera](../dist/v4/previews/04-junkbot-tres-vistas.png)

## Korblox Deathspeaker — alternativa propia

![Frontal, lateral y trasera](../dist/v4/previews/05-deathspeaker-tres-vistas.png)

## Guest 666

![Frontal, lateral y trasera](../dist/v4/previews/06-guest666-tres-vistas.png)

## Tubers93

![Frontal, lateral y trasera](../dist/v4/previews/07-tubers93-tres-vistas.png)

Regeneración: `blender -b -t 4 --python tools/render_v4_characters.py`. La escena local es `dist/v4/previews/Personajes-V4.blend`; el ZIP incluye imágenes y generador reproducible.
