<#
.SYNOPSIS
    Erzeugt SNMP-Abfragelast auf einem Sensormeter-Geraet (WT32-ETH01 "Sensormeter"/
    "Sensormeter PRO", "Sensormeter WLAN") - reine SNMPv1-GET-Implementierung in
    PowerShell, ohne externe Tools (kein Net-SNMP/snmpget noetig).

.DESCRIPTION
    Fragt zyklisch alle bekannten OIDs unter der gemeinsamen Basis-OID
    .1.3.6.1.4.1.99999 ab, die alle drei Sensormeter-Projekte identisch verwenden
    (siehe docs/admin-guide.pdf der jeweiligen Repos, Abschnitt 6.1/6). Simuliert damit
    die Abfragelast, die ein echtes Sensormeter-Display per SNMP erzeugen wuerde -
    nuetzlich zum Stresstest bzw. um Stabilitaetsprobleme unter Last zu reproduzieren.

    Funktioniert unveraendert fuer alle Varianten:
      - Sensormeter (WT32-ETH01), Systemtyp "Sensormeter"        -> Zweig .4.x (Sensor 2)
        antwortet nicht, wird als Timeout gezaehlt (erwartet, kein Fehler)
      - Sensormeter PRO (WT32-ETH01, Sensor 2 aktiv)              -> Zweig .4.x antwortet
      - Sensormeter WLAN                                          -> Zweig .2.3.0 (LAN-IP)
        sowie .4.x antworten nicht (kein LAN-Interface, kein Sensor 2), ebenfalls
        erwarteter Timeout

.PARAMETER TargetIp
    IP-Adresse des Sensormeter-Geraets.

.PARAMETER Community
    SNMP-Community-String (Default: public, siehe Einstellungsseite Abschnitt 4.2 SNMP).

.PARAMETER IntervalMs
    Pause zwischen zwei kompletten Abfrage-Zyklen in Millisekunden (Default: 200).
    Kleiner = mehr Last.

.PARAMETER TimeoutMs
    Timeout je einzelner OID-Abfrage in Millisekunden (Default: 800).

.PARAMETER DurationSeconds
    Gesamtlaufzeit in Sekunden. 0 = endlos, bis Strg+C (Default: 0).

.PARAMETER ShowValues
    Zeigt bei jedem Zyklus die tatsaechlich zurueckgelieferten Werte an, nicht nur
    Erfolg/Timeout-Zaehler.

.EXAMPLE
    .\snmp-load.ps1 -TargetIp 192.168.1.42

.EXAMPLE
    .\snmp-load.ps1 -TargetIp 192.168.77.9 -IntervalMs 50 -DurationSeconds 300 -ShowValues
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$TargetIp,

    [string]$Community = "public",

    [int]$IntervalMs = 200,

    [int]$TimeoutMs = 800,

    [int]$DurationSeconds = 0,

    [switch]$ShowValues
)

$ErrorActionPreference = "Stop"

# ----------------------------------------------------------------------------
# Bekannte OIDs (Vereinigung aus Sensormeter + Sensormeter WLAN, siehe jeweilige
# docs/admin-guide.pdf Abschnitt 6). Nicht jede OID existiert auf jeder Variante -
# nicht beantwortete OIDs sind erwartungsgemaess und werden als Timeout gezaehlt,
# kein Skriptfehler.
# ----------------------------------------------------------------------------
$BaseOid = "1.3.6.1.4.1.99999"
$Oids = @(
    @{ Suffix = "1.1.0"; Label = "Systemname" }
    @{ Suffix = "1.2.0"; Label = "Firmwareversion" }
    @{ Suffix = "1.3.0"; Label = "Systemtyp" }
    @{ Suffix = "2.1.0"; Label = "LAN-IP / WLAN-IP" }
    @{ Suffix = "2.2.0"; Label = "WLAN-IP / WLAN-RSSI" }
    @{ Suffix = "2.3.0"; Label = "WLAN-RSSI (nur Sensormeter LAN+WLAN)" }
    @{ Suffix = "3.1.0"; Label = "Sensor 1 Name" }
    @{ Suffix = "3.2.0"; Label = "Sensor 1 Temperatur" }
    @{ Suffix = "3.3.0"; Label = "Sensor 1 Luftfeuchte" }
    @{ Suffix = "4.1.0"; Label = "Sensor 2 Name (nur PRO)" }
    @{ Suffix = "4.2.0"; Label = "Sensor 2 Temperatur (nur PRO)" }
    @{ Suffix = "4.3.0"; Label = "Sensor 2 Luftfeuchte (nur PRO)" }
    @{ Suffix = "5.1.0"; Label = "Uptime" }
    @{ Suffix = "5.2.0"; Label = "Freier Heap" }
)

