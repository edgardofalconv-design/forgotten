# FORGOTTEN V3 — personajes, animación y presentación

V3 continúa la entrega V2 `ed4ef703deb58cc7cb2b75c111a8158ed5c18b66`. Se guardó una copia completa en `backups/forgotten-v2-completa.zip`; los cuatro artefactos V1/V2 se verifican por SHA-256 y no se reconstruyen.

## Modelos y NPC

`CharacterFactory`, `AvatarCatalog`, `CharacterVisuals`, `CharacterVisualData`, `VisualGeometry` y `EditableAppearance`: rigs nativos cuando están disponibles, cabezas clásicas, geometría propia curva, accesorios soldados sin colisiones y consolidación opcional en MeshParts. La alternativa portátil no necesita permisos de EditableMesh.

- Pelotocino: mechones, chaqueta/camiseta, zapatillas, mochila con correas, bolsillo y cierre; sartén durante su acción.
- Yellow Guy: Noob amarillo/azul/verde, sonrisa y bastón curvo. Nunca utiliza la antigua malla robot llamada yellowguy.
- Junkbot: se conserva `CatalogCharacter` y el paquete 589; desgaste discreto sobre el original. Alternativa propia con pistones, anillos, placas, visores y cresta.
- Deathspeaker: búsqueda del paquete oficial por nombre y creador. Alternativa con capucha, cuernos, armadura, dedos espectrales, gema y túnica continua con bordado.
- Guest 666: cuerpo oscuro, gorra, camiseta y ojos rojos; sin capa ni anatomía monstruosa adicional en la base. Las Milestones existentes siguen independientes.
- Tubers93: cabello, atuendo de referencia y guadaña de hoja continua, empuñadura y cadena.

Los seis NPC y las vistas de selección usan la misma fábrica que las partidas. La llegada de recursos del catálogo actualiza NPC/plantillas, sin sustituir un avatar en medio de la ronda.

## Movimiento y combate

- `CharacterMotion`, `BasicAnimation`, `ClientPreview`, `AnimationConfig`: seis perfiles, trece estados, habilidades, victoria de ambos asesinos, MVP y resultados. Conversión de ejes R6/R15 y articulación Root/RootJoint.
- `AbilityTiming` y `Abilities`: los golpes con preparación validan alcance y visibilidad en el contacto. Una acción pendiente no golpea tras morir el atacante ni desde otra vida. Se conservan los costes, daños y cooldowns de las habilidades V2.
- Bacon Throw: mano al cabello, preparación, lanzamiento de un mechón propio, trayectoria e impacto; curación/ralentización siguen en el servidor. No se inventó una trampa al fallar: V2 no contenía esa regla.
- Yellow Guy: lanzamiento/retorno, recuperación y puñetazos mientras el bastón está fuera. Esta cuarta habilidad eleva el total de 25 a **26**; alcance 28, coste 10, cooldown 18 s y ralentización de 3 s son experimentales.
- Behind You incorpora sujeción breve y empuje sin daño adicional. Pounce añade sujeción de 1,6 s y escape con tres pulsaciones de E, validado por token y frecuencia. Requiere balance en Studio.
- `ClientEffects`: estelas, proyectiles con geometría de arma/mechón, impactos, desaparición y transformación visual. Los efectos locales no deciden el daño.
- `RoundItems` comunica el estado de uso; conserva medkit de 7 s y bebida con efecto de 6 s.

## Generadores y ambiente

- `GeneratorVisuals`, `Objectives`, `ClientChallenge`: modelo mecánico, cables Beam, cuatro interruptores, progreso, rotor, tirador y humo tenue. Poses de reparación y etapas de UI en español. Sin modificar requisitos ni recompensas.
- `World`: exposición/materiales, árboles por capas, helechos y piedras. Decoración sin colisiones; hasta cinco luces del lobby con sombras, detalles pequeños sin sombras y NPC lejanos sin actualización de poses. Falta medir FPS reales.

## Construcción y verificación

`tools/build_character_visuals_v3.py` genera la geometría; `render_v3_characters.py` produce una vista conjunta y seis hojas ortográficas. Blender aproxima la cabeza nativa y el sombreado.

`check_v3.py` añade regresiones de movimiento, ejes, catálogo y geometría; se amplían combate y generadores en `check_v2.py`. `validate_v3.py`, `validate_and_build.py`, `build_place.py` y `export_preview.py` exportan V3 con fuentes embebidas, ZIP y manifiestos. El constructor V2 rechaza fuentes V3.

`assets/character_sources.json`, README y documentación describen procedencia y límites. El informe generado enumera todos los archivos diferentes respecto al respaldo V2.

Nueve mapas, rondas, LMS, guardado, economía, inventario, cápsulas, skins y Milestones se conservan. No se copiaron recursos de Forsaken. Audios, retratos, PBR publicados y clips externos finales siguen pendientes, como en V2.
