@echo off
REM Publica la app en los dos sitios de Firebase: alumnos y vendedores.
REM Hacelo siempre desde la carpeta del proyecto (donde esta pubspec.yaml).

echo === 1/2 Alumnos ===
call flutter build web --release --dart-define=APP_MODE=student
if errorlevel 1 goto error
call firebase deploy --only hosting:alumnos
if errorlevel 1 goto error

echo.
echo === 2/2 Vendedores ===
call flutter build web --release --dart-define=APP_MODE=admin
if errorlevel 1 goto error
call firebase deploy --only hosting:vendedores
if errorlevel 1 goto error

echo.
echo Listo: los dos sitios quedaron publicados.
goto fin

:error
echo.
echo Hubo un error. Revisa el mensaje de arriba.

:fin
pause