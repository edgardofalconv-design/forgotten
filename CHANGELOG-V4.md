# FORGOTTEN V4 — cambios y archivos

V4 continúa las fuentes V3 y mantiene las entregas anteriores sin sobrescribirlas. El diseño nuevo de Yellow Guy sigue la descripción escrita del usuario; las tres nuevas imágenes no estuvieron disponibles.

## Personajes y animaciones

- `tools/build_character_visuals_v4.py`, `assets/v4/` y `src/shared/CharacterVisualData.luau`: superficies propias articuladas; ropa y cuerpos más delgados, cabello y rostro nuevos de Yellow Guy, casco Junkbot, detalles espectrales y eslabones Tubers93. Se conservan las fuentes gráficas V3.
- `RigProfileData.luau`, `RigProportions.luau`: dimensiones y pivotes R6 compatibles con los seis motores. Solo se aplican a los cuerpos alternativos generados; las plantillas originales validadas tienen prioridad.
- `FaceData.luau`, `CharacterVisuals.luau`: rostro Yellow Guy, ropa y soportes de SurfaceGui fuera de las superficies; accesorios y cuerpo separados del bastón. El lanzamiento ya no puede arrastrar el nuevo cuerpo o cabello.
- `CharacterMotion.luau`: curvas de preparación/contacto/recuperación, idle y movimiento. Guadaña orientada hacia delante al contacto. `ClientEffects.luau`: partículas locales breves, carga de plasma y efectos mecánicos; origen visual del plasma en la mano animada.
- `CharacterFactory.luau`, `EditableAppearance.luau`: integración V4 conservando originales, rigs R6/R15, colisiones, fallback e importaciones. `Abilities.luau`: payload visual y limpieza de reparación; importes de daño, coste y cooldown conservados.

## Lobby, mapas y objetos

- `MapExpansion.luau`, `Maps.luau`, `MapCatalog.luau`: cuatro sectores nuevos por mapa. El área útil pasa de aproximadamente 240 × 240 a 380 × 380 studs. Se mantienen los cuatro edificios centrales y se suman cuatro nuevos, con puertas, recorridos interiores, coberturas y decoración por tema. Forgotten Heights añade escaleras hacia los nuevos tejados.
- Generadores y estaciones repartidos entre centro y sectores exteriores. Se conserva un total de cuatro de cada tipo. Límites de teletransporte y puerta ajustados a la nueva extensión.
- `Camp.luau`: detalles del refugio y pasarelas; NPC existentes con rig/apariencia/idle V4. Ningún campamento se convierte en mapa de partida.
- `ClientEnvironment.luau`, `init.client.luau`: iluminación, niebla y color por mapa, con transiciones locales; el lobby conserva su perfil cálido. Se mantienen límites previos de sombras y efectos.
- `RoundItems.luau`: botiquín y bebida detallados sin colisiones decorativas. `Objectives.luau`: memoria, piano, reflejos y circuito visibles, cápsula con aros; todas sus piezas se ocultan/restauran juntas al transportar/soltar.

## Conservación y entrega

Permanecen economía, inventario, monedas, skins, 24 Milestones, vida, energía, música configurable, generadores, puzles, objetos, selección, rondas y LMS. Se conserva el namespace de guardado V2. Los audios, clips y texturas externos definitivos continúan pendientes de recursos autorizados; no hay IDs nuevos inventados.

`tools/check_v4.py`, pruebas V2/V3 reutilizadas, simulación de cinco rondas, exportación XML y verificación ZIP. La lista exacta de archivos cambiados frente al respaldo V3 aparece en `dist/INFORME-V4.json` (en el ZIP: `INFORME-V4.json`). Los seis artefactos V1/V2/V3 se comparan con `backups/pre-v4-protected.json`.

`tools/render_v4_characters.py`: siete imágenes, incluidas 18 vistas ortográficas. **Blender, no Roblox Studio**. `tools/validate_v4.py` y `validate_and_build.py`: exportación de `Forgotten-V4.rbxlx` y `Forgotten-V4.zip`. El ZIP contiene juego, fuentes, recursos, vistas e instrucciones.

No se ha ejecutado Roblox Studio en este entorno. Catálogo real, física, cámara, replicación, rendimiento y balance de los mapas ampliados requieren la prueba manual descrita en `docs/V4_PRUEBAS_Y_PENDIENTES.md`.
