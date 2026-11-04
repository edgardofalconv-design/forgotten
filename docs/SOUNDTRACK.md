# Dirección musical recibida

Fuente: `referencia-musical-original.txt`, transcripción aportada por el autor. Las afirmaciones históricas de aquella conversación sobre haber escuchado un WAV o buscado una canción no son verificaciones realizadas aquí. El WAV mencionado no venía adjunto.

| Tema | Uso | Duración objetivo | Dirección |
| --- | --- | --- | --- |
| Shadow Reaper | Persecución de Tubers 93 | 2:48, 165 BPM | Rock, orquesta, terror retro Roblox; guadaña, fuego, caos |
| Broken Friendship | Guest 666 contra Death Speaker en LMS | 1:30, 155–165 BPM | Amistad rota tras accidente de ácido; reconciliación frente a venganza |
| Last Hope 2.1 | LMS de las demás parejas | 1:30, ~165 BPM | Mantener identidad existente; 65% persecución, 35% terror |

No hay audio generado, descargado ni escuchado en esta entrega. Se conservan los seis personajes; Bacon aparece como referencia narrativa de Tubers en la fuente, sin añadirlo al plantel ni asumir que su nombre equivale a Pelotocino.

## Integrar los audios en Studio

1. Obtener los audios originales/autorizados y subirlos mediante las herramientas de Roblox. Conceder a la experiencia permiso para usarlos.
2. Editar `src/shared/Music.luau`: sustituir las cadenas vacías por `rbxassetid://ID` en `lastHope.soundId`, `brokenFriendship.soundId` y las cuatro capas de `shadowReaper.layers`.
3. Exportar de nuevo con `python3 tools/build_place.py` o Rojo. Los IDs deben quedar dentro del archivo que abres en Studio.
4. Probar sonido y permisos en Studio y en una experiencia de prueba. El aviso «audio pendiente» indica ID vacío o formato incorrecto; un ID con formato correcto todavía puede fallar por permisos (ver Output).

Las marcas 0:12, 0:24 y 0:36 del documento describen la composición de un tema completo. La implementación interactiva utiliza **cuatro clips separados**, seleccionados por distancia: hasta 100, 65, 35 y 18 studs respectivamente. Fuera de 100 no se oye persecución. Preparar bucles con cortes musicales; no cargar el mismo tema completo en las cuatro casillas esperando que se recorte automáticamente. La capa cuatro debe tener melodía protagonista desde su inicio. Esta versión reinicia el clip al cambiar de nivel y hace un fundido corto; no sincroniza stems por compases.

El LMS tiene prioridad sobre las capas y sobre la pista normal de salida. `exit.soundId` queda preparado y vacío hasta recibir el audio autorizado. Se activa una sola vez al quedar un superviviente vivo frente al asesino, incluso en una partida iniciada con dos jugadores. El reloj se establece exactamente en 90 segundos, incluso si antes quedaba menos. En LMS se eliminan los requisitos de objetivos y la puerta abre a cero; el superviviente debe atravesarla físicamente. El audio LMS no se repite y se detiene al acabar la ronda. Los eliminados y espectadores quedan en silencio. Guest 666 todavía no tiene un tema normal de persecución: no se inventó uno.

## Prompt consolidado — Last Hope 2.1

Usar junto al audio original si la herramienta permite edición o referencia. Sin ese archivo, un prompt por sí solo no conserva su melodía ni garantiza una duración exacta.

> Refine the supplied original LAST HOPE soundtrack for FORGOTTEN. Preserve its existing melodic identity, hooks, chord progression, rhythmic character and fast arcade horror-rock chase style. Target 90 seconds at approximately 165 BPM. Increase tension moderately: 65% energetic pursuit and 35% spooky atmosphere. Improve the opening impact, clarify the existing hook with restrained melodic variations, strengthen drums and bass, balance piano, electric guitar and urgent violins, and intensify the final 15 seconds. Add eerie high piano, low minor chords, unsettling bells and brief dissonance without burying the melody. Structure: 0:00–0:06 striking spooky opening; 0:06–0:30 recognizable hook; 0:30–1:00 driving chase; 1:00–1:15 rising urgency; 1:15–1:30 frantic climax. Instrumental only. No vocals, chanting, screams, long ambience, slow sections or excessive techno. Keep the musical identity of the supplied track. Do not copy third-party melodies.

Los prompts completos de Shadow Reaper y Broken Friendship se conservan en la referencia original. No se dispone del audio de Last Hope ni de la referencia WAV para evaluar su melodía o remasterizarla.

## Pruebas pendientes en Roblox Studio

- Dos clientes: Guest 666 + Death Speaker → Broken Friendship y reloj fijado en 90 s.
- Guest 666 + Yellow Guy → Last Hope; Tubers 93 + Death Speaker → Last Hope.
- Tres clientes: Tubers 93 + dos supervivientes → capas según distancia; eliminar uno → LMS sin superposición persistente.
- Eliminar o desconectar al último superviviente / al asesino → terminar ronda y detener música.
- En LMS los objetivos se desactivan; llegar a cero abre la salida y solo cruzarla permite escapar.
- Morir o entrar a mitad de ronda → silencio en refugio.
- IDs vacíos → juego operativo y aviso de audio pendiente, sin solicitudes de assets ficticios.
