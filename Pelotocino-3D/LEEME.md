# Pelotocino para FORGOTTEN — modelo independiente

Modelo 3D real basado en la referencia proporcionada: cabeza clara con sonrisa, pelo castaño por mechones, camiseta azul, chaqueta negra abierta, pantalones oscuros, zapatillas claras y mochila marrón. No se ha modificado FORGOTTEN V4 ni ningún mapa. Esta entrega debe probarse primero en una experiencia vacía.

## Archivos

- `Pelotocino.rbxm` y `Pelotocino.rbxmx`: el mismo modelo en formato binario y XML. Contienen geometría persistente, Humanoid R15, Animator, 15 Motor6D, attachments, cabello y mochila como Accessories y un Script Animate para locomoción de muestra. No son generadores de piezas: el cuerpo y los accesorios ya están dentro de los archivos.
- `Pelotocino.blend`: fuente editable con malla, materiales, textura empaquetada, esqueleto de 16 huesos y clips Walk, Run y Jump. Las pistas NLA están silenciadas al abrir para mostrar la pose de reposo; activa una pista por vez para previsualizarla.
- `Pelotocino.glb`: malla con skin, esqueleto, textura incorporada y tres clips. El archivo principal para Studio es el RBXMX; el GLB sirve de intercambio y edición y no sustituye la configuración nativa del Humanoid.
- `Pelotocino_palette.png`: textura de colores usada por Blender/GLB. La trama de denim, la cara y los detalles de Roblox se representan con geometría y materiales nativos; no requieren subir imágenes a Roblox.
- `Vista_frente.png` y `Vista_espalda.png`: renders del modelo real entregado.
- `fuentes/`: constructor de Blender, script de animación y validadores.
- `Test_Pelotocino.server.lua`: prueba opcional para una Baseplate nueva.
- `VERIFICACION.json`: resultados reales y comprobaciones pendientes.

## Insertar en Roblox Studio

1. Descomprime el ZIP y abre **una Baseplate nueva**, separada de FORGOTTEN V4.
2. En Explorer, haz clic derecho en **Workspace → Insert from File… / Insertar desde archivo…** y selecciona `Pelotocino.rbxm` (o `Pelotocino.rbxmx`, que contiene el mismo modelo). También puedes arrastrar el archivo a la vista 3D si tu versión lo permite.
3. Verifica que aparezca el Model `Pelotocino` con `Humanoid`, `HumanoidRootPart`, cuerpo, `Hair` y `Backpack`. Usa **F** con el modelo seleccionado para enfocarlo.
4. Para la prueba automática, crea un Script en **ServerScriptService**, pega `Test_Pelotocino.server.lua` y pulsa **Play**. Observa caminar, correr y saltar; consulta **Output** para ver los resultados. El NPC no se mueve por sí solo sin una orden de movimiento.
5. Para controlarlo como jugador, en esta Baseplate mueve el modelo a **StarterPlayer** y renómbralo `StarterCharacter`. Pulsa Play y usa los controles habituales. La prueba anterior es únicamente para el NPC en Workspace; retírala al probar como jugador.
6. Caminar/correr se selecciona según la velocidad: `Humanoid.WalkSpeed = 12` y `22` respectivamente. No se ha añadido una tecla de sprint.
7. Para animaciones propias, **desactiva el Script `Animate` incluido** antes de usar Animation Editor o tus AnimationTracks. El script de muestra modifica C0; no debe competir con otro sistema de animación.

## Alcance y límites

- Comprobado mediante archivos: XML válido, referencias internas, 15 partes R15 más raíz, 15 articulaciones alineadas en reposo, piezas sin anclar, accesorios con Handle; GLB con malla, pesos, huesos, textura y animaciones incorporados. La fuente se vuelve a abrir en Blender y se comprueba el cambio de pose de cada clip. Lune 0.11.1 / rbx-dom deserializa el RBXMX, genera un RBXM y vuelve a leerlo; también compila el Luau del Script Animate. Esto comprueba el formato de archivos, no sustituye una prueba en Studio.
- **No se ha abierto ni ejecutado en Roblox Studio.** No se afirma que la importación, la física, la reproducción de animaciones o la compatibilidad con sistemas existentes estén verificadas en el motor. Ejecuta la prueba incluida y revisa hombros, manos, rodillas y mochila antes de incorporarlo al juego.
- El dibujo oscuro de la camiseta es una aproximación: la referencia no permite leerlo exactamente. El resultado es una reconstrucción estilizada, no una copia de los assets originales. Los mechones y los detalles pequeños pueden diferir.
- Las habilidades de FORGOTTEN no están definidas en esta solicitud y no se ha inventado ninguna. Se incluyen articulaciones y LeftGripAttachment / RightGripAttachment para animarlas; falta integrar las habilidades y sus animaciones reales.
- El RBXMX/RBXM usa **2.268 BaseParts** para ser autocontenido, sin IDs de meshes ni texturas que exijan publicación previa. Es una versión para evaluación visual y del rig; requiere medir rendimiento y convertir detalles en MeshParts y publicar esos assets para producción, especialmente con varios NPC. La fuente GLB/Blender también contiene geometría densa (~387.000 vértices); requiere reducción de polígonos para producción.
- Materiales de Blender/GLB y Roblox no son idénticos. Roblox usa colores, Fabric/Metal/SmoothPlastic; el cuero se aproxima con color y forma. La textura de paleta no es un atlas PBR detallado.
- Se entrega GLB, no FBX. No se han publicado assets en Roblox ni modificado scripts del juego.

## Regenerar la fuente

Con Blender 4.3, ejecuta `blender -b --python fuentes/build_pelotocino.py` desde esta carpeta. El constructor escribe en la carpeta de la entrega; puedes elegir otra mediante la variable de entorno `PELOTOCINO_OUT`. `scene.json` conserva también los datos geométricos en coordenadas Roblox (Y arriba, -Z frente). Blender/GLB fusionan y suavizan las superficies; el RBXMX conserva las primitivas nativas, por lo que pueden verse pequeñas diferencias en sus uniones.

Para volver a generar el binario y comprobarlo con Lune 0.11.1, desde la carpeta descomprimida ejecuta `lune run fuentes/validate_roblox.luau`. Para comprobar la fuente: `blender -b --python fuentes/verify_blender.py`. Para el XML y el GLB: `python fuentes/validate_files.py`. Lune es una herramienta independiente: estas comprobaciones no ejecutan el motor de Roblox.
