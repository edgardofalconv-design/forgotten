# Abrir y probar FORGOTTEN

No necesitas PowerShell, Rojo ni pegar scripts para usar esta entrega.

1. Descarga y descomprime `Forgotten-Primera-Prueba.zip`, o descarga directamente `Forgotten.rbxlx`.
2. Abre Roblox Studio → Archivo → Abrir desde archivo → `Forgotten.rbxlx`.
3. Pulsa Play/F5. Espera a que cargue tu avatar, elige un superviviente y pulsa **PROBAR SOLO**. El botón solo existe dentro de Studio cuando hay un jugador.

Verás tu avatar habitual en la cabaña. Al iniciar la práctica se equipa el personaje elegido y apareces en el escenario de ruinas, separado del campamento. Los modelos con `[provisional]` no son sus apariencias definitivas. Junkbot intenta obtener su paquete original automáticamente; la partida sigue disponible aunque falle esa descarga.

## Recorrer una práctica individual

- WASD: caminar. Espacio: saltar. Shift: correr; la energía baja al correr y se recupera al descansar. Q: habilidad. Hay botones equivalentes en pantalla.
- Busca una caja marcada **G1–G4** y mantén E durante tres segundos para repararla. Cada generador resta diez segundos.
- Abre una de las cuatro estaciones con E. Pulsa los cuatro colores en el orden mostrado. Si fallas, vuelve a abrir el puzle. Resolverlo resta cinco segundos.
- Recoge con E la cápsula que se libera encima de la estación. Resolver sin recoger no aumenta el contador de cápsulas.
- Completa al menos dos generadores y recoge tres cápsulas. Cuando el reloj marque 1:00 o menos, se abre la salida situada al sur del escenario.
- Atraviesa la puerta y el umbral verde. Solo entonces habrás escapado y volverás a la cabaña. Si se agota el reloj normal, termina la ronda sin dar por escapados a quienes sigan dentro.

La práctica dura inicialmente cuatro minutos, no contiene asesino y mantiene los requisitos normales. No activa LMS por estar solo. Puedes repetirla desde el lobby.

## Probar multijugador

En la pestaña **Test / Prueba**, busca **Server & Clients** o **Servidor y clientes** y elige **3 clientes**. En uno selecciona Guest 666 o Tubers93; en los otros, supervivientes. Tras la cuenta del lobby comienza la ronda normal de 4:00.

El servidor asegura un solo asesino. Si las elecciones no forman un equipo válido, asigna uno y lo avisa; conserva la preferencia para próximas rondas. El asesino usa clic para atacar a corta distancia y Q para su habilidad.

Con dos clientes hay un solo superviviente: entra en LMS a 1:30. Generadores y puzles quedan desactivados. La puerta abre al llegar a 0:00 y el superviviente debe atravesarla; estar vivo al llegar a cero no lo hace ganar automáticamente. También se activa LMS si un participante muere, abandona o escapa y queda solo un superviviente activo. Una vez iniciado no vuelve a reiniciarse.

## Comprobaciones manuales que faltan

Estos puntos no se han marcado como aprobados porque no se dispone de Studio en la nube:

- Abrir el archivo y comprobar que no hay errores en Output / Salida.
- Probar los seis personajes en rondas distintas: nombre, cuerpo, cámara, caminar, salto, sprint, colisiones y habilidad.
- Confirmar que Yellow Guy lleva bastón y Junkbot es un robot; verificar visualmente la descarga del paquete 589 y sus texturas.
- Probar reparación interrumpida, puzle incorrecto, abandonar la estación, dos jugadores en la misma estación y recogida única de cápsulas.
- Comprobar los requisitos normales, deducciones, paso físico por la puerta, y cero sin escape.
- Probar muerte, Reset Character, desconexión del asesino, desconexión de un superviviente, entrada tardía y regreso al avatar propio.
- Jugar dos rondas seguidas para detectar cámara desenganchada, energía sin reiniciar o elección perdida.
- Revisar el modo de tres clientes en un equipo real y ajustar rendimiento. El lobby mantiene más de 1.600 piezas de la versión existente.

La etiqueta de música pendiente es esperada: todavía no hay audios con permiso para esta experiencia. La animación incluida es básica y procedural; no equivale a un paquete de animaciones final.
