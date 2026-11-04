> ARCHIVO HISTÓRICO: corresponde a la reconstrucción anterior. El robot exportado como `yellowguy` se identifica ahora como **Junkbot**; Baller queda fuera del lanzamiento. El Yellow Guy clásico es otro personaje. No importes el robot con el ID yellowguy. Consulta `CHARACTERS.md` y `assets/character_sources.json` para la asignación actual. Estos recursos no se cargan automáticamente.

# Reconstrucción de las seis referencias: estado real

Se construyó una nueva versión con mallas, curvas, texturas de rostro/emblemas y rig de inspección. La fuente son las imágenes del autor visibles en la conversación; no se usaron modelos originales descargados. No se ha demostrado equivalencia 1:1. Se interpretaron superficies ocultas, formas ambiguas y detalles que las imágenes pequeñas no permiten medir.

## Archivos

`dist/reference-characters/<id>/<id>.fbx`: malla con esqueleto y texturas incrustadas para importar en Studio.

`<id>.glb`: alternativa portátil para inspección en visores 3D.

`Reference-reconstruction.blend`: escena editable con las seis mallas y texturas empaquetadas.

`*-reference.png` y `00-lineup-T.png`: renders de esos modelos, no capturas de Roblox Studio.

`tools/sculpt_reference_characters.py` y `tools/character_textures.py`: generadores reproducibles.

## Cambios de esta revisión

- Pelotocino: mechones curvos, rostro texturizado, chaqueta abierta, dedos y calzado.
- Tubers 93: mismo tipo de avatar, pechera de expresión triste, hoja curva continua y cadena con eslabones.
- Guest 666: cuerpo oscuro, gorra con visera, R y logotipo, ojos rojos. Sin marcas de combate.
- Yellow Guy: casco, cresta, paneles, pistones, anillos del abdomen, manos y pies mecánicos. Desgaste sobre armadura, sin vendas flotantes.
- Death Speaker: capucha, cuernos continuos, hombreras con espinas, filigrana, gema, brazales, garras y túnica con borde rasgado que oculta las piernas.
- Baller: versión del avatar 246 elegida por el autor; tupé, expresión facial, smoking, botones y pajarita. La foto original no muestra piernas completas; se interpretaron con pantalón y zapatos negros.

Se preserva la excepción de los asesinos y las señales discretas de combate de los supervivientes.

## Integración pendiente en Studio

Los nuevos archivos FBX **no están convertidos en assets de Roblox ni incrustados como MeshParts utilizables en el .rbxlx**. El `.rbxlx` mantiene la representación procedural anterior hasta instalar plantillas importadas. No se han inventado IDs de assets ni afirmado una carga que no se hizo.

1. Importar el FBX correspondiente con el importador 3D de Studio, conservando los nombres de las piezas `<id>__Head_mesh`, `<id>__Torso_mesh`, `<id>__LeftArm_mesh`, etc. Verificar texturas transparentes y tamaño: altura aproximada de 5–7 studs; ajustar escala de importación si las unidades difieren.
2. Nombrar el Model importado con su ID: `guest666`, `tubers93`, `pelotocino`, `baller`, `yellowguy` o `deathspeaker`.
3. Seleccionar únicamente ese Model y ejecutar `tools/InstallReferenceCharacter.luau` en la barra de comandos de Studio. Se copia a `ServerStorage/ReferenceCharacters`; no se sobrescribe una plantilla existente.
4. El módulo `ImportedAppearance` usa esas piezas para NPC y personajes R6. Requiere verificar pivotes y escala después de importar: ajustar pivotes de los miembros para que coincidan con el centro de cada parte del avatar. `ReferenceScale` permite escala uniforme; no corrige pivotes incorrectos.
5. Probar selección, inicio, animación, muerte y retorno al lobby. En R15 o sin plantilla válida se mantiene la apariencia anterior; esta revisión no declara compatibilidad de las nuevas mallas con R15.

La integración conserva la elección en lobby y equipa al comenzar la ronda. El avatar normal se restaura al terminar. Los maniquíes en pose T son de inspección.

## Validación

Comprobación estructural de FBX/GLB, imágenes y XML; comparación visual manual de los renders. Las nuevas mallas no se han ejecutado en Roblox Studio: importación, transparencia de texturas, pivotes, animaciones, permisos y rendimiento siguen pendientes. El rig suministrado es de referencia; la integración usa soldaduras a un avatar R6 existente. No se debe presentar el estado actual como réplica exacta final ni como importación terminada.
