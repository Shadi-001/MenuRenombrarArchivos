Renombrador Interactivo en PowerShell
Este script interactivo en PowerShell permite renombrar archivos en una carpeta de forma masiva, ordenarlos por diferentes criterios, y también reordenarlos manualmente antes de aplicar los cambios.

Requisitos
-Windows con PowerShell 5.1 o superior
-Permisos para ejecutar scripts de PowerShell (puedes usar -ExecutionPolicy Bypass)

Cómo usarlo
Descarga o clona este repositorio:

git clone https://github.com/Shadi-001/MenuRenombrarArchivos.git
cd Menu RenombrarArchivos

Haz clic derecho sobre el archivo Renombrar.ps1 y selecciona "Ejecutar con PowerShell"
O abre PowerShell manualmente y ejecuta:

powershell -ExecutionPolicy Bypass -File .\Renombrar.ps1

Funcionalidades
✅ Selección de carpeta con explorador gráfico
✅ Filtro por tipo de archivo (jpg, png, mp4, mkv, personalizado o todos)
✅ Ordenamiento por:

-Nombre (A-Z, Z-A)
-Fecha de creación (antiguo a nuevo o viceversa)
-Sin orden (tal cual están)

✅ Vista previa del renombrado
✅ Reordenamiento manual interactivo:

-Subir/bajar archivos
-Ver cambios en tiempo real

✅ Opción para mantener el nombre original
✅ Nombres con formato personalizado (ej: Proyecto Capitulo 001)

📝 Notas
-No se hacen cambios hasta confirmar al final.
-El script asegura una vista clara antes de realizar los cambios.
