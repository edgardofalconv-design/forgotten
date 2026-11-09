# Pelotocino R15 — entrega de prueba sobre FORGOTTEN V4

Esta rama modifica solamente Pelotocino y su integración. Las entregas V1, V2, V3 y V4 y sus ramas permanecen intactas. No es una entrega general V5.

## Abrir la partida

1. Extrae `Forgotten-Pelotocino-R15.zip`.
2. En Roblox Studio: **Archivo → Abrir desde archivo → Forgotten-Pelotocino-R15.rbxlx**.
3. Pulsa **Play/F5**, elige **Pelotocino** en PERSONAJES y después **JUGAR → PROBAR SOLO**.

No necesitas Rojo ni PowerShell. El campamento es solo el lobby. Los personajes actuales se construyen al ejecutar; la maqueta de edición histórica no representa el nuevo personaje.

El cuerpo visible se compone de **25 MeshParts propios**, con cabeza, ropa, manos curvas, cabello por mechones, mochila, sartén y rastreador. La física utiliza el esqueleto R15 de 15 articulaciones. El controlador intenta generar la base mediante `Players:CreateHumanoidModelFromDescriptionAsync`; también incluye una estructura R15 completa para no depender de la descarga de un avatar. Las piezas de física son invisibles; no son el cuerpo visual.

Las mallas se crean localmente con **EditableMesh**. Si ves un aviso de mallas no disponibles, activa **Mesh & Image APIs** en los ajustes de la experiencia y vuelve a pulsar Play. En experiencias publicadas Roblox puede exigir verificación del creador y permisos. No se sustituye el personaje por cubos si falla esa API. La ropa usa colores por vértice y mapas propios de tejido/cuero mediante EditableImage; si falla la API de imágenes, se conservan los colores/materiales de la malla y se pierde ese detalle textil.

## Modelo y NPC independientes

En un lugar abierto, usa **Insertar desde archivo / Insert from File** en el explorador de Studio:

- `Pelotocino-R15.rbxmx`: plantilla R15 completa, con rig, fuentes de mallas, control de animación y diez KeyframeSequences. Está anclada para inspección; FORGOTTEN la desancla al equiparla.
- `Pelotocino-NPC.rbxmx`: misma geometría, ropa y accesorios. Al pulsar Play, acércate y usa **E** para alternar las animaciones de demostración. El prompt no realiza ataques ni concede habilidades a un NPC.
- `Pelotocino-Animations.rbxmx`: las secuencias por separado, para inspección y edición en Studio. Los marcadores `Contact` y `BaconRelease` señalan los tiempos del servidor; no disparan daño desde el cliente.

Las mallas de estos archivos aparecen al ejecutar sus scripts de cliente. La geometría está incluida como datos; todavía no son MeshIds publicados y persistentes en Creator Store. No afirmamos haber exportado estos modelos desde Studio.

## Controles y comportamiento conservado

| Acción | Tecla | Regla de V4 conservada |
| --- | --- | --- |
| Rastreador | Q | 100 studs, detección 6 s, cooldown 24 s, coste 10 |
| Bacon Throw | R | Alcance 32, cura 15 a aliado o ralentiza al asesino a 8 durante 2 s; cooldown 18 s, coste 10 |
| Sartén | F | Alcance 9; ralentiza al asesino a velocidad 6 durante 2,5 s; cooldown 16 s, coste 10 |
| Lucky Bacon | G | Recupera 25 de vida; cooldown 25 s, coste 10 |

La sartén no añade daño de salud nuevo. El cabello sale a los **0,45 s**: mano izquierda retira el mechón, lo lanza corto frente a la sartén, y mano derecha lo golpea. La sartén contacta a los **0,22 s**. Impactos, objetivos válidos y cooldowns los resuelve el servidor con el sistema de V4. El proyectil visual no tiene autoridad para dañar.

El rastreador muestra una señal y dirección aproximada utilizando únicamente los objetivos autorizados por el servidor. Se guarda al finalizar la animación. Vida, energía, tienda, guardado, reglas de salida y LMS conservan sus sistemas anteriores.

## Comprobación manual necesaria

No se ha ejecutado Roblox Studio en este entorno. Pasan las comprobaciones locales con Lua 5.4/dobles de APIs y validación XML/ZIP; no sustituyen al motor.

- Comprobar que se crean las 25 mallas, se ven texturas y el rig mantiene pies, manos, cabello, mochila y objetos alineados. Revisar Output/Salida.
- Caminar, correr con Shift, saltar y recibir daño. Revisar cámara, suelo, rodillas, codos y agarres en movimiento; las animaciones son originales y procedurales, no clips publicados.
- R: comprobar retirada del mechón, contacto con sartén, vuelo, impacto y regeneración visual del cabello. F: comprobar alcance, aturdimiento y cooldown. Q: probar con asesino delante, detrás, a los lados y fuera de alcance.
- Usar **Server & Clients con tres clientes** para combate y replicación. La práctica individual no incluye un asesino controlado por IA. Con dos clientes comprobar LMS.
- Completar objetivos, escapar, volver al lobby y comprobar que regresa el avatar personal.
- Comparar NPC y jugador; medir FPS/memoria con ambos y los restantes personajes.

## Herramientas oficiales y recursos pendientes

No se han utilizado las interfaces de Rig Generator, Avatar Setup o Animation Editor aquí: Roblox Studio no está disponible en este Linux. Se consultó documentación oficial de las APIs y se prepararon modelos/secuencias compatibles para probarlos allí.

`fuentes-3d/Pelotocino-Meshes.fbx` y `Pelotocino.blend` son las mallas editables propias, no recursos extraídos de Forsaken. El cabello es una reconstrucción propia de la referencia, no el asset Pal Hair descargado. La fidelidad visual debe evaluarse con la imagen original; no se certifica una copia 1:1.

Para una versión final sin generación dinámica: importa el FBX con el importador 3D oficial de Studio; comprueba materiales, escala y nombres; publica los recursos bajo el propietario de la experiencia. Coloca las MeshParts importadas en `ReplicatedStorage/PelotocinoImportedMeshes`, conservando sus nombres. El renderizador prioriza esas piezas sobre EditableMesh. Hay que validar esa importación en Studio antes de publicarla. Avatar Setup puede emplearse para revisar la importación, sin reemplazar automáticamente el rig o sus pivotes ya preparados.

Las diez KeyframeSequences pueden revisarse con el Animation Editor o con `KeyframeSequenceProvider:RegisterKeyframeSequence` en Studio. Publicarlas y poner sus IDs en `AnimationConfig.characters.pelotocino` permite sustituir los clips procedurales; hasta entonces el juego usa el controlador incluido. No se inventaron AssetIds.
