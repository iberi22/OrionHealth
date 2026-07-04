param(
    [string]$Type = "golden"
)

$existing = gh issue list --label jules --state open --json number,title --limit 100 2>&1 | ConvertFrom-Json | ForEach-Object { $_.title }
$created = @()

if ($Type -eq "golden") {
    $features = @("about","allergies","auth","dashboard","eps_connection","home","local_agent","medications","onboarding","settings","user_profile","vitals","voice_chat")
    Write-Host "=== Creando issues de golden tests ==="
    foreach ($f in $features) {
        $title = "[jules] $f : add golden tests"
        if ($existing -notcontains $title) {
            $body = "Crear golden tests de referencia para el feature $f.`n`nUsar test/golden_test_utils.dart como base.`nCrear screenshots de referencia PNG en test/features/$f/presentation/golden/goldens/.`nTest file: test/features/$f/presentation/golden/${f}_page_golden_test.dart"
            $result = gh issue create --title $title --body $body --label jules 2>&1
            $created += $result
            Write-Host "  Creado: $result"
            Start-Sleep -Milliseconds 300
        } else {
            Write-Host "  Ya existe: $title"
        }
    }
}

if ($Type -eq "e2e") {
    $features = @("about","allergies","calendar_import","doctor_verification","eps_connection","health_data_import","health_record","health_sharing","local_agent","medical_research","meditation","reports","user_profile","vitals","voice_chat","network")
    Write-Host "=== Creando issues de E2E tests ==="
    foreach ($f in $features) {
        $title = "[jules] $f : add e2e test"
        if ($existing -notcontains $title) {
            $body = "Crear test de integracion/E2E para el feature $f.`n`n- Revisar test/integration/ para ejemplos existentes.`n- Crear test/features/$f/integration/ folder structure.`n- Cubrir flujos criticos del feature.`n- Usar patron E2E existente en proyectos similares."
            $result = gh issue create --title $title --body $body --label jules 2>&1
            $created += $result
            Write-Host "  Creado: $result"
            Start-Sleep -Milliseconds 300
        } else {
            Write-Host "  Ya existe: $title"
        }
    }
}

if ($Type -eq "network") {
    Write-Host "=== Creando issue de arquitectura network ==="
    $title = "[jules] network : refactor architecture to include application layer"
    $body = "La feature network tiene 3 subfeatures (governance, incentives, network_health) pero el harness espera una estructura uniforme.`n`nActualmente: governance, incentives, network_health ya tienen layers domain/infrastructure/presentation/full.`n`nProblema: el harness los busca en lib/features/network/{subfeature}/{layer}/ pero algunos layers (application) estan vacios.`n`nObjetivo: asegurar que network_health y las subfeatures tengan todos los layers completos.`
    if ($existing -notcontains $title) {
        $result = gh issue create --title $title --body $body --label jules 2>&1
        Write-Host "  Creado: $result"
    } else {
        Write-Host "  Ya existe: $title"
    }
}

Write-Host "`nCreados $($created.Count) issues nuevos."
