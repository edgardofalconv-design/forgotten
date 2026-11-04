# Auditoría y cambios de la primera prueba

Se continuó sobre el repositorio existente. Antes de modificarlo se guardaron los scripts, herramientas, documentos, configuración y lugar anterior en `backups/pre-playable-2026-11-03.zip`. El repositorio no tenía commits: los archivos existentes estaban sin seguimiento; no se borró ni reinicializó Git.

## Inventario de entrada

100 archivos, aproximadamente 117 MB incluyendo entregas comprimidas y escenas de Blender. Había 13 fuentes Luau (incluyendo herramientas), 15 herramientas Python, seis FBX, seis GLB, 30 PNG, un lugar `.rbxlx` y un modelo estático `.rbxmx`. Se revisaron la estructura, los scripts de ejecución, módulos, configuración, exportadores, documentación y referencias. Los recursos binarios se inventariaron y conservaron; no se verificaron visualmente como originales ni se ejecutaron en Studio.

## Hallazgos y resolución

| Hallazgo inicial | Resolución |
| --- | --- |
| Yellow Guy apuntaba al paquete Junkbot 589; Baller ocupaba un puesto del lanzamiento | IDs independientes `yellowguy` y `junkbot`. Baller preservado en FutureRoster, fuera del plantel activo |
| El catálogo cargaba un R15 original, pero no se había ejecutado en Studio | Se conserva la ruta AssetService → UserOutfit → HumanoidDescription → modelo R15; se corrige el ID y se añaden validación, migración de plantilla antigua, reintento y provisional identificado |
| Un fallo del catálogo impedía jugar con el robot | Provisional de Junkbot mientras falla la carga; original usado en la siguiente aparición cuando esté disponible |
| Al usar avatar R6 con Junkbot faltaba animación básica | Rigs completos R6/R15 y animación local básica sin dependencias de assets externos |
| Apariencias dependían de las proporciones del avatar personal | Fábrica de rigs R6 provisionales y ruta separada para rigs completos definitivos; se conserva la restauración del avatar del lobby |
| Importación de mallas podía ocultar miembros sin reemplazo | Se exigen seis piezas corporales; se rechaza el antiguo robot mal nombrado como Yellow Guy |
| Ronda de 150 s, cuatro fragmentos y victoria automática | Reglas modulares: 240 s, cuatro generadores, cuatro puzles, cápsulas, apertura condicionada y escape físico |
| LMS usaba min(reloj, 90), reducía pero nunca ampliaba el reloj | LMS fija exactamente 90 s, abre a cero y exige cruzar; prioridad musical explícita |
| No había energía ni asignación automática | Energía y sprint en servidor; un asesino asignado con rotación y selección conservada |
| Cabaña aislada sin campamento exterior | Se conserva la cabaña detallada, se añaden dos cabañas abandonadas y bosque al lobby |
| El escenario de prueba debía mantenerse separado | Bosque con ruinas a 400 studs del lobby; objetivos y puerta solo en ese escenario |
| Exportador solo incluía el script raíz del servidor | Ahora incrusta también los ModuleScripts hijos World y Objectives, y valida las fuentes contra los archivos |
| Probar requería varios clientes incluso para recorrer objetivos | Modo de práctica individual, exclusivo de Studio, con objetivos normales y sin asesino/LMS |

## Sistemas preservados

Cabaña de doble altura, billar, chimenea, materiales nativos, muebles y luces; relatos de NPC; selección persistente durante la sesión; habilidades de Guest, Tubers, Pelotocino y Deathspeaker; habilidad de velocidad del robot transferida a Junkbot, y efecto de ralentización reutilizado para el bastón de Yellow Guy; música por capas y LMS; fuentes de imágenes y mallas; integración opcional de modelos; exportación XML y configuración Rojo.

El controlador de rondas se reorganizó para conectar estos sistemas con las reglas nuevas. Los antiguos fragmentos no encajaban en la partida solicitada: su implementación completa se conserva en la copia previa, mientras la partida activa utiliza generadores y cápsulas.

## Estructura actual

- `src/shared/Roster`, `FutureRoster`, `Appearance`, `CatalogCharacter`, `ImportedAppearance`, `CharacterFactory`, `NativeRoundCharacter`, `BasicAnimation`: identidad, recursos, rigs, restauración y animaciones.
- `src/shared/RoundRules`, `RoleAssignment`, `Stamina`: lógica comprobable sin Roblox.
- `src/server/init.server.luau`: coordinación autoritativa, daño, habilidades, selección, muerte, escape, desconexión, reinicio y límites de mensajes.
- `src/server/World.luau`: reutiliza Lobby y construye campamento, ruinas, puntos de aparición y puerta.
- `src/server/Objectives.luau`: generadores, puzles, recogida, tiempos, distancia, sesiones y limpieza.
- `src/client/init.client.luau`: HUD, selección, controles, puzles, cámara y música.
- `tools/validate_and_build.py`: comprobación y entrega reproducible.

## Límites reales

No hay Roblox Studio conectado a esta nube, ni permisos de red configurados para consultar el catálogo de Roblox. No se afirma una ejecución real, carga de texturas originales, física, navegación multijugador o apariencia final verificada. Los tests emplean Lua 5.4 con dobles de APIs; la revisión de sintaxis adapta construcciones Luau y no sustituye su compilador. El archivo `.rbxlx` pasa validación XML y de estructura/fuentes; su apertura real se prueba en Studio.

No se incorporaron audios ausentes ni IDs ficticios de modelos. Los cinco personajes sin rig final instalado son provisionales; Junkbot también tiene un provisional si falla el catálogo. Las mallas FBX/GLB históricas siguen necesitando publicación/importación para funcionar como MeshParts. La práctica individual comprueba objetivos y control, no un combate contra IA. Persistencia entre sesiones, matchmaking, inventario, tienda, balance final y Milestones quedan fuera de esta prueba.
