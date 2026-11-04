# Personajes V3: vistas para revisión

**Renders técnicos de Blender, no capturas de Roblox Studio.** Se generan desde `assets/v3/character-geometry.json`, fuente de las superficies propias usadas por el juego. Blender aproxima la cabeza nativa y su sombreado; la cara de autoría del render representa la sonrisa clásica que el juego toma del recurso integrado de Roblox.

Junkbot y Deathspeaker muestran alternativas propias provisionales. Al jugar se intenta cargar sus originales. El cabello Bacon también puede sustituirse por Pal Hair oficial. Estas imágenes no verifican el catálogo ni Studio.

![Vista conjunta](../dist/v3/previews/01-personajes-v3.png)

## Pelotocino

![Frontal, lateral y trasera](../dist/v3/previews/02-pelotocino-tres-vistas.png)

## Yellow Guy

![Frontal, lateral y trasera](../dist/v3/previews/03-yellowguy-tres-vistas.png)

## Junkbot — alternativa propia

![Frontal, lateral y trasera](../dist/v3/previews/04-junkbot-tres-vistas.png)

## Korblox Deathspeaker — alternativa propia

![Frontal, lateral y trasera](../dist/v3/previews/05-deathspeaker-tres-vistas.png)

## Guest 666

![Frontal, lateral y trasera](../dist/v3/previews/06-guest666-tres-vistas.png)

## Tubers93

![Frontal, lateral y trasera](../dist/v3/previews/07-tubers93-tres-vistas.png)

Regeneración: `blender -b -t 4 --python tools/render_v3_characters.py`. La escena local es `dist/v3/previews/Personajes-V3.blend`; el ZIP incluye imágenes y generador reproducible.
