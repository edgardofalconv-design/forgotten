# Personajes del lanzamiento

La aclaración más reciente del autor sustituye la asignación anterior: **Yellow Guy y Junkbot son distintos**. No hay Baller en el lanzamiento; se preservan su definición en `FutureRoster.luau` y sus recursos para una actualización posterior.

| ID | Nombre | Representación jugable actual | Fuente final pendiente |
| --- | --- | --- | --- |
| `pelotocino` | Pelotocino | R6 Bacon provisional con mochila y señales discretas de combate | Rig final fiel a la referencia |
| `yellowguy` | Yellow Guy | R6 amarillo clásico provisional, camiseta azul, pantalón verde y bastón | Rig/referencia tridimensional propia; nunca el robot |
| `junkbot` | Junkbot | Paquete Roblox 589 original en R15 si está disponible; tres arañazos discretos añadidos. Si falla la carga: robot R6 provisional identificado | Verificar descarga, textura, desgaste y movimiento en Studio |
| `deathspeaker` | Korblox Deathspeaker | R6 provisional con capucha, cuernos, armadura, gema y faldón | Modelo clásico original o rig final validado |
| `guest666` | Guest 666 | R6 provisional oscuro con gorra y ojos rojos | Rig final validado |
| `tubers93` | Tubers93 | R6 provisional oscuro estilo Bacon con guadaña | Rig final validado |

Los asesinos no llevan marcas de combate. Los supervivientes provisionales conservan sus señales cosméticas. No se afirma fidelidad 1:1 de los provisionales. Las partes ocultas de las referencias originales seguían interpretadas en las mallas históricas.

## Orden de carga

1. Un rig completo instalado en `ServerStorage/CharacterModels/<id>`, con atributo `CharacterIdentity=<id>`, tiene prioridad. Se valida Model, Humanoid, HumanoidRootPart, cabeza, torso, rig R6/R15 y conectividad de todas las piezas mediante Motor6D.
2. Para `junkbot`, se consulta la plantilla original de catálogo o el paquete 589. Ese paquete nunca se admite para otro ID.
3. Si no hay rig final, se construye un provisional R6. Las mallas opcionales en `ReferenceCharacters` solo se aplican cuando están completas y son compatibles. Su estado se indica como pendiente de validar.

Para instalar después un rig completo se incluye `tools/InstallCharacterRig.luau`. Es opcional y no hace falta ejecutarlo para esta primera prueba. Se conserva un modelo ya instalado y se evita sobrescribirlo automáticamente. La validación estructural no demuestra fidelidad visual.

## Selección, controles y ciclo

El avatar personal permanece en el lobby. El servidor guarda el modelo original, equipa el personaje asignado al comenzar y restaura el original al escapar o al terminar. Una reaparición normal tras morir se conserva. La elección se mantiene entre rondas de la sesión.

Se incluyen animaciones básicas locales de reposo, caminar y salto, sin IDs externos, para rigs R6 y R15. La cámara vuelve a apuntar al Humanoid actual. Los accesorios cosméticos no colisionan y el HumanoidRootPart no se dibuja. Estas comprobaciones estructurales y de lógica pasan con dobles; el movimiento, la red, la física y la apariencia efectiva se verifican en Studio.

## Recursos históricos

`dist/reference-characters/yellowguy/` y su imagen `yellowguy-reference.png` corresponden al **robot aproximado antiguo**. No son el Yellow Guy clásico y no se cargan automáticamente. `assets/character_sources.json` registra esta relación. El instalador de mallas exige una identificación explícita para un nuevo Yellow Guy; permite reutilizar aquel robot solo bajo `junkbot`.

Los renders anteriores de Baller, del robot llamado Yellow Guy y las alineaciones de seis modelos son archivos históricos, no capturas de la entrega actual. Se conservan sin borrar trabajo previo.
