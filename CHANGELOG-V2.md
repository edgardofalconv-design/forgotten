# FORGOTTEN V2 — cambios sobre la primera prueba

Se continúa el proyecto existente, preservando la V1, sus constructores, rigs, selección, intercambio de avatar, reglas y cargador original de Junkbot.

- Lobby: iluminación y atmósfera ajustadas; cabaña detallada conservada; caminos, fogata, club house y accesos a tienda, personajes e inventario. NPCs con identidad y relatos conservados.
- Mapas: catálogo y votación de nueve escenarios temáticos, cuatro edificios con puertas y rutas, decoración por tema, azoteas/escaleras, puntos de objetivos y objetos; separados del lobby a 600 studs.
- Personajes: seis identidades; proporciones de cabeza ajustadas, guadaña articulada en el brazo, Animator; Junkbot original con desgaste discreto cuando carga el bundle 589. Los rigs definitivos instalados tienen prioridad.
- Combate: 25 acciones configurables con controles de vida, rol, energía, distancia, visibilidad y cooldown en servidor; curas, escudos, ralentización, revelado, raycast, desplazamientos, impactos y fuego.
- Objetivos: generadores de tres etapas; memoria, piano, reflejos y laberinto. Sesiones con token, alcance y expiración. Recoger y depositar son acciones separadas; las cápsulas sin depositar vuelven a la estación al morir/abandonar.
- Partidas: reglas 4:00/1:30 y escape físico conservadas. Corregidos los resultados y victoria del asesino cuando se agota el tiempo. Práctica sin recompensas y asignación multijugador.
- Objetos: Medkit de 7 s, cancelable por movimiento/daño; bebida de 6 s con energía infinita y velocidad configurable; dos ranuras y máximo uno por tipo.
- Economía: tienda cosmética, monedas, inventario, selección por personaje y 24 Milestones de maestría. Guardado con bloqueo de sesión, deduplicación y espacio separado para Studio; fallback temporal sin sobrescribir datos remotos.
- Interfaz: selección, vistas 3D, catálogo, inventario, mapas, HUD, avisos de desbloqueo, marcador, resultados y MVP; retratos pendientes identificados.
- Animación/música: animaciones procedurales de rigs y resultados, campos para clips finales. Lobby, salida, dos LMS especiales y cuatro capas de persecución por asesino; transiciones y prioridad LMS; sin IDs inventados.
- Optimización: un escenario activo, decoraciones sin colisión/consulta, efectos locales limitados y ajuste para reducir efectos.
- Calidad: pruebas de componentes, cinco flujos del servidor principal, accesibilidad 2D de los mapas, exportación XML y protección SHA-256 de V1. Se movió un objeto que quedaba bajo la escalera de Cursed Manor.

No se ha ejecutado Roblox Studio. Los mapas son una primera elaboración procedural sobre estructura común; modelos y skins siguen siendo provisionales. El informe distingue comprobaciones locales y pruebas reales pendientes.
