# Diagnóstico y alcance de la corrección

La entrega anterior (`175ce29`) buscaba primero la pieza correspondiente en `ReplicatedStorage.PelotocinoImportedMeshes`; si no existía, intentaba `CreateEditableMesh` y `CreateMeshPartAsync`. Por tanto, **el orden no era «falló EditableMesh y después buscó las importadas»**: las importadas ya tenían prioridad, pero los archivos entregados no contenían esa biblioteca con MeshIds persistentes.

El `pcall` englobaba tanto la creación de las mallas como su montaje. Cualquier excepción destruía el cuerpo visual parcial y mostraba un aviso genérico. Además, guardaba `states[model]` como fallido y las siguientes llamadas salían inmediatamente, sin recuperación. El FBX antiguo no se importaba automáticamente al abrir el lugar.

Con el aviso aportado no se puede determinar el motivo exacto que devolvió Roblox: hace falta el texto posterior a «Pelotocino R15: no se reemplaza por cubos» en Output para distinguir permisos, presupuesto de EditableMesh, API o montaje. No afirmamos haber reproducido esa excepción dentro de Studio.

## Corrección

- `PelotocinoMeshLibrary`: acepta únicamente MeshParts con MeshIds y texturas persistentes. Mantiene tamaño y centro por segmento, une las mallas a los Motor6D y conserva un montaje ya instalado. No crea mallas ni imágenes mediante AssetService.
- `PelotocinoRenderer`: utiliza esa biblioteca, conserva las mallas ya montadas y reintenta errores transitorios. Limpia el aviso cuando la instalación está completa. No oculta el problema si todavía no se ha importado el FBX.
- `ClientPreview`: permite recuperar la previsualización si la biblioteca llega después de la primera actualización del cliente.
- `StudioInstall`: realiza la instalación una sola vez en edición. Valida las 25 piezas, sus texturas y su carga con ContentProvider, conecta los dos rigs, instala la plantilla jugable y guarda backups. No crea IDs falsos ni sube archivos mediante APIs de la partida.
- `tools/pelotocino_import`: exportación FBX, texturas UV, plantillas, instalador, prueba integrada, comprobaciones y empaquetado separados de las entregas históricas.

## Conservado

La geometría original, el rig, los movimientos, los tiempos de impacto, las habilidades del servidor, el daño/curación, los cooldowns y las reglas de V4 se mantienen. Las texturas trasladan los colores de los vértices y el detalle textil al FBX para que el importador no dependa del generador de imágenes del juego. No se han rediseñado otros personajes.

## Límite de la entrega

Sin ejecutar el importador autenticado de Studio no se pueden rellenar MeshIds reales del propietario. El ZIP contiene un proyecto **preparado para importar**, no un lugar ya instalado bajo tu cuenta. La guía reduce la instalación a importar un FBX y ejecutar una línea. Solo después debe comprobarse que se ve correctamente en Studio y guardar el archivo instalado.
