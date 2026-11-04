# V4: pruebas y límites

## Comprobado localmente

`dist/INFORME-V4.json` y `dist/VALIDACION-V4.txt` se generan después de ejecutar las pruebas. Usan Lua 5.4 con sintaxis adaptada y dobles explícitos de las APIs, más validación Python/XML/ZIP. No equivalen al compilador Luau, física, replicación ni ejecución de Studio.

- Normal: 240 s, cuatro generadores/cuatro estaciones, dos generadores y tres cápsulas depositadas, descuentos de 10/5 s, salida a 60 s o menos y cruce físico.
- LMS: 90 s, sin requisitos, apertura a cero, escape obligatorio y prioridad musical conservada.
- Cinco recorridos del servidor: práctica, escape normal, LMS, tiempo normal agotado y abandono del asesino.
- Seis rigs alternativos conectados, identidades independientes y rechazo de plantillas incompletas/equivocadas. Proporciones V4, hombros/caderas, rostro y separación entre el bastón y el cuerpo de Yellow Guy.
- Nueve mapas con cuatro distritos nuevos por mapa: prueba 2D de acceso a los 36 puntos de interés, objetivos, objetos y salida con un margen conservador. No simula escalones, saltos ni la física.
- Compras, saldos, inventario, 24 Milestones, recibos y bloqueos de guardado simulados. No cambia el namespace DataStore.
- Generadores: tres etapas, decoración sin obstáculos, señal de arranque, tokens, distancia, cancelaciones y recompensas sin duplicación.
- Movimiento: valores finitos, seis perfiles diferentes, ejes R6/R15 y brazos hacia delante; muerte, victoria/MVP, reparación y habilidades.
- Combate: cooldowns/energía, contacto, cancelación por muerte/cambio de vida y escape con token/frecuencia limitada.
- Catálogo simulado: bundle 589, nombre/creador oficial, rechazo de resultados ajenos, caché y recuperación. Se consultaron firmas públicas de API; no se descargaron aquí los originales.
- XML válido, fuentes embebidas sin diferencias, ZIP íntegro y hashes V1/V2/V3 conservados cuando están presentes.

## Provisional

1. **Arte:** las alternativas propias son reconocibles y reemplazables; no son réplicas 1:1 ni arte final. Junkbot y Deathspeaker intentan cargar sus originales al jugar. Bacon intenta cargar Pal Hair. Si Roblox falla, permanece la alternativa identificada en el modelo/UI.
2. **Animación:** clips procedurales sin IDs externos. Falta revisar manos, pies, contacto, obstáculos y transiciones reales R6/R15. AnimationConfig admite clips publicados y autorizados. Las curvas V4 colocan el filo de la guadaña delante del cuerpo en el contacto; los proyectiles y partículas siguen los tiempos del servidor.
3. **Rendimiento:** la geometría portátil tiene más piezas que un modelo final importado. EditableMesh puede estar deshabilitado por permisos/memoria. Hay límites de luces/FX y animación de NPC lejanos, pero no cifras reales de FPS ni rendimiento móvil verificado.
4. **Recursos:** música/sfx, retratos, PBR y clips finales siguen sin IDs publicados. Los PNG de autoría se conservan; se usan materiales nativos hasta configurar recursos válidos.
5. **Balance:** lanzamiento del bastón y tiempos de sujeción/escape son de prueba. Las cifras V2 restantes siguen experimentales. No hay trampa de Bacon al fallar porque no existía en V2.
6. **Mapas:** el área útil crece de aproximadamente 240 × 240 a 380 × 380 studs. Falta equilibrar tiempos de recorrido con el reloj de cuatro minutos y probar interiores/escaleras con los seis cuerpos.
7. **Milestones:** propiedad, desbloqueos y cosméticos V2 conservados; su arte sigue provisional. No se rediseñan en esta entrega.

## Prueba mínima en Studio

1. Extrae el ZIP, abre `Forgotten-V4.rbxlx` y pulsa Play. La vista en edición es estática; los modelos actuales aparecen al ejecutar.
2. Revisa PERSONAJES y los seis NPC. Yellow Guy debe ser delgado, amarillo, con cabello dorado elevado, chaqueta negra, camiseta azul, pantalones oscuros y bastón; Junkbot es un robot diferente. Comprueba el estado del modelo y advertencias del catálogo en Output/Salida.
3. Usa PROBAR SOLO: camina, corre, salta, gira la cámara y prueba Q/R/F/G. Con Pelotocino revisa mechón/sartén; con Yellow Guy golpe, lanzamiento, puños y retorno. Repite con Junkbot/Deathspeaker.
4. Repara dos generadores: cables, interruptores y tres tirones en verde. Comprueba pose, rotor y señal. Cancela una reparación y verifica regreso a idle.
5. Resuelve tres estaciones, recoge/deposita cápsulas y cruza la salida al cumplir requisitos con 60 s o menos. Confirma regreso al lobby y restauración del avatar.
6. Con Server & Clients y **tres clientes**, prueba Guest/Tubers: daño, estelas, guadaña, agarre, escape, cámara, muerte, resultados y MVP. No debe haber golpes duplicados ni ataques de un eliminado.
7. Con **dos clientes**, comprueba LMS de 1:30, puerta a cero y cruce físico. LMS tiene prioridad si hay audios configurados.
8. Prueba con/sin permiso Mesh & Image APIs. En ambos casos debe existir un cuerpo visible. Mide FPS/memoria, especialmente con varias apariencias portátiles y en móvil.
9. Vota y recorre los nueve mapas. Cada uno conserva el centro y añade cuatro sectores con interiores y coberturas. Comprueba los nuevos objetivos, rutas de vuelta, escaleras y salida.
10. Para guardado real, publica una experiencia de prueba y habilita sus APIs. Compra, cierra y vuelve a entrar. Si indica Progreso de sesión, no esperes persistencia.

No necesitas configurar APIs para abrir y probar las alternativas propias. El motor/catálogo y la persistencia real siguen pendientes de revisión manual.
