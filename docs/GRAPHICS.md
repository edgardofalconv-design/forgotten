# Revisión visual del lobby

## Cambios incorporados al juego

- 1348 piezas de lobby; detalles pequeños sin colisión. Tablones segmentados con juntas y clavos; piedra individual alrededor del hogar; herrajes y remaches.
- Cojines de terciopelo, costuras, bordes y flecos de alfombra, vajilla, carta, botella y vela; billar con bandas, diamantes y bolas.
- Faroles con jaula y vidrio, cortinas plegadas, luz cálida del fuego y relleno azul en ventanas.
- Sombras globales, exposición moderada, corrección de color y bloom limitado para preservar legibilidad.
- Materiales nativos de Roblox (WoodPlanks, Cobblestone, Slate, Fabric, Metal y Glass) activos sin depender de descargas nuevas.
- Modelo estático `Workspace/LobbyPreview` visible al abrir el `.rbxlx`. El servidor lo elimina al comenzar Play y crea la versión interactiva una vez. Las interacciones solo funcionan en Play.

El modelo estático solo es una vista de edición. Cambios permanentes se hacen en el constructor `src/shared/Lobby.luau`; editar únicamente el modelo estático no modifica el escenario que se crea al jugar. Con Rojo, el escenario se genera al jugar; la vista estática la añade nuestro exportador Python al `.rbxlx`.

## Texturas originales

`assets/textures/` contiene doce PNG de 512×512: roble, caliza, tejido y latón envejecido, cada uno con color, normal y roughness. Se generaron mediante `tools/make_textures.py`, sin imágenes de terceros. Licencia: utilizables como parte de este proyecto.

Para activarlos como MaterialVariant, subir los mapas mediante las herramientas de assets de Roblox y rellenar los tres IDs de cada entrada en `src/shared/MaterialPack.luau` (`rbxassetid://ID`). Verificar permisos en la experiencia. Con campos vacíos se conservan los materiales nativos. **Los PNG suministrados no quedan cargados en Roblox automáticamente.** El latón usa el comportamiento metálico de su material base.

## Qué representan las imágenes

Las vistas `dist/previews/*.png` se renderizan en Blender a partir de las posiciones, tamaños, rotaciones, colores, luces y textos del constructor real. El exportador evalúa el constructor usando un adaptador geométrico Lua 5.4, no el motor Roblox.

La geometría procede del juego. El render añade biseles de presentación, sombreado PBR, rebotes y rellenos de luz aproximados. Las transparencias, la exposición y el color pueden diferir de Studio. No son capturas de Roblox Studio ni garantizan el mismo resultado gráfico en la aplicación. Los NPC continúan siendo representaciones básicas; no se añadieron modelos ni animaciones finales.

## Reproducción

Entorno Linux de este proyecto:

```
python3 tools/make_textures.py
python3 tools/export_preview.py
python3 tools/build_place.py
blender -b -t 6 --python tools/render_preview.py
# Para reutilizar la escena y las cámaras finales:
blender -b -t 6 --python tools/render_saved_preview.py
```

`export_preview.py` requiere la biblioteca `liblua5.4.so.0`; el render requiere Blender. La exportación del `.rbxlx` funciona con Python estándar y el JSON geométrico incluido. Tras modificar el constructor hay que regenerar ese JSON para actualizar la vista estática.

## Validación y límites

Verificados: evaluación geométrica del constructor, sintaxis normalizada a Lua 5.4, inclusión de seis scripts y 1348 piezas en el XML, conservación de fuentes y mapas de textura completos. Pendiente: ejecución y capturas en Roblox Studio, permisos de texturas al subirlas, colisiones y rendimiento con varios clientes/dispositivos. No se ha medido FPS. Los pequeños clavos y adornos aumentan el número de objetos; revisar presupuesto gráfico antes de publicar para móviles.
