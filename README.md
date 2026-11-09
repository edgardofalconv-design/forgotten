# FORGOTTEN — Pelotocino R15

Entrega específica de Pelotocino sobre V4. V1–V4 y los otros cinco personajes se conservan.

[Descargar ZIP completo](https://github.com/edgardofalconv-design/forgotten/raw/refs/heads/character/pelotocino-r15-20261108/dist/Forgotten-Pelotocino-R15.zip) · [Descargar prueba .rbxlx](https://github.com/edgardofalconv-design/forgotten/raw/refs/heads/character/pelotocino-r15-20261108/dist/Forgotten-Pelotocino-R15.rbxlx)

Extrae **Forgotten-Pelotocino-R15.zip**, abre **Forgotten-Pelotocino-R15.rbxlx** en Roblox Studio y pulsa **Play → PERSONAJES → Pelotocino → JUGAR → PROBAR SOLO**.

Incluye cuerpo visible de mallas propias, rig R15, ropa, cabello 3D, mochila, sartén, mechón lanzable, rastreador y NPC con la misma apariencia. La animación Bacon Throw retira el mechón con la mano izquierda y lo golpea con la sartén derecha a los 0,45 s. Se mantienen los valores de habilidades de V4.

**Requisito visual:** EditableMesh / Mesh & Image APIs disponibles, o instalación de las mallas FBX incluidas. Si la API no funciona, aparece un aviso; no se dibuja un cuerpo de cubos. Las mallas aparecen al ejecutar y todavía no son recursos definitivos publicados en Creator Store.

- [Abrir, importar el NPC, controles y pruebas manuales](docs/pelotocino/ABRIR_Y_PROBAR.md).
- [Vistas y demostración de animaciones](docs/pelotocino/VISTAS.md): Blender, no capturas de Studio.
- `dist/pelotocino/`: modelo R15, NPC, secuencias y fuentes 3D.
- `dist/Forgotten-Pelotocino-R15.rbxlx`: proyecto de prueba integrado.

No se ejecutó Roblox Studio ni sus editores gráficos aquí. Las pruebas locales verifican reglas, estructura, mallas, animaciones y empaquetado mediante dobles de APIs; quedan pendientes física, replicación, permisos, rendimiento y revisión visual en el motor. El modelado es propio a partir de la imagen del autor; no se certifica 1:1.

Desarrollo: `python3 tools/pelotocino/build.py`. No ejecutar los empaquetadores históricos sobre estas fuentes para sobrescribir entregas anteriores.

El empaquetador usa las vistas y el vídeo ya generados. Para cambiar el arte, las fuentes están en `tools/pelotocino/geometry.py`, `render.py` y `demo.py`; las muestras de movimiento se exportan con `animations.py`. La validación detecta renders desactualizados. Requiere Python, NumPy, Pillow, liblua5.4 y FFmpeg; Blender solo para volver a generar las vistas.
