# V2 — pruebas y pendientes

## Comprobación automática

Se ejecutan módulos reales con **Lua 5.4 y dobles explícitos de APIs Roblox**. La sintaxis usada se adapta para el análisis local. No equivale a Studio, su compilador Luau, física, red ni servicios reales.

- Reglas 240/90 s, descuentos 10/5, requisitos y puerta a ≤60/0, escape físico y práctica.
- Cápsulas: recoger no cuenta como depositar; entrega única, propietario, recuperación y ranuras independientes.
- Generadores de tres etapas; tokens, alcance, expiración y recompensa única. Secuencias correctas/erróneas, reflejos, cuerda, interruptores y ambos laberintos resolubles.
- Seis rigs e identidades, articulaciones, bastón/mochila, colisiones y rechazo de Junkbot como Yellow Guy. Carga/fallback conservados, intercambio y restauración R6/R15, segunda ronda.
- Base y cuatro tiers por personaje sin alterar vida/velocidad; cosméticos sin colisión; garras de Guest solo desde M3.
- Compras, saldos, propiedad, equipamiento, maestría y recibos repetidos. Persistencia simulada: bloqueo, adquisición, guardado, liberación, pérdida de bloqueo y fallo de API sin sobrescritura.
- Dos objetos y uno por tipo; Medkit antes/después de 7 s y cancelación por movimiento/daño; bebida de 6 s.
- Las 25 habilidades pasan por el controlador real con impactos/raycast simulados. Energía, cooldown, aliados, enemigos, escudos e invulnerabilidad.
- Nueve constructores, objetivos, objetos y puertas. Búsqueda de rutas 2D con margen de cuerpo desde spawn a cada objetivo, objeto y salida; se corrigió un objeto bajo una escalera. No valida salto, pendiente, altura de cada rig o navegación 3D del motor.
- Script principal real con servicios simulados: práctica, escape normal, LMS, tiempo agotado y abandono del asesino; resultados, recompensas, limpieza y regreso al lobby.
- Recursos conservados, XML, jerarquía Rojo, fuentes incrustadas exactas y ZIP. V1 comparada con los hashes originales.

El detalle está en VALIDACION-V2.txt; INFORME-V2.json incluye archivos modificados y hashes.

## Recorrido mínimo en Studio

1. Abrir el lugar, Play y **View/Vista → Output/Salida**. Caminar por cabaña/club house, hablar con NPCs, abrir tienda y seleccionar personaje.
2. Comprar un cosmético con las 100 monedas iniciales experimentales, intentar repetir la compra, equiparlo y comprobar la vista y la aparición en ronda.
3. Votar mapa y PROBAR SOLO; recorrer los nueve mapas en rondas sucesivas. Revisar cámaras, puertas, escaleras, colisiones y altura con cada rig.
4. Completar cables, interruptores y tres tirones verdes en dos generadores. Resolver tres puzles, recoger cápsulas y llevarlas al depósito junto a la puerta.
5. Verificar que antes de 1:00 la salida normal no abre. Con 2 generadores, 3 cápsulas depositadas y ≤1:00, cruzar y volver al campamento. Probar segunda ronda.
6. Medkit herido: 7 segundos quieto; cancelarlo moviéndose o recibiendo daño. Bebida: 6 segundos de efecto. No aceptar dos objetos iguales.
7. **Server & Clients con 3 clientes**: normal de 4:00, combate con paredes/distancia y cooldown. **2 clientes**: LMS 1:30, sin objetivos, puerta a 0:00 y escape físico.
8. Reiniciar avatar, morir llevando cápsulas, desconectar asesino/superviviente, llegar tarde, agotar reloj y comprobar resultados y segunda ronda.
9. Publicar una experiencia de prueba y habilitar sus API para comprobar guardado real: comprar, equipar, salir y volver. Studio usa un DataStore distinto al publicado. Con API deshabilitada, el progreso es temporal.
10. Probar teclado/ratón y emulador táctil en distintas resoluciones; revisar solapamientos del HUD y medir FPS/memoria/red en dispositivos reales.

## Pendiente o provisional

| Área | Estado |
| --- | --- |
| Studio y multijugador | No disponible en esta nube; falta el recorrido manual. No se entregan capturas como si fueran del motor. |
| Junkbot original | Cargador bundle 589 y fallback preparados; falta comprobar descarga real y rig R15 en Studio. No necesitas tenerlo equipado en tu avatar. |
| Otros personajes | Rigs aproximados reemplazables, no réplicas 1:1. Se necesitan modelos finales R6/R15 o paquetes autorizados que correspondan a las referencias. |
| Milestones | 24 desbloqueos y variantes geométricas provisionales. Faltan referencias/modelos finales por tier. Guest sin capa y con rasgos monstruosos solo desde M3. |
| Retratos | Placeholders en selección, tienda, inventario, marcador y resultados. Completar Portraits.luau con las imágenes que enviarás. |
| Música/sonidos | Configuración y disparadores preparados; Music.luau tiene IDs vacíos. Faltan pistas, cuatro capas sincronizadas y efectos autorizados para la experiencia. El piano tiene teclas visuales, sin melodía audible hasta recibir sonidos. |
| Animaciones | Movimiento/acciones/poses procedurales. Faltan clips finales autorizados y compatibles con el rig, configurables en AnimationConfig.luau. |
| Texturas | Materiales nativos y PNG PBR fuente conservados. Publicar imágenes y completar MaterialPack.luau para activar PBR propio. |
| Mapas | Nueve variantes temáticas explorables sobre estructura común; falta pasada artística, mayor diversidad de distribución y pruebas de jugabilidad/rendimiento reales. |
| DataStore | Lógica comprobada con dobles, no servicio real. Falta experiencia publicada, API y reconexión/concurrencia reales. |
| Balance | Todas las estadísticas nuevas son experimentales; ajustar tras pruebas multijugador. |

## Configuración y límites

- AbilityConfig: habilidades, costes y recargas. ItemConfig: dos ranuras, Medkit 7 s, bebida 6 s. Speed III se interpreta provisionalmente como ×1,35; no es un valor definitivo aprobado.
- EconomyConfig: inicial 100 Coins, participación válida de 45 s, recompensas de participación/generador/puzle/escape/victoria/MVP = 15/12/8/40/50/10. Maestría = 100/300/600/1000. Valores configurables y experimentales.
- Práctica individual sin monedas/maestría de partida; permite compras de prueba. Seis personajes y skins base incluidos; sin Robux ni venta de estadísticas.
- Victoria del asesino: nadie escapó y la ronda terminó por eliminación de todos o tiempo normal agotado. No se premia abandonar.
- DataStore con bloqueo de 180 s, renovación cada 45 s, liberación al salir y hasta 256 recibos recientes. Solo el servidor crea recompensas. Puede perderse progreso reciente si el servidor se cierra antes de guardar.
- Si API falla: sesión temporal que nunca se guarda sobre el remoto. Otra sesión activa: compras/equipamiento bloqueados. Namespaces separados: FORGOTTEN_Profiles_v2_Studio y FORGOTTEN_Profiles_v2.
- LMS espera escape físico o eliminación a 0:00, sin añadir límite extra.
- Baller y personajes futuros siguen fuera del plantel inicial; Baller's Arena es un mapa.
