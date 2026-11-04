-- Usa únicamente IDs de audio publicados con permiso para esta experiencia.
-- Cadenas vacías: música pendiente, sin intentar cargar recursos ficticios.
return {
 lmsDuration = 90,
 lobby = {title="Everything Is Fine",soundId=""},
 exit = {title="Escape the Forgotten",soundId=""},
 baconLMS = {title="LMS Pelotocino contra Tubers93",soundId="",duration=90},
 sfx={skill="",hit="",footstep="",objective="",item="",ui="",results="",reward=""},
 guestChase={title="Persecución de Guest 666",layers={
  {distance=100,soundId="",title="Presencia"},{distance=65,soundId="",title="Amenaza"},
  {distance=35,soundId="",title="Peligro"},{distance=18,soundId="",title="Persecución"}}},
 lastHope = {title="Last Hope 2.1",soundId="",duration=90,bpm=165},
 brokenFriendship = {title="Broken Friendship",soundId="",duration=90,bpm=160},
 shadowReaper = {
  title="Shadow Reaper",bpm=165,duration=168,
  -- Cuatro clips independientes y en bucle, NO posiciones de un único audio.
  layers={
   {distance=100,soundId="",title="Presencia"},
   {distance=65,soundId="",title="Amenaza"},
   {distance=35,soundId="",title="Peligro"},
   {distance=18,soundId="",title="Full Chase"},
  },
 },
}
