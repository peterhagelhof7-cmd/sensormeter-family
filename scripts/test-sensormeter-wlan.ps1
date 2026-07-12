<#
.SYNOPSIS
    Funktionstest fuer ein laufendes Sensormeter-WLAN-Geraet (ESP32-WROOM-32).
    Prueft die Netzwerkdienste (Weboberflaeche, REST-API inkl. Auth, SNMP) und
    optional die serielle Kommandozeile - ergibt eine PASS/FAIL-Uebersicht.

.DESCRIPTION
    Ergaenzt scripts/snmp-load.ps1 (reiner SNMP-Lasttest) um einen vollstaendigen
    Funktionsdurchlauf. Gedacht fuer die Inbetriebnahme-Abnahme und fuer
    Regressionstests nach einem Firmware-Update.

    Wichtige Umgebungshinweise (aus einem realen Testlauf, siehe
    testing/sensormeter-wlan-testprotokoll.md):
      * Der Test-Host MUSS im selben Subnetz wie das Geraet sein. Gaeste-WLANs
        mit Client-/AP-Isolation (z.B. "*-GAST") blocken Peer-Verkehr - dann ist
        das Geraet trotz gleichem Subnetz nicht erreichbar. Regulaeres WLAN nutzen.
      * HTTP-Tests laufen ueber curl.exe (ab Windows 10 enthalten). PowerShells
        Invoke-WebRequest / Test-NetConnection / ICMP-Ping waren in der Praxis auf
        manchen WLAN-Adaptern unzuverlaessig (Timeouts trotz funktionierendem
        Server) - curl.exe verbindet zuverlaessig.

.PARAMETER TargetIp
    IP-Adresse des Geraets (z.B. 192.168.178.17).

.PARAMETER Password
    Passwort der Einstellungsseite (HTTP-Basic-User ist immer "admin").
    Default: admin (Werksvorgabe).

.PARAMETER Community
    SNMP-Community (Default: public).

.PARAMETER SerialPort
    Optionaler COM-Port (z.B. COM5) fuer die seriellen Zusatztests (status).
    Leer = serielle Tests ueberspringen.

.PARAMETER SkipSnmp
    SNMP-Test ueberspringen (falls snmp-load.ps1 nicht daneben liegt).

.EXAMPLE
    .\test-sensormeter-wlan.ps1 -TargetIp 192.168.178.17

.EXAMPLE
    .\test-sensormeter-wlan.ps1 -TargetIp 192.168.178.17 -Password geheim -SerialPort COM5
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $TargetIp,
    [string] $Password = "admin",
    [string] $Community = "public",
    [string] $SerialPort = "",
    [switch] $SkipSnmp
)

$ErrorActionPreference = "Stop"
$script:pass = 0
$script:fail = 0

function Test-Result([string]$name, [bool]$ok, [string]$detail = "") {
    if ($ok) {
        $script:pass++
        Write-Host ("  [PASS] {0,-42} {1}" -f $name, $detail) -ForegroundColor Green
    } else {
        $script:fail++
        Write-Host ("  [FAIL] {0,-42} {1}" -f $name, $detail) -ForegroundColor Red
    }
}

# HTTP-Statuscode ueber curl.exe holen (leerer String bei Verbindungsfehler)
function Get-HttpCode([string]$url, [string]$userpass = "") {
    $args = @("-s", "-m", "10", "-o", "NUL", "-w", "%{http_code}")
    if ($userpass) { $args += @("-u", $userpass) }
    $args += $url
    $code = & curl.exe @args 2>$null
    return "$code".Trim()
}

function Get-HttpBody([string]$url, [string]$userpass = "") {
    $args = @("-s", "-m", "10")
    if ($userpass) { $args += @("-u", $userpass) }
    $args += $url
    return (& curl.exe @args 2>$null) -join "`n"
}

$base = "http://$TargetIp"
$auth = "admin:$Password"

Write-Host ""
Write-Host "=== Sensormeter-WLAN Funktionstest ===" -ForegroundColor Cyan
Write-Host "Ziel: $TargetIp   Community: $Community   Serial: $(if($SerialPort){$SerialPort}else{'(uebersprungen)'})"
Write-Host ""

# ------------------------------------------------------------------ Erreichbarkeit
Write-Host "[1] Erreichbarkeit / Weboberflaeche" -ForegroundColor Yellow
$root = Get-HttpCode "$base/"
Test-Result "Hauptseite GET /" ($root -eq "200") "HTTP $root"
if ($root -ne "200") {
    Write-Host ""
    Write-Host "Geraet nicht erreichbar - Test abgebrochen." -ForegroundColor Red
    Write-Host "Pruefe: gleiches Subnetz? Kein Gaeste-WLAN mit Client-Isolation? IP korrekt?" -ForegroundColor Red
    exit 2
}

# ------------------------------------------------------------------ Oeffentliche REST-Endpunkte
Write-Host "[2] Oeffentliche REST-Endpunkte (erwartet 200)" -ForegroundColor Yellow
foreach ($e in @("/api/status", "/api/sensors", "/api/network", "/api/logs", "/api/graph", "/values.csv", "/branding/logo.bmp")) {
    $c = Get-HttpCode "$base$e"
    Test-Result "GET $e" ($c -eq "200") "HTTP $c"
}

