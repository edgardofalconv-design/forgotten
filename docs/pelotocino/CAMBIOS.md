# Cambios de esta rama

Entrega de Pelotocino sobre el commit V4 `304894192ab5829fbd6f0a05e569bc699525c4e6`. No crea V5 ni sobrescribe los archivos de V1–V4.

- `PelotocinoRig`, `PelotocinoMeshData`, `PelotocinoRenderer` y `PelotocinoSurface`: cuerpo R15 con 25 mallas propias; superficies curvas, rostro, cabello por mechones, ropa, mochila y tres objetos. Los cuerpos físicos del rig son invisibles. El jugador, el NPC y la vista de selección reutilizan la misma geometría.
- `PelotocinoMotion`: respiración, pasos, carrera, salto, caída, daño y acciones con articulaciones R15. Diez secuencias exportadas; el juego usa movimiento procedural compartido entre observadores.
- `CharacterFactory`, `CharacterMotion`, `BasicAnimation`, `ClientPreview` e inicio del cliente: integración exclusiva del nuevo Pelotocino. Se conservan las rutas de creación de los demás personajes.
- `ClientEffects`: el cabello proyectado sale de la sartén usando el mismo mechón de malla. `Abilities`: proporciona al rastreador el número de enemigos detectados y su caducidad. Los valores de daño/curación, ralentización, energía, cooldown y tiempos del servidor no cambian.
- `tools/pelotocino`: modelado, exportación R15/NPC/secuencias, renders, vídeo, pruebas y empaquetado. Los exportadores actuales protegen los nombres históricos.

Se verifican localmente la geometría, los 15 enlaces del rig, igualdad del jugador/NPC, los límites de tiempo del combate, rastreador dentro/fuera del alcance, regresiones de V4 y contenido del paquete. Los informes describen los dobles de APIs utilizados; no equivalen a ejecutar Studio.

Pendiente de comprobación real: permisos y comportamiento de EditableMesh/EditableImage, apariencia bajo la iluminación del juego, física, cámara, replicación con varios clientes y rendimiento. Las mallas y clips no están publicados como AssetIds. El FBX es una fuente de mallas; el rig y los controladores se entregan en los archivos Roblox. La reconstrucción mantiene el diseño de la referencia, pero no se declara una réplica 1:1.
