# Pelotocino — prototipo visual con avatar R15 nativo

**Esta entrega prepara el nuevo método. Necesita un montaje en Roblox Studio.**
No incluye un avatar completo ya verificado ni imágenes del avatar terminado: este
entorno Linux no dispone de Roblox Studio y su acceso al catálogo está bloqueado.
No se ha utilizado Rig Generator, Avatar Setup ni Animation Editor aquí.

El taller usa el cuerpo que tú insertes con **Rig Generator**, conserva sus mallas
y articulaciones, y aplica `HumanoidDescription`. No contiene cuerpo ni cabello
de sustitución. Se detiene si no puede obtener un recurso. Las partidas,
habilidades, valores, animaciones y entregas anteriores de FORGOTTEN están intactos.

## Qué contiene

- `Pelotocino-R15-Taller.rbxlx`: lugar independiente para montar y revisar el avatar.
  No es una partida ni una actualización de FORGOTTEN.
- `Herramientas-Pelotocino-R15.rbxmx`: los mismos módulos del taller, para insertar
  opcionalmente en `ReplicatedStorage` de otra copia de trabajo. **Es un paquete
  de herramientas, no el modelo de personaje terminado.** Usa el `.rbxlx` para
  el procedimiento más sencillo, que ya incluye las vistas.
- `accesorios/Accesorios-Pelotocino.fbx`: solo **Backpack, Pan y Tracker** (3
  MeshParts). Reutiliza la geometría anterior de estos objetos. No es el FBX
  anterior de 25 mallas ni incluye cuerpo o cabello.
- `.blend`, geometría fuente y PNG Color/Roughness/Metalness de los accesorios.
- `accesorios/accesorios-solo-blender.png`: **render de accesorios en Blender**,
  sin personaje. No es una captura de Studio ni evidencia del avatar montado.
- Fuentes del taller, pruebas locales y manifest de integridad.

## Diseño propuesto para revisar

R15 masculino con cuerpo de malla nativo, delgado, piel clara y cara clásica.
Cabello **Pal Hair** auténtico (conocido como Bacon Hair), camiseta/chaqueta
**Blue and Black Motorcycle Shirt**, pantalones **Dark Green Jeans** del creador
**Roblox** y mochila marrón existente. Esa ropa clásica es una base visual para
evaluar; los jeans pueden verse más verdosos que los de la foto. **No se ha
confirmado una coincidencia exacta** de ropa, silueta o mochila con la referencia.

Los nombres se buscan y los IDs se verifican en Studio: creador usuario Roblox
(ID 1), nombre exacto y tipo de recurso. No se incluyen AssetIds inventados ni se
descargan recursos de terceros sin verificar. El cabello provendrá del catálogo,
no de nuestros antiguos mechones. La cara usa la sonrisa clásica nativa (Face 0).

## Montaje, una sola vez (Windows)

1. Descarga y **extrae todo el ZIP**. Abre `Pelotocino-R15-Taller.rbxlx` con Roblox
   Studio. Inicia sesión en tu cuenta. **No pulses Play todavía**.
2. En la barra superior, abre **Avatar → Character** (también puede estar en
   **Home → Character**). Es el **Rig Generator**; algunas versiones lo llaman
   **Rig Builder**. Escoge **R15**, cuerpo **Masculine** y un estilo con cuerpo de
   malla (por ejemplo, **Man**, si aparece en tu versión). Evita **Block**.
   Aparecerá **Rig** en Workspace. No uses el Pelotocino de la entrega anterior.
3. Abre **File → Import** y elige
   `accesorios/Accesorios-Pelotocino.fbx` del ZIP. En versiones que muestran el
   botón **3D Importer**, abre ese mismo importador desde la barra de herramientas.
   Revisa estos ajustes antes de pulsar **Import**:
   - **Add to Workspace**: activado; **Upload to Roblox**: activado.
   - **Creator**: tu cuenta o el grupo propietario del lugar.
   - **Import Only As Model**: activado; **Merge Meshes**: desactivado.
   - **Rig Type**: **No Rig**; **Scale Unit**: **Studs**.
   - Mantén las texturas. Deben aparecer **Backpack**, **Pan** y **Tracker**.
   Si Studio pide guardar/publicar para vincular permisos, guarda **este taller**
   como una experiencia nueva tuya. No elijas FORGOTTEN V4 ni sobrescribas V1–V4.
4. En **Explorer**, bajo Workspace, selecciona **Rig** y, manteniendo **Ctrl**,
   selecciona también el **Model completo importado del FBX**. Deben quedar dos
   modelos seleccionados. No selecciones sus piezas internas ni todo Workspace.
5. Pulsa **Ctrl+9** para abrir **Command Bar**. También puedes usar
   **Window → Script → Command Bar**. Pega esta única línea:

   ```lua
   require(game:GetService("ReplicatedStorage").PelotocinoVisualWorkshop.Workshop).install()
   ```

   Pulsa **Enter**; si tu barra es multilínea, pulsa **Run** o **Ctrl+Enter**.
   Espera a que termine la carga del catálogo. Revisa **Output** si aparece error.
6. Cuando Output diga **PELOTOCINO VISUAL LISTO PARA REVISAR**, encontrarás una
   carpeta nueva `Workspace.PelotocinoVisual_…` con:
   - `Pelotocino_Visual` y `Pelotocino_NPC_Visual`, clonados del mismo avatar.
   - `Equipo_SoloVisual`, con sartén y rastreador separados. No están equipados
     ni animados todavía; la foto principal solo requiere la mochila.
   El Rig original y las mallas importadas permanecen intactos. Repetir la
   instalación crea otra revisión; no reemplaza la anterior.

