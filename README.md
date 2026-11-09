# FORGOTTEN — Pelotocino con MeshParts importadas

Corrección de carga sobre la entrega de Pelotocino R15. Conserva V1–V4 y la entrega anterior. No rediseña el personaje ni modifica sus animaciones, habilidades o reglas.

**Requiere importar un FBX una vez en Roblox Studio.** El ZIP todavía no contiene MeshIds publicados bajo tu cuenta. Después de importar y ejecutar el instalador incluido, guarda el lugar; las MeshParts quedan conectadas y visibles sin EditableMesh durante las partidas.

- [Descargar ZIP completo](https://github.com/edgardofalconv-design/forgotten/raw/refs/heads/fix/pelotocino-meshparts-20261109/dist/Forgotten-Pelotocino-MeshParts.zip).
- [Guía exacta: importar un archivo y ejecutar una línea](docs/pelotocino-importado/IMPORTAR.md).
- [Diagnóstico y archivos cambiados](docs/pelotocino-importado/DIAGNOSTICO.md).
- [Vistas del FBX reimportado en Blender](docs/pelotocino-importado/VISTAS.md).

El instalador comprueba las 25 mallas/texturas, prepara el personaje jugable y el NPC con la misma apariencia y conserva backups. Las pruebas locales incluyen fallos de importación, rig, animaciones, combate y partidas. No se ha ejecutado Roblox Studio aquí.

Construcción: `python3 tools/pelotocino_import/build.py`. Los recursos importables están en `dist/pelotocino-importado/fuentes-3d/`. El FBX reutiliza la geometría existente y agrega UV/texturas exportables. No se inventaron AssetIds.
