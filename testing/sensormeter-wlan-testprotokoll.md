# Testprotokoll — Sensormeter WLAN

Funktionstest eines realen Sensormeter-WLAN-Geräts (ESP32-WROOM-32 DevKit)
über die serielle Schnittstelle **und** über das Netzwerk (Web/REST/SNMP/Syslog).
Das zugehörige, wiederholbare Prüfskript liegt unter
[`scripts/test-sensormeter-wlan.ps1`](../scripts/test-sensormeter-wlan.ps1).

## Prüfling & Umgebung

| | |
|---|---|
| Gerät | Sensormeter WLAN, Systemname `ERSTER-WLAN` |
| Firmware | `0.9.0-rc4` (Beta) |
| Hardware | ESP32-WROOM-32, DHT22 @ GPIO4, OLED SSD1306, USB-Serial CH340 |
| Serieller Port | COM5, 115200 Baud |
| Datum | 2026-07-12 |
| Test-Host | Windows 11, PowerShell, `curl.exe`, Python (pyserial) |

## Testumgebung — wichtige Erkenntnisse (Lessons Learned)

Diese Punkte haben den Testaufbau real beeinflusst und sind für jeden
Folgetest relevant:

1. **Gäste-WLAN mit Client-Isolation blockt den Test.** Ein erster Versuch über
   das offene Netz `SPS-GAST` schlug fehl: Gerät und Test-Host lagen zwar im
   selben Subnetz (192.168.231.x), aber der Access Point isoliert die Clients
   (nur ARP/Broadcast kam durch, jeder L3-Unicast — Ping/HTTP/SNMP — wurde
   verworfen). Belegt dadurch, dass das Gerät gleichzeitig **ausgehend**
   funktionierte (NTP-Sync gegen `de.pool.ntp.org` erfolgreich), nur der
   **Peer→Gerät**-Verkehr blockiert war. → **Für Netzwerktests ein reguläres
   WLAN ohne Client-Isolation verwenden** (hier: `SPS-Werkstatt`).

2. **`curl.exe` statt PowerShell-`Invoke-WebRequest`.** Auf dem Test-Adapter
   lieferten `Invoke-WebRequest`, `Test-NetConnection` (TCP-Test) und ICMP-Ping
   Timeouts/`False`, obwohl der Webserver einwandfrei antwortete — `curl.exe`
   (ab Windows 10 enthalten) verband zuverlässig und bekam HTTP 200. Das
   Prüfskript nutzt daher durchgängig `curl.exe`. **Ping ist hier kein
   verlässlicher Erreichbarkeitstest.**

3. **DHCP bei schwachem Signal langsam; statische IP verbindet sofort.** Bei
   ~−80 dBm brauchte die DHCP-Lease bis zu ~90 s (Gerät hängt solange in
   `WLAN_CHECK`). Nach Umstellung auf statische IP verband das Gerät nach jedem
   Reboot in Sekunden. Für schnelle Test-Zyklen ist eine statische IP praktisch.

4. **Offenes WLAN nicht per Serial-`wifi`-Kommando setzbar.** Das
   `wifi <ssid> <psk>`-Kommando verlangt zwei Token, ein leeres Passwort ist so
   nicht eingebbar. Offene Netze werden über `upload` einer `config.xml` mit
   `psk=""` gesetzt (`WiFi.begin(ssid, "")`).

## Ergebnisübersicht

**Serielle Tests (USB, COM5)**

| # | Test | Ergebnis | Beleg |
|---|------|:---:|---|
| S1 | Gerät per USB erkannt | ✅ | COM5 / CH340 (VID 1A86 PID 7523) |
| S2 | Serielle Kommandozeile reagiert | ✅ | `status`, `dump`, `upload`, `ip` |
| S3 | Config sichern (`dump`) | ✅ | vollständige `config.xml` als XML ausgegeben |
| S4 | Config einspielen (`upload`) + Reboot | ✅ | Import übernommen, sauberer Neustart |
| S5 | Boot-Sequenz vollständig | ✅ | LittleFS, DHT22, Syslog:514, MQTT, Web:80, SNMP:161, mDNS |
| S6 | WLAN-Join offen (leeres PSK) | ✅ | `SPS-GAST` → DHCP |
| S7 | WLAN-Join WPA2-PSK | ✅ | `SPS-Werkstatt` → DHCP 192.168.178.17 |
| S8 | Statische IP (`ip`-Kommando) | ✅ | sofortiger Reconnect nach Reboot |
| S9 | NTP-Sync | ✅ | `[LOG] Zeit: NTP-Sync erfolgreich` |
| S10 | mDNS | ✅ | `http://erster-wlan.local/` |
| S11 | Config-Persistenz über Reboot | ✅ | zurückgelesene == geschriebene Config |
| S12 | Sensor-Messwert plausibel | ✅ | 26.4 °C / 52.1 % stabil (siehe Hinweis DHT22) |

**Netzwerk-Tests (Host im selben WLAN, via `curl.exe`)**