**Si algún paso falla**, no actives EditableMesh ni API Services para intentar
resolverlo: no forman parte de este prototipo. Conserva el mensaje completo de Output.

## Si el catálogo no encuentra el cabello o la ropa

1. Busca el nombre exacto indicado arriba en el catálogo de Roblox. Abre la
   página del artículo y comprueba que el creador sea **Roblox**, no una copia.
2. Copia el número de la URL `roblox.com/catalog/NUMERO/...`.
3. En Explorer abre
   `ReplicatedStorage → PelotocinoVisualWorkshop → Config`. Haz doble clic.
   Cambia solamente el `Id = 0` del recurso correspondiente por ese número.
4. Vuelve a seleccionar el Rig original y el Model del FBX. Para recargar los
   módulos editados, **guarda y vuelve a abrir el taller** antes de ejecutar la
   línea de instalación otra vez. Roblox conserva módulos `require()` en caché.

El instalador vuelve a comprobar el ID. No permite recursos de otro creador,
otro nombre ni otro tipo. Si Roblox impide cargar el artículo incluso con un ID
verificado, el montaje queda pendiente; no se inventará cabello ni ropa.

## Si faltan texturas en los accesorios

En el importador, revisa los materiales del FBX. Si no reconoce los mapas
embebidos, asigna los archivos de la carpeta `accesorios`: `Color.png` como color,
`Roughness.png` como rugosidad y `Metalness.png` como metalicidad; vuelve a importar.
Si se necesitan IDs de textura, súbelos mediante el **Asset Manager** bajo el
mismo propietario y asígnalos a `SurfaceAppearance.ColorMap`, `RoughnessMap` y
`MetalnessMap` en cada MeshPart. Esto requiere tu sesión de Roblox. No uses un ID
de malla en un campo de textura. El instalador no da por válida una malla sin color.

## Ver frente, lateral y espalda

Pulsa **Play** una vez montado el avatar. El taller muestra tres paneles con el
modelo real instalado: **FRENTE, LATERAL y ESPALDA**. Captúralos con
**Win + Mayús + S**. Son vistas de Roblox generadas en `ViewportFrame`, no renders
de Blender. El taller no contiene imágenes prerenderizadas del cuerpo.

Comprueba también el modelo directamente en el visor 3D de Studio, porque la
iluminación y el aspecto de PBR en ViewportFrame pueden diferir del Workspace.
Detén Play antes de hacer ajustes o guardar. Los modelos de revisión están
anclados y sin colisiones: no son todavía personajes jugables.

## Validar con Avatar Setup y guardar

1. En edición, selecciona el avatar montado. Abre **Avatar → Avatar Setup** para
   inspeccionar el cuerpo/accesorios según las opciones disponibles. El R15 ya
   viene articulado desde Rig Generator: no necesita generar otro cuerpo.
   No ejecutes auto-rig sobre el conjunto ni conviertas de nuevo el cuerpo.
2. Revisa el cabello, la cara, hombros, manos, ropa, mochila y sus correas desde
   los tres ángulos. Comprueba que la mochila no atraviese la espalda o los brazos.
   Su ajuste a cada cuerpo nativo requiere inspección real. `Config.BackpackFit`
   y `BackpackOffset` permiten corregir tamaño/posición y reconstruir **ambas**
   copias juntas. Recarga el taller después de editar Config, como se explica arriba.
3. **File → Save to File As…**, con nombre `Pelotocino-Visual-Revisado.rbxlx`.
   En algunas versiones el menú dice **Save to File** o **Save As**.
4. Para exportar el avatar ya resuelto, selecciona `Pelotocino_Visual` en Explorer,
   haz clic derecho → **Save to File…** y guarda `Pelotocino-Visual.rbxm` (o `.rbxmx`
   si la opción está disponible). Repite para `Pelotocino_NPC_Visual`.
   Guarda también el lugar, que contiene los recursos/configuración y las vistas.
5. Cierra y vuelve a abrir el archivo guardado. Verifica que cuerpo, ropa,
   cabello y mochila siguen visibles sin ejecutar otra vez el instalador.

No avances a Animation Editor ni integres el avatar en las partidas antes de
aprobar su apariencia. El paso siguiente será adaptar las animaciones existentes
al rig elegido y conectar las habilidades conservando sus valores; **ese trabajo
no forma parte de esta entrega visual**.

## Qué se verifica aquí y qué queda pendiente

Verificable en este entorno: código/flujo con dobles de APIs, rechazo de recursos
incorrectos y rigs incompletos, conservación del cuerpo, copias visuales iguales,
exportación/importación del FBX en Blender, UV/texturas, XML y ZIP íntegros,
sin cambios en `src/` ni entregas anteriores. No equivale a una prueba en Studio.

Pendiente en tu Studio: obtención efectiva del cuerpo/cabello/ropa oficiales,
importación y permisos, ajuste de mochila y ropa, apariencia real, capturas de
frente/lateral/espalda y guardado/reapertura. No hay animaciones nuevas ni demo de
combate en este taller. La sartén y el rastreador son accesorios visuales existentes.

## Fuentes oficiales consultadas

- [Rig Generator](https://create.roblox.com/docs/studio/rig-builder)
- [HumanoidDescription y apariencia](https://create.roblox.com/docs/characters/appearance)
- [Avatar Setup](https://create.roblox.com/docs/avatar-setup)
- [Importador 3D](https://create.roblox.com/docs/art/modeling/3d-importer)
- [Animation Editor — fase posterior](https://create.roblox.com/docs/animation/editor)

Documentación oficial consultada en el repositorio `Roblox/creator-docs`, commit
`ccc2b01d9bf8b85dee2905d1aaff3444fcbd01c5`. El interfaz puede variar por versión.
