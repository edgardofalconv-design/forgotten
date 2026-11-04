# FORGOTTEN — V2 de prueba

Abre **Forgotten-V2.rbxlx** en Roblox Studio, pulsa **Play/F5** y elige **PROBAR SOLO**. El ZIP contiene el lugar, guía, informe y proyecto fuente. No necesitas PowerShell, Rojo ni pegar código.

**Estado real:** implementación comprobada localmente con Lua 5.4, APIs simuladas y XML. Falta ejecutarla en Roblox Studio. Las apariencias provisionales, retratos, canciones y animaciones finales no se presentan como terminados.

## Incluido

- Cabaña conservada, campamento ampliado, caminos, fogata y club house con tienda, personajes e inventario. El campamento sigue siendo exclusivamente el lobby.
- Nueve escenarios procedurales temáticos: Disaster Island, Abandoned Pizza Place, Forgotten Heights, Zombie Research Facility, Cursed Manor, Forgotten Robloxia, Junkbot Factory, Corrupted Arcade y Baller's Arena. Comparten una base de circulación, con arquitectura y obstáculos propios de cada tema. Solo se instancia un mapa de partida a la vez.
- Seis personajes independientes y 25 habilidades. Yellow Guy es amarillo con bastón; Junkbot conserva su cargador del paquete original 589. Los modelos provisionales se identifican como tales.
- Generadores de cables, interruptores y cuerda; estaciones de memoria, piano, reflejos y laberinto; cápsulas transportables y depósito.
- Medkit de 7 segundos y Energy Drink de 6 segundos; dos ranuras y una unidad por tipo, separadas de las cápsulas.
- Forgotten Coins, cuatro cosméticos, inventario permanente, base y cuatro Milestones por personaje. Compras y recompensas de servidor; guardado con bloqueo de sesión y recibos contra duplicación.
- HUD, selección, votación de mapas, vistas 3D, marcador, resultados y MVP. Animaciones procedurales, retratos provisionales y configuración de música/animaciones externas sin IDs ficticios.

## Abrir y probar

1. Extrae el ZIP. Abre **Roblox Studio → Archivo → Abrir desde archivo → Forgotten-V2.rbxlx**.
2. Pulsa **Play**, entra en **PERSONAJES** y elige un superviviente. En **MAPAS** puedes votar.
3. Vuelve a **JUGAR → PROBAR SOLO**. No hay asesino ni LMS; esta práctica no concede monedas o maestría de partida.
4. Repara dos generadores completando sus tres pasos. Resuelve tres estaciones, recoge las cápsulas con **E** y deposítalas junto a la salida.
5. Con ambos requisitos y **1:00 o menos**, cruza físicamente la puerta. Volverás al campamento.

WASD: moverse; espacio: saltar; Shift: correr; E: interactuar; Q/R/F/G/T/Y: habilidades; Z/X: objetos; clic: ataque del asesino; M: menú; Tab: marcador. También hay botones de acciones.

Para persecución, usa **Test/Prueba → Server & Clients con 3 clientes**: un asesino y dos supervivientes. El servidor equilibra equipos y conserva la selección para la siguiente ronda. Con 2 clientes comienza LMS: **1:30**, sin objetivos, puerta a **0:00**, escape físico obligatorio.

Normal: 4:00, cuatro generadores y cuatro estaciones. Requisitos: dos generadores y tres cápsulas **depositadas**. Cada generador descuenta 10 s; cada puzle, 5 s. LMS tiene prioridad musical y no termina automáticamente a cero.

## Guardado y recursos pendientes

El HUD indica **Progreso de sesión** cuando Roblox no permite DataStore: se puede probar la tienda, pero esos cambios no persistirán ni sobrescribirán un perfil remoto. Studio usa **FORGOTTEN_Profiles_v2_Studio**; el juego publicado usa **FORGOTTEN_Profiles_v2**. Para verificar guardado real necesitas publicar una experiencia de prueba y habilitar su acceso a API.

Junkbot intenta cargar el original de Roblox; si falla, conserva un robot provisional identificado y permite reintentar. Los demás personajes usan rigs aproximados reemplazables: no son réplicas 1:1. Faltan modelos finales, referencias finales de Milestones, retratos, música/sonidos autorizados y clips finales de animación.

Los PNG PBR de assets/textures se conservan; hasta publicar imágenes y configurar MaterialPack se usan materiales nativos. Los valores nuevos de habilidades, precios, recompensas, maestría y Speed III son **experimentales**, no estadísticas definitivas aprobadas.

## Desarrollo y conservación

Un comando: **python3 tools/validate_and_build.py**. Comprueba y exporta la V2; requiere Python 3 y liblua5.4.so.0. No requiere Blender. La sintaxis adaptada no sustituye al compilador Luau.

default.project.json mantiene Rojo y preserva modelos instalados en ServerStorage al sincronizar. El exportador incorpora los scripts y una vista estática del lobby; los escenarios interactivos se construyen al jugar.

La V1 se conserva en sus artefactos originales y en backups/primera-prueba-v1-completa.zip. La construcción V2 comprueba sus hashes cuando existen y no los reconstruye. Los renders y FBX/GLB históricos se conservan localmente; no son capturas de V2 ni apariencias instaladas.

Consulta **CHANGELOG-V2.md**, **docs/V2_PRUEBAS_Y_PENDIENTES.md**, **dist/VALIDACION-V2.txt** y **dist/INFORME-V2.json**. Los demás documentos históricos describen la primera prueba.
