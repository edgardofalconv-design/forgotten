# Junkbot — personaje independiente

Fuente proporcionada por el autor: https://www.roblox.com/es/bundles/589/Junkbot . **589 es un bundle de Junkbot**, no un modelo de Yellow Guy ni un asset para insertar directamente con InsertService.

`CatalogCharacter.luau` consulta `AssetService:GetBundleDetailsAsync(589)`, obtiene el elemento `UserOutfit`, solicita su `HumanoidDescription` y crea el rig original R15 mediante Players. Conserva cuerpo, colores, proporciones y articulaciones. `CharacterFactory` añade tres arañazos discretos sobre el torso sin sustituir sus mallas.

El juego lo solicita automáticamente al iniciar el servidor y reintenta en el lobby cuando falla. La consulta ocurre fuera del ciclo de partida; no bloquea el inicio. Si no está disponible, se permite jugar con un robot R6 marcado **provisional**. Un original que termina de cargar se utiliza en la próxima aparición; no cambia un cuerpo a mitad de la ronda.

## Compatibilidad con el trabajo anterior

La plantilla preferida es `ServerStorage/CatalogCharacters/junkbot`. Si solo existe una antigua plantilla `yellowguy` con atributo `SourceBundleId=589`, el cargador la interpreta como Junkbot y etiqueta su copia con `ExpectedCharacterId=junkbot`; conserva el archivo original. Yellow Guy clásico usa su ruta independiente. Una plantilla local incompleta se descarta de la caché y se intenta la consulta del catálogo, sin destruir la plantilla guardada por el autor.

Para guardar opcionalmente el original dentro del archivo de Studio, se conserva `tools/ImportJunkbotFromBundle.luau`. Se pega en Command Bar en modo edición; crea una vista y la plantilla `junkbot`. No es necesario hacerlo para abrir y jugar esta versión. No necesita el nombre de usuario, cambiar el avatar personal ni activar HttpService.

El importador antiguo por avatar sigue guardado como herramienta histórica, pero el procedimiento recomendado parte del enlace de bundle. Las mallas robot FBX antiguas llamadas `yellowguy` son aproximaciones y no sustituyen el paquete original.

## Verificación real

Pasan las pruebas locales de carga con respuestas simuladas, caché, reintento, respuesta incompleta, plantilla anterior, separación de identidad y equipamiento/restauración R6/R15. Esto verifica código y manejo de errores, no la API real de Roblox.

Pendiente: ejecutar la descarga en Studio, verificar la apariencia y texturas, revisar los arañazos y probar caminar/saltar/colisiones. La nube no dispone de Studio ni acceso configurado al catálogo. No hay captura real del original en esta entrega.
