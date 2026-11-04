# FORGOTTEN — V3 de prueba

Extrae **Forgotten-V3.zip**, abre **Forgotten-V3.rbxlx** en Roblox Studio y pulsa **Play/F5**. En **PERSONAJES** selecciona un superviviente; vuelve a **JUGAR → PROBAR SOLO**. No necesitas comandos, Rojo ni pegar código.

V3 continúa V2: conserva sus nueve mapas, reglas, vida, energía, tienda, inventario, monedas, skins, Milestones, música configurable, puzles y LMS. V1 y V2 mantienen sus entregas originales. El campamento es únicamente el lobby.

## Cambios visibles

- Seis identidades: Pelotocino con cabello Bacon y mochila; Yellow Guy amarillo, azul y verde con bastón; Junkbot; Korblox Deathspeaker; Guest 666 oscuro con ojos rojos y sin capa; Tubers93 con guadaña curva y cadena.
- Cabezas nativas de Roblox, ropa, accesorios, formas curvas y superficies propias articuladas. Los modelos instalados y validados tienen prioridad. Junkbot conserva el cargador original del paquete **589**. Se intenta localizar **Pal Hair** y **Korblox Deathspeaker** del creador Roblox, sin inventar identificadores.
- Posturas propias de cada personaje, saltos, caída, aterrizaje, daño, muerte y reparación. Lanzamiento visible del mechón y del bastón, recuperación, estelas de armas, habilidades, victoria y MVP.
- Generadores con motor, aletas, depósito, cables curvos, interruptores y arranque animado. Sus tres minijuegos mantienen las reglas de V2.
- Luz más legible, vegetación por capas, helechos y piedras; límites de sombras, efectos locales y animación de NPC lejanos.

**Estado real:** pruebas locales con Lua 5.4 y dobles de APIs, validación XML y renders de Blender. **No se ha ejecutado Roblox Studio aquí.** Los modelos propios son provisionales, no réplicas 1:1. Las animaciones son procedurales; no son clips finales publicados. El catálogo y la consolidación opcional con EditableMesh requieren comprobación real.

## Primera partida

1. Abre el archivo y pulsa **Play**. El lobby y los NPC actuales se construyen al jugar; la vista de edición es una maqueta estática del campamento.
2. Elige un superviviente en **PERSONAJES**, vota un mapa si quieres y pulsa **JUGAR → PROBAR SOLO**.
3. Repara dos generadores: cables, interruptores y tres tirones en verde. Resuelve tres puzles, recoge sus cápsulas con **E** y llévalas al depósito junto a la salida.
4. Con ambos requisitos y **1:00 o menos**, atraviesa físicamente la salida para regresar al lobby.

WASD: moverse; espacio: saltar; Shift: correr; E: interactuar o liberarse; Q/R/F/G/T/Y: habilidades; Z/X: objetos; clic: ataque del asesino; M: menú; Tab: marcador. También hay botones. Yellow Guy lanza el bastón con **G** y lo recupera automáticamente.

Para persecuciones: **Test/Prueba → Server & Clients → 3 clientes**. Dos clientes activan LMS: **1:30**, sin requisitos, puerta a **0:00** y escape físico. La práctica individual no concede monedas ni maestría de partida.

## Vistas y comprobaciones

[Galería: frontal, lateral y trasera de los seis personajes](docs/V3_VISTAS.md). Son **renders de Blender**, con cabeza nativa aproximada y sombreado de Blender. Junkbot y Deathspeaker muestran las alternativas propias, no recursos descargados del catálogo. No son capturas del juego.

[Cambios y archivos](CHANGELOG-V3.md) · [Pruebas y pendientes de Studio](docs/V3_PRUEBAS_Y_PENDIENTES.md).

Si el HUD indica **Progreso de sesión**, la tienda se puede probar, pero los cambios no se guardan al cerrar. Se conserva el espacio de datos V2: `FORGOTTEN_Profiles_v2_Studio` en Studio y `FORGOTTEN_Profiles_v2` en producción.

Para desarrollo: `python3 tools/validate_and_build.py` comprueba y exporta V3 con Python 3 y `liblua5.4.so.0`. Blender solo se necesita para regenerar los renders. `default.project.json` conserva la configuración Rojo y las plantillas instaladas. Los constructores bloquean la sobrescritura de las entregas V1/V2.