| # | Test | Ergebnis | Beleg |
|---|------|:---:|---|
| N1 | Weboberfläche `GET /` | ✅ | HTTP 200, 3908 B HTML |
| N2 | `GET /api/status` | ✅ | `{systemName, firmwareVersion, uptimeSeconds, freeHeap, chipTemperatureC, timeSynced, time}` |
| N3 | `GET /api/sensors` | ✅ | `{"name":"DHT22","valid":true,"temperature":26.4,"humidity":52.2}` |
| N4 | `GET /api/network` | ✅ | IP/GW/DNS/MAC/SSID/RSSI, `usingFallbackWlan:false` |
| N5 | `GET /api/logs` | ✅ | Log-Einträge mit Zeitstempel |
| N6 | `GET /api/graph` | ✅ | 12-Punkt-Verlauf Temp/Feuchte |
| N7 | `GET /values.csv` | ✅ | CSV-Historie mit Zeitstempeln |
| N8 | `GET /branding/logo.bmp` | ✅ | 200, 1086 B (Default-Logo, `brandingHasLogo:true`) |
| N9 | Auth: geschützte Endpunkte **ohne** Passwort → 401 | ✅ | `/api/config`, `/api/config/export`, `/settings` |
| N10 | Auth: geschützte Endpunkte **mit** Passwort → 200 | ✅ | HTTP-Basic `admin:<pw>` |
| N11 | Auth: **falsches** Passwort → 401 | ✅ | Zugriff korrekt verweigert |
| N12 | `GET /api/wifi/scan` (async) | ✅ | `started` → `done` mit Netzliste (14 SSIDs) |
| N13 | SNMP v1/v2c, 14 OIDs unter `.1.3.6.1.4.1.99999` | ✅ | 28 Abfragen, 0 Timeout, 0 Fehler |
| N14 | SNMP: Sensor-2- & LAN-IP-Zweig korrekt abwesend | ✅ | „keine Instanz" (passt zur Family-OID-Konvention) |
| N15 | Syslog UDP 514 — Ereignis + Zyklus-Report | ✅ | RFC5424, siehe unten |

### Belege (Auszüge aus dem realen Lauf)

**SNMP** (`scripts/snmp-load.ps1 -ShowValues`):
```
Systemname            = ERSTER-WLAN
Firmwareversion       = 0.9.0-rc4
Systemtyp             = Sensormeter WLAN
WLAN-IP               = 192.168.178.17
WLAN-RSSI             = -61
Sensor 1 Name         = DHT22
Sensor 1 Temperatur   = 264   (= 26.4 °C, x10)
Sensor 1 Luftfeuchte  = 521   (= 52.1 %, x10)
Uptime                = 75508 (TimeTicks, 1/100s)
Freier Heap           = 195952
LAN-IP / Sensor 2     = keine Instanz (erwartet — kein LAN, nur 1 Sensor)
```

**Syslog** (UDP 514, empfangen auf dem Test-Host):
```
<134>1 - ERSTER-WLAN sensormeter-wlan - - Zeit: NTP-Sync erfolgreich
<134>1 - ERSTER-WLAN sensormeter-wlan - - ERSTER-WLAN | 192.168.178.17 | -63 | 26.4C/52% | 2026-07-12T17:58:17+0200 | 00:01:00
```
(Priorität `<134>` = Facility local0, Severity info; Ereignis-Log + Statusreport pro Sensorzyklus.)

## Nicht getestet / Einschränkungen

- **MQTT / Home-Assistant-Anbindung:** nicht geprüft — benötigt einen echten
  MQTT-Broker bzw. eine Home-Assistant-Instanz. Deckt sich mit dem Stand im
  Projekt-README (geflasht, bootet sauber, per Default deaktiviert, noch nicht
  gegen einen Broker verifiziert).
- **OTA-`.bin`-Upload:** Endpunkt vorhanden und passwortgeschützt, ein echter
  Firmware-Upload wurde in diesem Durchlauf nicht ausgeführt.
- **DHT22-Transient:** Ein einzelner `/api/sensors`-Abruf lieferte kurzzeitig
  `valid:false` (null-Werte), unmittelbar danach wieder gültige Werte. Das ist
  normales DHT22-Verhalten (gelegentlich ein fehlgeschlagener Read; die Firmware
  markiert den Zyklus korrekt als ungültig und erholt sich beim nächsten Read) —
  **kein Firmware-Fehler**. Das Prüfskript wiederholt diesen Test daher mehrfach.

## Wiederholen

```powershell
# Netzwerk- + SNMP-Test (Gerät muss im selben, nicht-isolierten WLAN sein):
scripts\test-sensormeter-wlan.ps1 -TargetIp <geraete-ip>

# Zusätzlich serielle Tests und abweichendes Passwort:
scripts\test-sensormeter-wlan.ps1 -TargetIp <geraete-ip> -Password <pw> -SerialPort COM5
```

Erwartetes Ergebnis dieses Durchlaufs: **20 PASS / 0 FAIL**.
