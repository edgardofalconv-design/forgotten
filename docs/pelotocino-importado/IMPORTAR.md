# Pelotocino — instalación de MeshParts persistentes

**Esta entrega requiere importar el FBX una vez en Roblox Studio.** El `.rbxlx` y los `.rbxmx` traen el rig, el instalador y todos los scripts, pero todavía no contienen MeshIds publicados bajo tu cuenta. Antes de importar no aparecerá el cuerpo. No se ha ejecutado Roblox Studio aquí.

Después de importar e instalar, las mallas quedan guardadas en el proyecto y se clonan durante las partidas. Pelotocino no usa `CreateEditableMesh`, `CreateMeshPartAsync`, `EditableImage` ni descargas del catálogo para dibujar su cuerpo. No necesitas Roblox Studio Assistant, Rojo ni PowerShell.

## 1. Abre la prueba

Extrae **todo** `Forgotten-Pelotocino-MeshParts.zip`. En Studio, abre `Forgotten-Pelotocino-MeshParts.rbxlx` mediante **Archivo / File → Abrir desde archivo / Open from File**. Mantén la prueba detenida: no pulses Play todavía.

## 2. Importa un único archivo

En **Archivo / File → Importar / Import**, selecciona **`fuentes-3d/Pelotocino-Importar.fbx`**. En versiones anteriores el botón se llama **Import 3D**.

Deja los tres PNG junto al FBX. Están también incrustados, pero las copias externas facilitan la resolución de texturas. En el importador, abre la configuración del modelo y usa:

| Ajuste | Valor |
| --- | --- |
| Creator | Tu usuario, o el grupo propietario de FORGOTTEN |
| Upload to Roblox | Activado |
| Add to Workspace | Activado |
| Import Only As Model | Activado; conserva el conjunto como modelo |
| Import as Package | Desactivado |
| Merge Meshes | **Desactivado**; deben conservarse 25 MeshParts |
| Rig Type, si aparece | **No Rig**; el rig R15 ya está preparado en el proyecto |
| Open in Avatar Setup, si aparece | Desactivado |
| Scale Unit | Studs |
| Anchored | Activado para inspeccionar el modelo importado |

Conserva la orientación del archivo. No gires, unas ni renombres sus piezas. Comprueba que la previsualización tenga cuerpo, cara, cabello, camiseta azul, mochila y equipo; no debería verse todo blanco. Si el importador muestra errores de textura, localiza los PNG de esa misma carpeta antes de continuar.

Pulsa **Import** y espera a que finalice la subida. En el Explorador, selecciona el **Model completo** recién importado dentro de Workspace, no una pieza individual. El menú contextual **Find in Workspace** del importador ayuda a localizarlo.

## 3. Conecta todo con una línea

Con Play detenido y el modelo importado seleccionado, pulsa **Ctrl+9** en Windows para abrir la **Command Bar / Barra de comandos**. También está en **Window / Ventana → Script → Command Bar**; en versiones antiguas aparece en Vista. Pega esta línea y ejecútala con Enter, o con el botón Run de la barra si usas la versión multilínea:

```lua
require(game:GetService("ReplicatedStorage"):WaitForChild("PelotocinoSetup")).install()
```

No se pega en Assistant ni dentro de un Script. La línea llama al instalador incluido y legible en `tools/pelotocino_import/StudioInstall.luau`.

El instalador comprueba nombres, proporciones, MeshIds, texturas y carga de recursos con Roblox. Si falta algo, detiene la instalación y lo indica en **Output / Salida**. No sustituye cuerpos por cubos ni borra una instalación válida cuando falla la validación.

Si todo pasa, Output muestra **«PELOTOCINO INSTALADO: 25/25 MeshParts y texturas cargadas»**. Se crean:

- `ReplicatedStorage.PelotocinoImportedMeshes`: biblioteca de las 25 mallas con texturas.
- `ServerStorage.CharacterModels.pelotocino`: modelo que equipa FORGOTTEN al iniciar la partida.
- `Workspace.PelotocinoRevision.Pelotocino_R15` y `Pelotocino_NPC`: dos modelos visibles para inspección y exportación, con la misma geometría y controladores.
- `ServerStorage.PelotocinoImportBackups`: copia de cualquier instalación reemplazada.

