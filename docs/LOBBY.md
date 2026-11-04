# Cabaña del Último Refugio

Revisión basada en las dos imágenes aportadas por el autor. Se conserva su distribución reconocible y la mayoría de categorías de objetos; «80%» se interpreta como dirección de semejanza, no como una medición exacta de una réplica. Dimensiones adaptadas al prototipo. No se importaron modelos ni texturas de las imágenes.

| Referencia | Implementación y toque propio |
| --- | --- |
| Sala de doble altura | Troncos, suelo de tablones, tejado inclinado y cerchas |
| Escalera lateral | Veinte escalones, pasamanos y descansillo al entrepiso en L |
| Galería con barandillas | Altillo con asientos, mesa y seis recuerdos del plantel |
| Chimenea de piedra | Hogar, leña, repisa y emblema fracturado en lugar del trofeo animal |
| Sofá, butacas, alfombra y mesa | Tapizado verde/crema, alfombra con bandas y diario interactivo |
| Mesa de billar azul | Seis troneras, bolas con colores de los personajes y taco decorativo |
| Aparador, radio y estanterías | Radio Shadow Reaper, cajones, tiradores y libros de archivo |
| Cuadros y reloj | Seis retratos tipográficos y reloj detenido |
| Ventanas y cortinas | Ventanales frontales elevados con marcos y cortinas claras |
| Plantas y lámparas | Macetas, follaje geométrico, faroles suspendidos y lámpara de pie |
| Tabla y señales decorativas | Tabla de rutas, recuerdo de rescate y cartel «No olvidar» |

Los objetos tienen geometría básica propia: no equivalen al detalle de los modelos de las referencias. Billar, libros, asientos y recuerdos son decorativos. Diario, radio y NPC tienen ProximityPrompt. La radio muestra información; el audio sigue pendiente. Los seis NPC se distribuyen por la sala y el altillo, sin ampliar el plantel.

La cabaña se construye al pulsar Play mediante `src/shared/Lobby.luau`; no aparece en la vista de edición antes de ejecutar. El retorno de las rondas se movió al acceso despejado. El mapa, los personajes y el sistema de rondas se conservan.

Validación disponible: sintaxis del constructor contrastada con Lua 5.4 tras normalizar dos extensiones de sintaxis Luau; XML exportado con cinco scripts preservados. Esto no valida las APIs ni la física de Roblox. Pendiente en Studio: inspección visual, subir y bajar la escalera, recorrer el altillo, hablar con los seis NPC, examinar diario/radio y verificar retorno al refugio. No se dispone de captura real de Studio en esta sesión.

Revisión gráfica posterior: ver `GRAPHICS.md`. El archivo exportado ahora incorpora vista estática en edición, seis scripts y 1348 piezas; los detalles y materiales se ampliaron.
