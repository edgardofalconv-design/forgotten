# Pelotocino — versión 2, avatar Roblox

La nueva referencia se utilizó para corregir la silueta: cuerpo delgado, brazos inclinados, manos de avatar, cabeza cilíndrica y cabello Pal Hair. Se conservan la camiseta azul con chaqueta negra, jeans negros con zapatillas blancas y la mochila básica marrón de la primera referencia.

El cuerpo usa las **14 mallas R15 del paquete oficial gratuito Man de Roblox**, escaladas. El cabello usa el recurso gratuito oficial Pal Hair. La camiseta es Blue and Black Motorcycle Shirt, que contiene el gráfico de la moto de la referencia; los pantalones son Black Jeans with White Shoes. La mochila y la cara son geometría creada para este modelo. No se han modificado FORGOTTEN V4, mapas ni scripts anteriores del juego.

## Qué incluye

- `Pelotocino.rbxm` y `Pelotocino.rbxmx`: el mismo modelo nativo en binario y XML, con MeshParts reales, Humanoid R15, Animator, 15 Motor6D, attachments, Shirt, Pants, Hair y Backpack. El modelo ya existe dentro de los archivos; el Script Animate solamente controla locomoción.
- `Pelotocino.blend`: malla editable, materiales, seis texturas empaquetadas, esqueleto de 16 huesos y clips Walk, Run y Jump. Las pistas NLA están silenciadas al abrir para mostrar la pose de reposo. Activa una pista por vez para verla.
- `Pelotocino.glb`: geometría, skin, esqueleto, texturas incorporadas y tres clips. Para insertar en Studio utiliza preferentemente RBXM/RBXMX.
- `fuentes/`: constructor, las mallas y texturas utilizadas, metadatos, compositor de texturas y validadores. `ASSETS_ROBLOX.json` identifica los recursos oficiales originales.
- `Vista_frente.png` y `Vista_espalda.png`: renders del archivo de Blender entregado.
- `Test_Pelotocino.server.lua`: prueba opcional en una experiencia nueva.
- Los tres informes `*VERIFICACION.json`, `model_stats.json` y `SHA256SUMS.txt`: comprobaciones y huellas de archivos.

## Importar y probar en Studio

1. Descomprime el ZIP y abre **una Baseplate nueva**, separada de FORGOTTEN V4.
2. En Explorer, haz clic derecho en **Workspace → Insert from File… / Insertar desde archivo…** y abre `Pelotocino.rbxm`. Puedes usar el RBXMX equivalente.
3. Espera la carga de las mallas y la ropa desde Roblox. El modelo nativo referencia assets oficiales de su CDN, como cualquier avatar con accesorios: **requiere conexión y acceso a esos recursos**. No requiere subir mallas o texturas personalizadas. Los archivos Blender/GLB sí llevan su geometría y texturas incorporadas para edición independiente.
4. Selecciona el Model `Pelotocino` y pulsa F para enfocarlo. Comprueba que aparezcan la camiseta azul con chaqueta negra, los jeans, el cabello y la mochila.
5. Para comprobarlo como NPC, crea un Script en **ServerScriptService**, pega `Test_Pelotocino.server.lua` y pulsa Play. El script ordena caminar, correr y saltar; consulta Output y revisa visualmente las articulaciones. El NPC no camina por sí solo sin una orden de movimiento.
6. Para controlarlo como jugador, retira la prueba de NPC y mueve el modelo a **StarterPlayer**, renómbralo `StarterCharacter` y pulsa Play. Realiza esto solamente en la experiencia de prueba.
7. Velocidades de muestra: `Humanoid.WalkSpeed = 12` para caminar y `22` para correr. No se agregó una tecla de sprint.
8. Para utilizar tus propias animaciones, **desactiva el Script Animate incluido** antes de reproducir AnimationTracks. La locomoción de muestra modifica los C0 de los Motor6D y no debe competir con tu Animator.

## Lo comprobado y lo pendiente

- XML válido, referencias completas, 15 partes anatómicas más raíz, 15 Motor6D alineados en reposo, 14 MeshParts corporales, ropa y accesorios. Lune 0.11.1 / rbx-dom deserializa el RBXMX, produce un RBXM y vuelve a leerlo. Ambos scripts Luau compilan.
- Blender vuelve a abrir la fuente con malla, 16 huesos, 15 grupos de pesos y seis texturas empaquetadas. Cada clip cambia la pose. El GLB contiene geometría, pesos, huesos, seis imágenes y tres animaciones, sin archivos externos.
- **No se ha importado ni ejecutado dentro de Roblox Studio.** La física, la carga de los assets en tu experiencia, las animaciones y la apariencia exacta del compositor de ropa de Roblox siguen pendientes de comprobar allí. No se afirma que esté listo para producción.
- El render de Blender emplea los mismos meshes de cuerpo y cabello. Sus atlas de ropa se recompusieron desde las plantillas oficiales; la iluminación, las costuras, la cabeza y las uniones de las piezas de la mochila pueden diferir respecto a Studio. El cuerpo se mantiene fiel al estilo de avatar, pero no se promete una copia exacta píxel por píxel de la referencia.
- El archivo nativo contiene **542 BaseParts**: el detalle de mochila/cara todavía usa primitivas para evitar subir assets propios. La fuente tiene **22.221 vértices**. Hace falta medir rendimiento en Studio y optimizar los accesorios si habrá muchos NPC simultáneos.
- Las habilidades específicas de FORGOTTEN no están definidas. Se incluyen el rig y LeftGripAttachment / RightGripAttachment para integrarlas, pero faltan sus animaciones y lógica real.
- Se entrega GLB; no se generó FBX. No se publicaron assets nuevos en Roblox ni se cambió el juego.

## Regenerar

Con Blender 4.3, desde esta carpeta ejecuta `blender -b --python fuentes/build_avatar_v2.py`. El constructor usa `fuentes/avatar_assets` y escribe en esta carpeta; puedes cambiar el destino mediante `PELOTOCINO_OUT`. Para recomponer los atlas: `python fuentes/make_clothing_atlases.py` (requiere Pillow).

Comprobaciones: `python fuentes/validate_files.py`, `blender -b --python fuentes/verify_blender.py` y `lune run fuentes/validate_roblox.luau` (Lune 0.11.1). El último comando también genera el RBXM. Estos programas no ejecutan el motor de Studio.
