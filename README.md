# Sensormeter-Familie

Übersichts-Repository für die drei Sensormeter-Firmware-Projekte: ein
gemeinsamer Ursprung (Sensormeter), eine kostengünstigere WLAN-only-Variante
(Sensormeter WLAN) und ein Touchscreen-Betrachter, der beide per SNMP
abfragt (Sensormeter Display). Alle drei sind eigenständige ESP32-Firmware-
Projekte mit eigenem Repository — dieses Repo bündelt nur den
Überblick: Links, aktueller Stand, One-Pager.

## Mitglieder

| Projekt | Repository | Board | Rolle |
|---|---|---|---|
| **Sensormeter** | [github.com/peterhagelhof7-cmd/sensormeter](https://github.com/peterhagelhof7-cmd/sensormeter) | WT32-ETH01 | Ursprung: Ethernet-first, bis zu 2 Sensoren |
| **Sensormeter WLAN** | [github.com/peterhagelhof7-cmd/sensormeter-wlan](https://github.com/peterhagelhof7-cmd/sensormeter-wlan) | ESP32-WROOM-32 DevKit | Günstigere WLAN-only-Variante, 1 Sensor |
| **Sensormeter Display** | [github.com/peterhagelhof7-cmd/sensormeter-display](https://github.com/peterhagelhof7-cmd/sensormeter-display) | HW-458B (ESP32 + Touch-TFT) | Betrachter: fragt beide Geschwister per SNMP ab |

## Aktueller Stand

| Projekt | Version | Firmware-Umfang | Hardware-Status |
|---|---|---|---|
| Sensormeter | `0.9.0-rc2` (Beta) | P0–P7 code-vollständig | Code-vollständig, **Board-Bringup noch offen** — nicht vollständig auf echter Hardware verifiziert |
| Sensormeter WLAN | `0.9.0-rc3` (Beta) | P0–P7 code-vollständig | **Board-Bringup abgeschlossen** — DHT22, OLED, WLAN inkl. Fallback-AP, Taster, Webserver, SNMP, Syslog auf echtem Gerät verifiziert |
| Sensormeter Display | `0.9.0-rc2` (Beta) | P0–P8 vollständig | **Auf echter Hardware verifiziert** — wiederholt geflasht und getestet |

*(Stand wird bei größeren Änderungen aktualisiert, verbindlich ist immer das
`README.md`/`docs/entscheidungen.md` des jeweiligen Projekt-Repos.)*

## One-Pager

Kompakte Ein-Seiten-Übersicht je Projekt (Architektur, Kennzahlen):

- [docs/sensormeter-onepager.pdf](docs/sensormeter-onepager.pdf)
- [docs/sensormeter-wlan-onepager.pdf](docs/sensormeter-wlan-onepager.pdf)
- [docs/sensormeter-display-onepager.pdf](docs/sensormeter-display-onepager.pdf)

## Werkzeuge

### `scripts/snmp-load.ps1` — SNMP-Lastgenerator

Reine PowerShell-Implementierung eines SNMPv1-GET-Clients (kein
Net-SNMP/`snmpget` oder andere externe Tools nötig — nur ASN.1/BER von
Hand kodiert, siehe Skriptkopf). Fragt zyklisch alle bekannten OIDs unter
der gemeinsamen Basis-OID `.1.3.6.1.4.1.99999` (siehe „Was die Familie
verbindet" unten) ab und erzeugt damit gezielt Abfragelast auf einem
Sensormeter-Gerät — simuliert, was ein echtes Sensormeter-Display im
Dauerbetrieb an SNMP-Traffic erzeugt, nur einstellbar schneller/länger.
Gedacht für Stresstests bzw. um Stabilitätsprobleme unter Last
nachzustellen.

Funktioniert unverändert für alle drei Produktvarianten, ohne dass vorher
bekannt sein muss, welche gerade angesprochen wird:

| Variante | Antwortet auf Zweig `.4.x` (Sensor 2)? | Antwortet auf `.2.3.0` (WLAN-RSSI bei LAN+WLAN)? |
|---|---|---|
| Sensormeter | Nein (Sensor 2 deaktiviert) | Ja |
| Sensormeter PRO | Ja | Ja |
| Sensormeter WLAN | Nein (kein Sensor 2) | Nein (nur ein Interface, RSSI liegt dort auf `.2.2.0`) |

Nicht beantwortete OIDs zählen als normaler Timeout, nicht als Fehler —
das Skript muss also nicht wissen, mit welcher Variante es spricht.

**Parameter:**

| Parameter | Default | Bedeutung |
|---|---|---|
| `-TargetIp` | *(Pflicht)* | IP-Adresse des Sensormeter-Geräts |
| `-Community` | `public` | SNMP-Community-String (siehe Einstellungsseite des Geräts, Abschnitt „SNMP") |
| `-IntervalMs` | `200` | Pause zwischen zwei kompletten Abfrage-Zyklen — kleiner = mehr Last |
| `-TimeoutMs` | `800` | Timeout je einzelner OID-Abfrage |
| `-DurationSeconds` | `0` (endlos) | Gesamtlaufzeit; `0` = laufen bis Strg+C |
| `-ShowValues` | aus | Zeigt bei jedem Zyklus die tatsächlich zurückgelieferten Werte statt nur der Erfolg-/Timeout-Zähler |

**Anwendungsbeispiele:**

```powershell
# Einfacher Dauerlauf mit Standardeinstellungen (200ms Pause, endlos,
# nur Zusammenfassung pro Zyklus) - zum Laufen lassen im Hintergrund,
# waehrend man das Geraet anderweitig beobachtet (z.B. serieller Log-
# Mitschnitt, Webinterface im Browser offen).
.\snmp-load.ps1 -TargetIp 192.168.1.42

# Kurzer, knallharter Stresstest: 5 Minuten am Stueck mit 50ms Pause
# zwischen den Zyklen (14 OIDs je Zyklus -> deutlich mehr Last als ein
# einzelnes echtes Sensormeter Display je erzeugen wuerde).
.\snmp-load.ps1 -TargetIp 192.168.77.9 -IntervalMs 50 -DurationSeconds 300

# Debugging: einzelne Werte live mitverfolgen statt nur Zaehler - zeigt
# z.B. sofort, ob ein Sensormeter PRO tatsaechlich auf dem Sensor-2-Zweig
# antwortet oder ob der Community-String stimmt.
.\snmp-load.ps1 -TargetIp 192.168.1.50 -Community public -ShowValues -DurationSeconds 30

# Sensormeter PRO mit aktiviertem Sensor 2 pruefen: bei korrekter
# Konfiguration antworten hier zusaetzlich die drei .4.x-OIDs (statt wie
# bei einem einfachen Sensormeter nur als Timeout durchzulaufen).
.\snmp-load.ps1 -TargetIp 192.168.1.60 -ShowValues -DurationSeconds 5

# Sehr kurzer Rauchtest gegen ein frisch geflashtes Geraet - ein Zyklus
# genuegt, um zu sehen ob der SNMP-Agent grundsaetzlich antwortet.
.\snmp-load.ps1 -TargetIp 192.168.4.1 -DurationSeconds 1 -ShowValues
```

Ausgabe pro Zyklus zeigt Erfolg/Timeout/Fehler-Zähler sowie eine
Gesamtstatistik am Ende (bzw. beim Abbruch mit Strg+C den zuletzt
ausgegebenen Zwischenstand). Ein `[FEHLER]` (statt `[--]` für Timeout)
deutet auf ein echtes Problem hin — z. B. falscher Community-String
(führt zu einem SNMP `error-status` statt einfach keiner Antwort) oder
ein Netzwerkproblem jenseits eines simplen Timeouts.

## Was die Familie verbindet

- Gemeinsame SNMP-Basis-OID `.1.3.6.1.4.1.99999.x` (SNMP v1/v2c, read-only) —
  Sensormeter Display kann Geräte aus beiden Produktlinien ohne
  Codeänderung abfragen.
- Fallback-WLAN-Konvention `installer`/`installer` bei Verbindungsverlust.
- Gleiches Architekturmuster: Manager-Klassen mit `begin()`/`loop()`,
  mutex-geschützte zentrale Datenhaltung, LittleFS/NVS-Persistenz mit
  sicherem Schreib-Umschreib-Mechanismus.
- Einheitliches Webdesign (Navy/Orange/Cream-Palette) über alle drei
  Weboberflächen hinweg.
- Gemeinsames Einrichtungs-Skript [`scripts/flash.ps1`](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/scripts/flash.ps1)
  (liegt identisch in allen drei Repos) — installiert Abhängigkeiten,
  klont, baut und flasht jedes der drei Projekte.

## Über dieses Repository

Entstanden in Zusammenarbeit mit [Claude](https://claude.com/claude-code)
(Anthropic) als KI-Coding-Assistent.