El FBX original sin rig se conserva también en el backup; así no queda un tercer personaje inmóvil con colisiones dentro del campamento.

La carpeta de revisión queda seleccionada. Sitúa el cursor sobre la vista 3D y pulsa **F** para encuadrarla. **Comprueba visualmente ambos modelos antes de Play**: cara al frente, camiseta azul, manos, piernas, mochila, sartén y rastreador. Guarda mediante **Archivo → Guardar como** con un nombre nuevo, por ejemplo `Forgotten-Pelotocino-Instalado.rbxlx`. No sobrescribas V4.

## 4. Juega y guarda modelos portátiles

Pulsa **Play → PERSONAJES → Pelotocino → JUGAR → PROBAR SOLO**. El personaje se equipa al empezar la partida. Conserva Q rastreador, R lanzamiento de cabello, F sartén y G Lucky Bacon. El NPC de revisión tiene el prompt **E** para recorrer las animaciones.

Después de detener Play, puedes exportar cada modelo de `Workspace.PelotocinoRevision` con **clic derecho → Save to File / Guardar en archivo**. Esos archivos guardados **después de instalar** incluyen las MeshParts conectadas y reutilizan sus MeshIds; ya no necesitan el instalador. Los `.rbxmx` originales del ZIP son plantillas previas a esa instalación, no modelos con recursos publicados previamente.

Para trasladar el juego a otra experiencia conserva también la biblioteca de ReplicatedStorage, necesaria para clonar el mechón proyectado. Si publicas una prueba online, usa un lugar nuevo y el mismo propietario que los recursos; comprueba que la experiencia tenga permiso para usarlos. Importar con **Add to Workspace** en una experiencia guardada/publicada ayuda a conceder ese acceso. No publiques encima de V4 para probar esta entrega.

## Si algo falla

| Mensaje | Qué hacer |
| --- | --- |
| «Falta: nombre...» o nombres duplicados | Reimporta el FBX completo con Merge Meshes desactivado y selecciona el Model completo. No mezcles dos importaciones en el mismo contenedor. |
| «MeshId sin publicar» | Espera a que termine el importador; usa Upload to Roblox activado. No uses el FBX antiguo de la entrega anterior. |
| «Textura sin importar» | Verifica los PNG y la previsualización del importador. Cada MeshPart necesita TextureID o SurfaceAppearance.ColorMap válido. |
| «Proporciones/ejes alterados» | Reimporta sin rotar/deformar objetos y conservando la orientación del archivo. El instalador normaliza una escala uniforme, no corrige ejes cambiados. |
| «Roblox no pudo cargar los recursos...» | Revisa Creator, permisos de la experiencia, el estado de moderación y el error detallado en Output; vuelve a ejecutar la misma línea cuando el recurso esté disponible. |
| «Importación pendiente» durante Play | Pulsa Stop, instala en modo edición y guarda. Los cambios realizados durante Play se pierden al detenerlo. |

No necesitas activar Mesh & Image APIs **para Pelotocino**. Los demás personajes conservan sus sistemas anteriores.

## Qué se verificó y qué falta

Localmente: mismas 25 mallas y 17.496 triángulos, FBX reimportado en Blender con UV/texturas y error de coordenadas inferior a 0,00001; montajes del rig, jugador/NPC idénticos, instalador con errores simulados y backups, sincronización visual y reglas originales de combate, cinco recorridos simulados de partida y entregas anteriores intactas.

Las pruebas Luau se ejecutaron mediante Lua 5.4 adaptado y dobles de APIs. **Pendiente en Studio:** importación real, autorización de MeshIds, apariencia, cámara, colisiones, animaciones, rendimiento y replicación con varios clientes. Para probar rastreador/combate usa Server & Clients con al menos dos jugadores; la práctica individual no trae un asesino de IA.

Consulta los ajustes del [importador oficial de Roblox](https://create.roblox.com/docs/studio/importer). La guía se contrastó con [creator-docs, commit ccc2b01](https://github.com/Roblox/creator-docs/blob/ccc2b01d9bf8b85dee2905d1aaff3444fcbd01c5/content/en-us/studio/importer.md), sin usar la interfaz de Studio aquí.
