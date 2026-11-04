# FORGOTTEN — V4 de prueba

Extrae **Forgotten-V4.zip**, abre **Forgotten-V4.rbxlx** en Roblox Studio y pulsa **Play/F5**. En **PERSONAJES** elige un superviviente; vuelve a **JUGAR → PROBAR SOLO**. No necesitas comandos, Rojo ni pegar código.

V4 continúa el proyecto existente. Conserva habilidades, vida, energía, tienda, inventario, monedas, skins, Milestones, música configurable, puzles y LMS. Las entregas V1, V2 y V3 se mantienen intactas. El campamento sigue siendo únicamente el lobby.

## Cambios visibles

- **Pelotocino:** silueta de hombros y brazos un 30 % más estrecha que la alternativa V3; torso, brazos y piernas con contornos biselados y ajustados, ropa negra y azul, cabello Bacon y mochila más delgada.
- **Yellow Guy:** rediseño según la descripción escrita del usuario: piel amarilla, cabello dorado elevado y lateral, rostro serio/confiado, chaqueta negra abierta, camiseta azul brillante, pantalones oscuros y bastón. Es independiente de Junkbot.
- **Junkbot:** alternativa con casco curvo, articulaciones, metal desgastado y marcas. Conserva el cargador del original de Roblox, paquete **589**.
- **Deathspeaker:** alternativa con detalles de armadura y rostro espectral; conserva la búsqueda del Korblox original. **Guest 666:** silueta ajustada, gorra, ropa clásica, ojos rojos y sin capa. **Tubers93:** cuerpo más delgado, guadaña curva y cadena de eslabones abiertos.
- Posturas de preparación, contacto y recuperación para cabello, bastón, garras, Plasma Ray y guadaña; gestos idle, balanceo corporal, brazos al correr, propulsión y chispas de reparación. Se conservan los tiempos, costes y cooldowns del servidor.
- Los NPC interactivos usan las mismas mejoras de rig/apariencia e idle. El lobby incorpora tablones, suministros, alfombras, pasarelas y detalles de fogata.
- **Nueve mapas ampliados:** cuatro sectores nuevos por mapa, 36 en total, con edificios transitables, interiores temáticos, coberturas y rutas conectadas. El centro anterior permanece; objetivos distribuidos entre centro y periferia.
- Iluminación local por escenario, puzles con paneles visibles, cápsulas con aros, botiquines y bebidas con detalles. Los generadores V3 conservan su motor, cables, interruptores, arranque y minijuegos.

**Estado real:** pruebas locales con Lua 5.4 y dobles de APIs, validación XML/ZIP y renders de Blender. **No se ha ejecutado Roblox Studio aquí.** Las alternativas propias son provisionales; no son réplicas 1:1 ni arte final. Las animaciones son procedurales. El catálogo y EditableMesh requieren comprobación en Roblox. No se han inventado AssetIds.

## Primera partida

1. Abre el archivo y pulsa **Play**. Los modelos actuales y los NPC se construyen al jugar; la vista de edición es una maqueta estática del campamento.
2. Elige un superviviente en **PERSONAJES**, vota un mapa y pulsa **JUGAR → PROBAR SOLO**.
3. Repara dos generadores: cables, interruptores y tres tirones en verde. Resuelve tres puzles, recoge sus cápsulas con **E** y llévalas al depósito junto a la salida.
4. Con ambos requisitos y **1:00 o menos**, atraviesa físicamente la salida para regresar al lobby.

WASD: moverse; espacio: saltar; Shift: correr; E: interactuar o liberarse; Q/R/F/G/T/Y: habilidades; Z/X: objetos; clic: ataque del asesino; M: menú; Tab: marcador. También hay botones. Yellow Guy lanza el bastón con **G** y lo recupera automáticamente.

Para persecuciones: **Test/Prueba → Server & Clients → 3 clientes**. Dos clientes activan LMS: **1:30**, sin requisitos, puerta a **0:00** y escape físico. La práctica individual no concede monedas ni maestría de partida.

## Vistas y comprobaciones

[Galería: frontal, lateral y trasera de los seis personajes](docs/V4_VISTAS.md). Son **renders de Blender**, obtenidos de la geometría del proyecto, con cabeza nativa aproximada y sombreado de Blender. Junkbot y Deathspeaker muestran alternativas propias, no recursos descargados del catálogo. No son capturas de Studio.

[Cambios y archivos](CHANGELOG-V4.md) · [Pruebas y pendientes de Studio](docs/V4_PRUEBAS_Y_PENDIENTES.md).

Si el HUD indica **Progreso de sesión**, la tienda se puede probar, pero los cambios no se guardan al cerrar. Se conserva el espacio de datos V2: `FORGOTTEN_Profiles_v2_Studio` en Studio y `FORGOTTEN_Profiles_v2` en producción.

Para desarrollo: `python3 tools/validate_and_build.py` comprueba y exporta V4 con Python 3 y `liblua5.4.so.0`. Para regenerar vistas: `blender -b -t 4 --python tools/render_v4_characters.py`. El ZIP incluye el proyecto editable y sus siete imágenes. `default.project.json` conserva la configuración Rojo y las plantillas instaladas. Los documentos V1/V2/V3 son históricos y sus entregas conservan sus propias vistas.
