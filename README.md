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
