# DropQuest — Loot Tracker

Aplicación web de fans, en español y adaptable a celular, para registrar progreso de temporada. No está afiliada ni respaldada por Epic Games.

## Funciones

- Registro manual de cofres, horas, meta personal y una probabilidad hipotética editable.
- Estadísticas sincronizadas con Supabase tras iniciar sesión por correo.
- Perfil privado por defecto; se puede optar por hacerlo público.
- Buscador de perfiles públicos que aparecen conforme la comunidad se registra.
- Check-in diario autodeclarado y contador comunitario agregado.
- Mensajes motivacionales rotativos.

## Limitaciones importantes

Epic no ofrece una API pública general que permita consultar los cofres abiertos de cualquier jugador. Los registros son ingresados por los usuarios y no se verifican con Epic. El ejemplo 1/137.500 es una hipótesis editable, no una tasa oficial ni garantía de recompensa. Los tokens del día tampoco prueban la entrega del objeto. Los perfiles aparecen cuando una persona crea cuenta y activa la opción de perfil público.

## Arquitectura

- Frontend estático `index.html`, publicado con GitHub Pages.
- Supabase Auth por correo y Postgres con RLS.
- `supabase-schema.sql` documenta la estructura inicial (ya aplicada en el proyecto).
- El cliente usa solo Project URL y publishable key pública. Nunca almacenar `service_role`, secretos ni contraseñas en el repositorio.
- Perfil y estadísticas sincronizados al iniciar sesión. El progreso que ya estaba en ese navegador se conserva al crear la primera cuenta.
- Sin sesión, la demo local se guarda en `localStorage`; el check-in comunitario requiere iniciar sesión.

## Operación

Sitio: https://leonixim350.github.io/dropquest/
Repositorio: https://github.com/leonixim350/dropquest

Para cambiar el frontend, actualiza `index.html` en `main`; GitHub Pages vuelve a desplegarlo. La URL publicada está autorizada para retorno de Supabase Auth. Mantén RLS activo y revisa los asesores de seguridad al cambiar políticas o funciones.
