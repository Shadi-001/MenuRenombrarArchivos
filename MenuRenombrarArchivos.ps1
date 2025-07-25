Clear-Host

Add-Type -AssemblyName System.Windows.Forms
$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderDialog.Description = "Selecciona la carpeta donde renombrar los archivos"
$folderDialog.ShowNewFolderButton = $false

$folderSeleccionada = if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $folderDialog.SelectedPath
} else {
    Write-Host "No se seleccionó ninguna carpeta. Cancelando..."
    Pause
    exit
}

Set-Location -Path $folderSeleccionada

function Mostrar-Menu {
    Write-Host "=============================================="
    Write-Host "Selecciona el tipo de archivo a renombrar:"
    Write-Host "1 - jpg"
    Write-Host "2 - png"
    Write-Host "3 - mp4"
    Write-Host "4 - mkv"
    Write-Host "5 - Otro (manual)"
    Write-Host "6 - Todos los archivos"
    Write-Host "=============================================="
}

# Menu de extension
$extension = $null

do {
    Mostrar-Menu
    $choice = Read-Host "Opcion (1-6)"
    $choice = $choice.Trim()

    switch ($choice) {
        '1' { $extension = 'jpg' }
        '2' { $extension = 'png' }
        '3' { $extension = 'mp4' }
        '4' { $extension = 'mkv' }
        '5' { 
            $extension = Read-Host "Escribe la extension sin punto (ej. pdf, docx)"
            $extension = $extension.Trim()
        }
        '6' { $extension = '*' }
        Default {
            Write-Host "`nOpcion invalida. Intenta de nuevo.`n"
            $extension = $null
        }
    }
} until ($extension)

Clear-Host

# Menu de ordenamiento
function Ordenar-Archivos($archivos) {
    Write-Host "=============================================="
    Write-Host "Selecciona el orden en que se procesaran los archivos:"
    Write-Host "1 - Alfabetico (A-Z)"
    Write-Host "2 - Alfabetico (Z-A)"
    Write-Host "3 - Fecha (antiguo a nuevo)"
    Write-Host "4 - Fecha (nuevo a antiguo)"
    Write-Host "5 - Sin orden (tal cual estan)"
    Write-Host "=============================================="
    $orden = Read-Host "Opcion (1-5)"

    switch ($orden) {
        '1' { return $archivos | Sort-Object Name }
        '2' { return $archivos | Sort-Object Name -Descending }
        '3' { return $archivos | Sort-Object CreationTime }
        '4' { return $archivos | Sort-Object CreationTime -Descending }
        '5' { return $archivos }
        default {
            Write-Host "Opcion invalida. Se usara el orden actual."
            return $archivos
        }
    }
}

$archivos = if ($extension -ne '*') {
    Get-ChildItem -File -Filter "*.$extension"
} else {
    Get-ChildItem -File
}

if ($archivos.Count -eq 0) {
    Write-Host "`n=================================================="
    Write-Host "No se encontraron archivos con la extension: $extension"
    Write-Host "==================================================`n"
    Pause
    exit
}

$archivos = Ordenar-Archivos $archivos

Write-Host "`nSe encontraron $($archivos.Count) archivo(s) con la extension: $extension`n"

$keepname = Read-Host "¿Deseas conservar el nombre original del archivo al final? (S/N)"
$mainPrefix = Read-Host "Escribe el nombre principal (ej. Proyecto)"
$capName = Read-Host "Escribe el nombre base (ej. Parte, Capitulo)"

function Mostrar-Preview($lista) {
    Clear-Host
    Write-Host "Vista previa del renombrado:`n"
    for ($i = 0; $i -lt $lista.Count; $i++) {
        $num = ($i + 1).ToString("D3")
        $nuevoNombre = "$mainPrefix $capName $num"
        if ($keepname.ToUpper() -eq 'S') {
            $linea = "$nuevoNombre - $($lista[$i].Name)"
        } else {
            $linea = "$nuevoNombre$($lista[$i].Extension)"
        }
        $espaciado = ($lista[$i].Name + ' ').PadRight(50,'-')
        Write-Host "$($i+1) - $espaciado => $linea"
    }
    Write-Host "`n==================================================`n"
}

Mostrar-Preview $archivos

# Reordenamiento manual
$modificar = Read-Host "¿Deseas reordenar manualmente los archivos? (S/N)"
if ($modificar.ToUpper() -eq 'S') {
    do {
        Mostrar-Preview $archivos
        $sel = Read-Host "Selecciona el numero del archivo a mover (1-$($archivos.Count)) o Enter para terminar"
        if (![string]::IsNullOrWhiteSpace($sel) -and $sel -match '^\d+$') {
            $idx = [int]$sel - 1
            if ($idx -ge 0 -and $idx -lt $archivos.Count) {
                $seguir = $true
                while ($seguir) {
                    Mostrar-Preview $archivos
                    Write-Host "Seleccionado: $($archivos[$idx].Name)"
                    Write-Host "`n==================================================`n"
                    Write-Host "1 - Subir"
                    Write-Host "2 - Bajar"
                    Write-Host "4 - Elegir otro archivo"
                    Write-Host "5 - Terminar reordenamiento"
                    $accion = Read-Host "Elige una opcion"
                    switch ($accion) {
                        '1' {
                            if ($idx -gt 0) {
                                $tmp = $archivos[$idx - 1]
                                $archivos[$idx - 1] = $archivos[$idx]
                                $archivos[$idx] = $tmp
                                $idx--
                            }
                        }
                        '2' {
                            if ($idx -lt ($archivos.Count - 1)) {
                                $tmp = $archivos[$idx + 1]
                                $archivos[$idx + 1] = $archivos[$idx]
                                $archivos[$idx] = $tmp
                                $idx++
                            }
                        }
                        '4' {
                            $seguir = $false
                        }
                        '5' {
                            $sel = ''; $seguir = $false
                        }
                    }
                }
            }
        }
    } while (![string]::IsNullOrWhiteSpace($sel))
}

# Confirmar
$confirm = Read-Host "¿Deseas continuar con el renombrado? (S/N)"
if ($confirm.ToUpper() -ne 'S') {
    Write-Host "Operacion cancelada."
    Pause
    exit
}

Clear-Host
$count = 1
foreach ($archivo in $archivos) {
    $num = $count.ToString("D3")
    $nuevoBase = "$mainPrefix $capName $num"
    if ($keepname.ToUpper() -eq 'S') {
        $nuevoNombre = "$nuevoBase - $($archivo.Name)"
    } else {
        $nuevoNombre = "$nuevoBase$($archivo.Extension)"
    }
    Rename-Item -Path $archivo.FullName -NewName $nuevoNombre
    $count++
}

Write-Host "`nRenombrado completado exitosamente."
Pause
