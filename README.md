# DropQuest — Loot Tracker

Aplicación web de fans, en español y adaptable a celular, para registrar progreso de temporada. No está afiliada ni respaldada por Epic Games.

## Funciones

- Registro de alias, cofres, horas, meta y una probabilidad hipotética.
- Estadísticas sincronizadas con Supabase tras iniciar sesión.
- Perfil privado por defecto; el usuario puede optar por hacerlo público.
- Buscador de perfiles públicos y perfiles de ejemplo indicados como tales.
- Check-in diario autodeclarado y contador comunitario agregado.
- Mensajes motivacionales rotativos.

## Limitaciones importantes

Epic no ofrece una API pública general que permita consultar los cofres abiertos por cualquier jugador. Los registros son ingresados por los usuarios y no se verifican con Epic. El ejemplo 1/137.500 es una hipótesis editable, no una tasa oficial ni garantía de recompensa. Los tokens del día tampoco prueban la entrega del objeto.

## Arquitectura

- Frontend estático `index.html`, publicado con GitHub Pages.
- Supabase Auth por correo y Postgres con RLS.
- `supabase-schema.sql` configura perfiles, estadísticas, reportes diarios y políticas.
- Solo usa en el cliente el Project URL y la publishable key pública. Nunca guardar `service_role`, secretos ni contraseñas en el repo.
- La sesión sincroniza perfil y estadísticas; sin sesión, la demo local se conserva en `localStorage`.

## Operación

Para cambiar el frontend, actualiza `index.html` en `main`; GitHub Pages vuelve a desplegarlo. El URL de Auth de Supabase debe permitir el sitio publicado para los correos de confirmación. Mantén RLS activo y revisa los asesores de seguridad al cambiar políticas o funciones.