# ----------------------------------------------------------------------------
# Minimaler ASN.1/BER-Encoder fuer SNMPv1 GET-Request (RFC 1157) - keine externe
# SNMP-Bibliothek verfuegbar/gewuenscht, daher hier von Hand implementiert.
# ----------------------------------------------------------------------------
function ConvertTo-BerLength {
    param([int]$Length)
    if ($Length -lt 0x80) {
        return , [byte]$Length
    }
    $bytes = [System.Collections.Generic.List[byte]]::new()
    $remaining = $Length
    while ($remaining -gt 0) {
        $bytes.Insert(0, [byte]($remaining -band 0xFF))
        $remaining = $remaining -shr 8
    }
    return , ([byte](0x80 -bor $bytes.Count)) + $bytes.ToArray()
}

function ConvertTo-BerTlv {
    param([byte]$Tag, [byte[]]$Content)
    $len = ConvertTo-BerLength -Length $Content.Length
    return , ([byte]$Tag) + $len + $Content
}

function ConvertTo-BerInteger {
    param([long]$Value)
    if ($Value -eq 0) { return ConvertTo-BerTlv -Tag 0x02 -Content @(0x00) }
    $bytes = [System.Collections.Generic.List[byte]]::new()
    $v = $Value
    $negative = $Value -lt 0
    while ($true) {
        $bytes.Insert(0, [byte]($v -band 0xFF))
        $v = $v -shr 8
        if ((-not $negative -and $v -eq 0 -and (($bytes[0] -band 0x80) -eq 0)) `
            -or ($negative -and $v -eq -1 -and (($bytes[0] -band 0x80) -ne 0))) {
            break
        }
    }
    return ConvertTo-BerTlv -Tag 0x02 -Content $bytes.ToArray()
}

function ConvertTo-BerOid {
    param([string]$Dotted)
    $parts = $Dotted.Split('.') | ForEach-Object { [int]$_ }
    $bytes = [System.Collections.Generic.List[byte]]::new()
    $bytes.Add([byte]((40 * $parts[0]) + $parts[1]))
    for ($i = 2; $i -lt $parts.Count; $i++) {
        $n = $parts[$i]
        if ($n -eq 0) {
            $bytes.Add(0x00)
            continue
        }
        $chunk = [System.Collections.Generic.List[byte]]::new()
        while ($n -gt 0) {
            $chunk.Insert(0, [byte]($n -band 0x7F))
            $n = $n -shr 7
        }
        for ($j = 0; $j -lt $chunk.Count - 1; $j++) {
            $chunk[$j] = [byte]($chunk[$j] -bor 0x80)
        }
        $bytes.AddRange($chunk)
    }
    return ConvertTo-BerTlv -Tag 0x06 -Content $bytes.ToArray()
}

function New-SnmpGetRequestPacket {
    param([string]$Community, [string]$Oid, [int]$RequestId)

    $version = ConvertTo-BerInteger -Value 0   # SNMPv1
    $comm = ConvertTo-BerTlv -Tag 0x04 -Content ([System.Text.Encoding]::ASCII.GetBytes($Community))

    $oidTlv = ConvertTo-BerOid -Dotted $Oid
    $nullTlv = ConvertTo-BerTlv -Tag 0x05 -Content @()
    $varBind = ConvertTo-BerTlv -Tag 0x30 -Content ($oidTlv + $nullTlv)
    $varBindList = ConvertTo-BerTlv -Tag 0x30 -Content $varBind

    $reqId = ConvertTo-BerInteger -Value $RequestId
    $errStatus = ConvertTo-BerInteger -Value 0
    $errIndex = ConvertTo-BerInteger -Value 0

    $pduContent = $reqId + $errStatus + $errIndex + $varBindList
    $pdu = ConvertTo-BerTlv -Tag 0xA0 -Content $pduContent   # GetRequest-PDU

    $message = $version + $comm + $pdu
    return ConvertTo-BerTlv -Tag 0x30 -Content $message
}

# ----------------------------------------------------------------------------
# Minimaler TLV-Decoder fuer die GetResponse-Antwort - sequenziell, kein voller
# ASN.1-Baum, reicht fuer die feste Struktur einer Ein-OID-Antwort.
# ----------------------------------------------------------------------------
function Read-BerLength {
    param([byte[]]$Bytes, [ref]$Pos)
    $b = $Bytes[$Pos.Value]; $Pos.Value++
    if ($b -lt 0x80) { return [int]$b }
    $n = $b -band 0x7F
    $len = 0
    for ($i = 0; $i -lt $n; $i++) {
        $len = ($len -shl 8) -bor $Bytes[$Pos.Value]
        $Pos.Value++
    }
    return $len
}

function Read-BerTlv {
    param([byte[]]$Bytes, [ref]$Pos)
    $tag = $Bytes[$Pos.Value]; $Pos.Value++
    $len = Read-BerLength -Bytes $Bytes -Pos $Pos
    $val = if ($len -gt 0) { $Bytes[$Pos.Value..($Pos.Value + $len - 1)] } else { @() }
    $Pos.Value += $len
    return [PSCustomObject]@{ Tag = $tag; Value = $val }
}

function ConvertFrom-BerSignedInt {
    param([byte[]]$Bytes)
    if ($Bytes.Count -eq 0) { return 0 }
    $result = [long]0
    $negative = ($Bytes[0] -band 0x80) -ne 0
    foreach ($b in $Bytes) { $result = ($result -shl 8) -bor $b }
    if ($negative) {
        $bits = $Bytes.Count * 8
        $result = $result - [long][math]::Pow(2, $bits)
    }
    return $result
}

function ConvertFrom-BerUnsignedInt {
    param([byte[]]$Bytes)
    $result = [uint64]0
    foreach ($b in $Bytes) { $result = ($result -shl 8) -bor $b }
    return $result
}

function Format-SnmpValue {
    param([PSCustomObject]$Tlv)
    switch ($Tlv.Tag) {
        0x02 { return (ConvertFrom-BerSignedInt -Bytes $Tlv.Value).ToString() }              # INTEGER
        0x04 { return [System.Text.Encoding]::UTF8.GetString($Tlv.Value) }                    # OCTET STRING
        0x05 { return "(leer/NULL)" }                                                         # NULL
        0x40 { return ($Tlv.Value -join '.') }                                                # IpAddress
        0x41 { return (ConvertFrom-BerUnsignedInt -Bytes $Tlv.Value).ToString() }             # Counter32
        0x42 { return (ConvertFrom-BerUnsignedInt -Bytes $Tlv.Value).ToString() }             # Gauge32
        0x43 { return "$(ConvertFrom-BerUnsignedInt -Bytes $Tlv.Value) (TimeTicks, 1/100s)" } # TimeTicks
        0x80 { return "(keine Instanz - OID auf diesem Geraet nicht vorhanden)" }             # noSuchObject/Instance (v2-Stil, defensiv)
        default { return "(Rohdaten, Tag 0x$('{0:X2}' -f $Tlv.Tag): $($Tlv.Value -join ' '))" }
    }
}

# ----------------------------------------------------------------------------
# Eine einzelne SNMP-GET-Abfrage per UDP, Port 161, mit Timeout.
# ----------------------------------------------------------------------------
function Invoke-SnmpGet {
    param([string]$TargetIp, [string]$Community, [string]$Oid, [int]$TimeoutMs)

    $requestId = Get-Random -Minimum 1 -Maximum ([int32]::MaxValue)
    $packet = New-SnmpGetRequestPacket -Community $Community -Oid "$BaseOid.$Oid" -RequestId $requestId

    $udp = New-Object System.Net.Sockets.UdpClient
    try {
        $udp.Client.ReceiveTimeout = $TimeoutMs
        $udp.Connect($TargetIp, 161)
        [void]$udp.Send($packet, $packet.Length)

        $remoteEp = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        $respBytes = $udp.Receive([ref]$remoteEp)

        $pos = 0
        $msg = Read-BerTlv -Bytes $respBytes -Pos ([ref]$pos)
        $p2 = 0
        $inner = $msg.Value
        [void](Read-BerTlv -Bytes $inner -Pos ([ref]$p2))   # version
        [void](Read-BerTlv -Bytes $inner -Pos ([ref]$p2))   # community
        $pdu = Read-BerTlv -Bytes $inner -Pos ([ref]$p2)    # GetResponse-PDU (Tag 0xA2)

        $p3 = 0
        [void](Read-BerTlv -Bytes $pdu.Value -Pos ([ref]$p3))   # request-id
        $errStatus = Read-BerTlv -Bytes $pdu.Value -Pos ([ref]$p3)
        [void](Read-BerTlv -Bytes $pdu.Value -Pos ([ref]$p3))   # error-index
        $varBindList = Read-BerTlv -Bytes $pdu.Value -Pos ([ref]$p3)

        $errStatusVal = ConvertFrom-BerSignedInt -Bytes $errStatus.Value
        if ($errStatusVal -ne 0) {
            return [PSCustomObject]@{ Success = $false; Reason = "SNMP-Fehler (error-status $errStatusVal)"; Value = $null }
        }

        $p4 = 0
        $varBind = Read-BerTlv -Bytes $varBindList.Value -Pos ([ref]$p4)
        $p5 = 0
        [void](Read-BerTlv -Bytes $varBind.Value -Pos ([ref]$p5))   # OID (Echo)
        $valueTlv = Read-BerTlv -Bytes $varBind.Value -Pos ([ref]$p5)

        return [PSCustomObject]@{ Success = $true; Reason = $null; Value = (Format-SnmpValue -Tlv $valueTlv) }
    }
    catch [System.Net.Sockets.SocketException] {
        return [PSCustomObject]@{ Success = $false; Reason = "Timeout/keine Antwort"; Value = $null }
    }
    catch {
        return [PSCustomObject]@{ Success = $false; Reason = $_.Exception.Message; Value = $null }
    }
    finally {
        $udp.Close()
    }
}

# ----------------------------------------------------------------------------
# Lastgenerierung: zyklisch alle OIDs abfragen, bis Dauer erreicht oder Strg+C.
# ----------------------------------------------------------------------------
Write-Host "SNMP-Lastgenerator fuer Sensormeter / Sensormeter PRO / Sensormeter WLAN"
Write-Host "Ziel: $TargetIp  Community: $Community  Intervall: ${IntervalMs}ms  Timeout: ${TimeoutMs}ms"
if ($DurationSeconds -gt 0) {
    Write-Host "Laufzeit: ${DurationSeconds}s (danach automatischer Stopp)"
} else {
    Write-Host "Laufzeit: endlos - mit Strg+C beenden"
}
Write-Host ""

$startTime = Get-Date
$cycle = 0
$totalOk = 0
$totalTimeout = 0
$totalError = 0

while ($true) {
    $cycle++
    $cycleOk = 0
    $cycleTimeout = 0
    $cycleError = 0

    foreach ($entry in $Oids) {
        $result = Invoke-SnmpGet -TargetIp $TargetIp -Community $Community -Oid $entry.Suffix -TimeoutMs $TimeoutMs

        if ($result.Success) {
            $cycleOk++
            if ($ShowValues) {
                Write-Host ("  [OK]      {0,-38} = {1}" -f $entry.Label, $result.Value)
            }
        }
        elseif ($result.Reason -eq "Timeout/keine Antwort") {
            $cycleTimeout++
            if ($ShowValues) {
                Write-Host ("  [--]      {0,-38} (keine Antwort - normal bei nicht vorhandenem Sensor 2/Interface)" -f $entry.Label) -ForegroundColor DarkGray
            }
        }
        else {
            $cycleError++
            Write-Host ("  [FEHLER]  {0,-38} {1}" -f $entry.Label, $result.Reason) -ForegroundColor Yellow
        }
    }

    $totalOk += $cycleOk
    $totalTimeout += $cycleTimeout
    $totalError += $cycleError

    $elapsed = (Get-Date) - $startTime
    Write-Host ("Zyklus {0,4}  |  OK {1,2}  Timeout {2,2}  Fehler {3,2}  |  Laufzeit {4:hh\:mm\:ss}  |  gesamt OK {5} / Timeout {6} / Fehler {7}" -f `
        $cycle, $cycleOk, $cycleTimeout, $cycleError, $elapsed, $totalOk, $totalTimeout, $totalError)

    if ($DurationSeconds -gt 0 -and $elapsed.TotalSeconds -ge $DurationSeconds) {
        break
    }

    Start-Sleep -Milliseconds $IntervalMs
}

Write-Host ""
Write-Host "Fertig. Gesamt: $totalOk OK, $totalTimeout Timeout, $totalError Fehler ueber $cycle Zyklen."