# Inhaltliche Plausibilitaet. DHT22-Reads schlagen gelegentlich einzeln fehl
# (dann valid=false bis zum naechsten 60s-Zyklus) - daher mehrere Versuche.
$sensors = ""
$sensorOk = $false
for ($i = 0; $i -lt 4 -and -not $sensorOk; $i++) {
    if ($i -gt 0) { Start-Sleep -Seconds 2 }
    $sensors = Get-HttpBody "$base/api/sensors"
    $sensorOk = $sensors -match '"valid"\s*:\s*true'
}
Test-Result "GET /api/sensors liefert gueltigen Messwert" $sensorOk $sensors
$net = Get-HttpBody "$base/api/network"
Test-Result "GET /api/network meldet wlanUp=true" ($net -match '"wlanUp"\s*:\s*true') ""

# ------------------------------------------------------------------ Auth
Write-Host "[3] Authentifizierung (HTTP-Basic)" -ForegroundColor Yellow
foreach ($e in @("/api/config", "/api/config/export", "/settings")) {
    $cNo = Get-HttpCode "$base$e"
    Test-Result "GET $e OHNE Passwort -> 401" ($cNo -eq "401") "HTTP $cNo"
    $cYes = Get-HttpCode "$base$e" $auth
    Test-Result "GET $e MIT Passwort -> 200" ($cYes -eq "200") "HTTP $cYes"
}
$cWrong = Get-HttpCode "$base/api/config" "admin:__falsch__"
Test-Result "GET /api/config mit FALSCHEM Passwort -> 401" ($cWrong -eq "401") "HTTP $cWrong"

# ------------------------------------------------------------------ WLAN-Scan
Write-Host "[4] WLAN-Scan (async)" -ForegroundColor Yellow
$scan = Get-HttpBody "$base/api/wifi/scan" $auth
Test-Result "GET /api/wifi/scan startet Scan" ($scan -match '"status"') $scan

# ------------------------------------------------------------------ SNMP
if (-not $SkipSnmp) {
    Write-Host "[5] SNMP (v1/v2c, .1.3.6.1.4.1.99999.x)" -ForegroundColor Yellow
    $snmpScript = Join-Path $PSScriptRoot "snmp-load.ps1"
    if (Test-Path $snmpScript) {
        # snmp-load.ps1 gibt seine Zusammenfassung per Write-Host aus (Stream 6) -
        # daher *>&1, sonst bleibt $out leer und die Auswertung schlaegt fehl.
        $out = & $snmpScript -TargetIp $TargetIp -Community $Community -DurationSeconds 2 -IntervalMs 300 *>&1 | Out-String
        $m = [regex]::Match($out, 'Gesamt:\s*(\d+)\s*OK,.*?(\d+)\s*Fehler')
        if ($m.Success) {
            $ok = [int]$m.Groups[1].Value; $err = [int]$m.Groups[2].Value
            Test-Result "SNMP-Abfragen ($ok OK, $err Fehler)" ($ok -gt 0 -and $err -eq 0) ""
        } else {
            Test-Result "SNMP-Abfragen" $false "snmp-load.ps1-Ausgabe nicht auswertbar"
        }
    } else {
        Write-Host "  [--]  snmp-load.ps1 nicht gefunden - SNMP uebersprungen" -ForegroundColor DarkGray
    }
}

# ------------------------------------------------------------------ Serial (optional)
if ($SerialPort) {
    Write-Host "[6] Serielle Kommandozeile ($SerialPort)" -ForegroundColor Yellow
    $py = "C:\Users\$env:USERNAME\.platformio\penv\Scripts\python.exe"
    if (-not (Test-Path $py)) { $py = "python" }
    $script = @"
import serial, sys, time
s = serial.Serial(); s.port='$SerialPort'; s.baudrate=115200; s.timeout=0.3
s.dtr=False; s.rts=False; s.open(); time.sleep(0.3); s.reset_input_buffer()
s.write(b'status\n'); s.flush()
end=time.time()+4; buf=''
while time.time()<end:
    d=s.read(512)
    if d: buf+=d.decode('utf-8','replace')
s.close(); sys.stdout.write(buf)
"@
        $tmp = Join-Path $env:TEMP "sm_serial_status.py"
        Set-Content -Path $tmp -Value $script -Encoding utf8
        $st = & $py $tmp 2>$null | Out-String
        Test-Result "Serial 'status' antwortet (RUN_NORMAL)" ($st -match "RUN_NORMAL") ""
        Remove-Item $tmp -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------------ Zusammenfassung
Write-Host ""
Write-Host "=== Ergebnis: $script:pass PASS / $script:fail FAIL ===" -ForegroundColor Cyan
if ($script:fail -eq 0) {
    Write-Host "Alle Tests bestanden." -ForegroundColor Green
    exit 0
} else {
    Write-Host "$script:fail Test(s) fehlgeschlagen." -ForegroundColor Red
    exit 1
}
