# Sensormeter-Familie

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/projektfamilie-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="docs/projektfamilie-light.png">
  <img alt="Sensormeter Projektfamilie: Sensormeter (LAN), Sensormeter WLAN (WLAN), Sensormeter PoE (LAN+PoE) und Sensormeter Display (Touchscreen), verbunden über gemeinsame Architektur und SNMP" src="docs/projektfamilie-light.png">
</picture>

Übersichts-Repository für die vier Sensormeter-Firmware-Projekte: ein
gemeinsamer Ursprung (Sensormeter), eine kostengünstigere WLAN-only-Variante
(Sensormeter WLAN), ein Touchscreen-Betrachter, der beide per SNMP abfragt
(Sensormeter Display), und ein vierter Zweig, der den vollen Funktionsumfang
von Sensormeter auf ein PoE-fähiges ESP32-S3-Board mit RJ45-Modularanschluss,
Relais und MQTT/Home-Assistant-Anbindung überträgt (Sensormeter PoE). Alle
vier sind eigenständige ESP32-Firmware-Projekte mit eigenem Repository —
dieses Repo bündelt nur den Überblick: Links, aktueller Stand, Feature-
Vergleich, One-Pager, gemeinsame Werkzeuge.

## Mitglieder

| Projekt | Repository | Board | Rolle |
|---|---|---|---|
| **Sensormeter** | [github.com/peterhagelhof7-cmd/sensormeter](https://github.com/peterhagelhof7-cmd/sensormeter) | WT32-ETH01 | Ursprung: Ethernet-first (natives EMAC), bis zu 2 Sensoren |
| **Sensormeter WLAN** | [github.com/peterhagelhof7-cmd/sensormeter-wlan](https://github.com/peterhagelhof7-cmd/sensormeter-wlan) | ESP32-WROOM-32 DevKit | Günstigere WLAN-only-Variante, 1 Sensor |
| **Sensormeter Display** | [github.com/peterhagelhof7-cmd/sensormeter-display](https://github.com/peterhagelhof7-cmd/sensormeter-display) | HW-458B (ESP32 + Touch-TFT) | Betrachter: fragt die anderen drei per SNMP ab |
| **Sensormeter PoE** | [github.com/peterhagelhof7-cmd/sensormeter-poe](https://github.com/peterhagelhof7-cmd/sensormeter-poe) | Waveshare ESP32-S3-ETH | Ethernet (W5500) + WLAN, PoE optional, RJ45-Modul + Relais + MQTT |

## Aktueller Stand

| Projekt | Version | Firmware-Umfang | Hardware-Status |
|---|---|---|---|
| Sensormeter | `0.9.0-rc4` (Beta) | P0–P7 + MQTT/Home Assistant + Anbieter-Branding + Werksreset-Umfangsauswahl + Serial-Kommandozeile | Code-vollständig, **Board-Bringup noch offen** — nicht vollständig auf echter Hardware verifiziert. MQTT, Branding sowie die beiden neuen Features (Werksreset-Umfangsauswahl, Serial-CLI) gebaut (`pio run`), aber mangels Board weder geflasht noch live getestet |
| Sensormeter WLAN | `0.9.0-rc4` (Beta) | P0–P7 + MQTT/Home Assistant + Anbieter-Branding + Werksreset-Umfangsauswahl + Serial-Kommandozeile | **Board-Bringup abgeschlossen** — DHT22, OLED, WLAN inkl. Fallback-AP, Taster, Webserver, SNMP, Syslog auf echtem Gerät verifiziert. MQTT geflasht, aber noch nicht gegen einen echten Broker getestet; Branding geflasht (sauberer Boot-Log verifiziert), Upload/Anzeige mangels Netzroute zum Board noch nicht per HTTP getestet. Werksreset-Umfangsauswahl und Serial-Kommandozeile sind hier zuerst entstanden und **auf echter Hardware geflasht/verifiziert** |
| Sensormeter Display | `0.9.0-rc4` (Beta) | P0–P8 + Live-Dashboard + Anbieter-Branding + Werksreset-Umfangsauswahl + Serial-Kommandozeile | **Auf echter Hardware verifiziert** — wiederholt geflasht und getestet. DHCP-Lease-Test und der neu ausgeweitete Mutex-Schutz (Sensor/Ping/Sensormeter/GraphManager) noch nicht auf echter Hardware ausgelöst. Branding sowie die beiden neuen Features (hier komplett neu entworfen, da dieses Projekt zuvor gar keinen Werksreset und keine XML-Konfiguration hatte) nur gebaut (`pio run`), noch nicht geflasht/live getestet — insbesondere der TFT-Farbkanal-Vorbehalt (siehe Feature-Vergleich) |
| Sensormeter PoE | `0.9.0-rc4` (Beta) | Lastenheft/Pflichtenheft vollständig umgesetzt + Anbieter-Branding + Werksreset-Umfangsauswahl + Serial-Kommandozeile | **Noch nicht geflasht** — kein Board zum Erstellungszeitpunkt vorhanden, nur per `pio run` gebaut/verifiziert. Versionsschema in dieser Runde von phasenbasiert (`0.1.0-p0`) auf SemVer umgestellt, analog zu den drei Geschwisterprojekten |

*(Stand wird bei größeren Änderungen aktualisiert, verbindlich ist immer das
`README.md`/`docs/entscheidungen.md` des jeweiligen Projekt-Repos.)*

## Feature-Vergleich

| Feature | Sensormeter | Sensormeter WLAN | Sensormeter Display | Sensormeter PoE |
|---|---|---|---|---|
| Ethernet | ✅ nativ (LAN8720) | ❌ | ❌ | ✅ SPI (W5500) |
| WLAN | ✅ Fallback-AP | ✅ primär, Fallback-AP | ✅ primär | ✅ parallel, Fallback-AP |
| PoE | ❌ | ❌ | ❌ | ✅ optional (Huckepack-Modul) |
| Eigene Sensoren | 1–2× DHT (Sensor 2 optional, "PRO") | 1× DHT22 | 1× DHT11 (nur eigener Status) | 1–2× DHT-22 (Sensor 2 optional, "PRO") |
| RJ45-Modularanschluss | ✅ (Sensor 2 / Relais-Pins reserviert) | ❌ | ❌ | ✅ (Sensor 2 / Relais) |
| Automatische Modul-Erkennung | ❌ (nur manuell) | – (kein Anschluss) | – | ✅ I2C-Scan + DHT-Probe beim Boot |
| Relais/Aktor | ❌ (Pins reserviert, nicht angesteuert) | – (kein Anschluss) | – | ✅ Web/REST/MQTT |
| Display | OLED SSD1306 128×64 | OLED SSD1306 128×64 | 2,8" TFT ST7789P3, **Touch** | OLED SH1107 1,5" 128×128 |
| BOOT-Taster als Bedienelement | ❌ (GPIO0 fest am Ethernet-Takt) | ✅ Seitenwechsel/Werksreset | – (Touch-Bedienung) | ✅ Seitenwechsel/Werksreset |
| Webserver (Status + Einstellungen) | ✅ | ✅ | ✅ (+ öffentliches Live-Dashboard) | ✅ |
| SNMP-Agent (read-only, v1/v2c) | ✅ | ✅ | ❌ (ist SNMP-**Client**) | ✅ |
| SNMP-Client (fragt andere Geräte ab) | ❌ | ❌ | ✅ bis zu 5 Sensormeter-Ziele | ❌ |
| Syslog-Versand | ✅ | ✅ | ❌ | ✅ |
| MQTT / Home Assistant | ✅ Sensor-Rolle | ✅ Sensor-Rolle | ❌ | ✅ Sensor- **und** Aktor-Rolle |
| Anbieter-Branding (Weisslabel) | ✅ Name + Logo (128×64, 1bpp) | ✅ Name + Logo (128×64, 1bpp) | ✅ Name + Logo (128×64, RGB565) — TFT-Farbkanal-Vorbehalt nicht auf echter Hardware verifiziert | ✅ Name + Logo (128×128, 1bpp) |
| Matter | – (nicht geprüft) | – (nicht geprüft) | – (nicht geprüft) | ❌ bewusst geprüft & abgelehnt (siehe dortige `entscheidungen.md`) |
| Werksreset mit wählbarem Umfang (Alles/Konfiguration/Messwerte/Branding) | ✅ | ✅ | ✅ | ✅ |
| Serial-Kommandozeile (USB): status/dhcp/ip/wifi/reset | ✅ (dhcp/ip mit Interface-Argument `lan\|wlan`) | ✅ | ✅ (kein LAN, daher ohne Interface-Argument) | ✅ (dhcp/ip mit Interface-Argument `lan\|wlan`) |
| Serial-Kommandozeile: dump/upload (Config-Backup per USB) | ✅ | ✅ | ❌ (kein XML-Konfigurationsdokument, Settings liegen einzeln in NVS) | ✅ |
| Lokales OTA-Update (.bin) | ✅ | ✅ | ✅ | ✅ |
| Zabbix-Template | ✅ | ✅ | ✅ (ICMP-only, Client hat keinen Agenten) | ✅ |
| PRTG-Template | ✅ | ✅ | – (kein Agent, Ping genügt) | ✅ |
| Gemeinsame SNMP-Basis-OID `.1.3.6.1.4.1.99999` | ✅ | ✅ (eigenes Sub-Schema, siehe unten) | – (fragt sie ab) | ✅ (identisch zu Sensormeter) |

**Legende:** ✅ vorhanden · ❌ nicht vorhanden/nicht umgesetzt · – nicht zutreffend für diese Geräterolle

## One-Pager

Kompakte Ein-Seiten-Übersicht je Projekt (Architektur, Kennzahlen,
aktueller Funktionsumfang):

- [docs/sensormeter-onepager.pdf](docs/sensormeter-onepager.pdf)
- [docs/sensormeter-wlan-onepager.pdf](docs/sensormeter-wlan-onepager.pdf)
- [docs/sensormeter-display-onepager.pdf](docs/sensormeter-display-onepager.pdf)
- [docs/sensormeter-poe-onepager.html](docs/sensormeter-poe-onepager.html)
  (noch als HTML, kein PDF-Export in dieser Runde — erste, ungeflashte
  Fassung, siehe Aktueller Stand oben)

Diese Dateien sind lokale Kopien der jeweils aktuellsten Version aus dem
Projekt-Repo (Quelle der Wahrheit bleibt immer `docs/` im jeweiligen
Repo) — bei größeren Firmware-Änderungen hier nachziehen.

## Architekturübersicht

[docs/projektfamilie.html](docs/projektfamilie.html) — dieselbe Skizze wie
das Bild oben, als eigenständige Seite (lokal im Browser öffnen). Identische
Kopie liegt in allen vier Projekt-Repos.

## Werkzeuge

### Monitoring-Integration (Zabbix / PRTG)

Jedes der drei SNMP-Agent-Projekte (Sensormeter, Sensormeter WLAN,
Sensormeter PoE) bringt inzwischen für **beide** Monitoring-Systeme
fertige Templates mit — Sensormeter Display braucht keins, da es selbst
nur SNMP-**Client** ist und sich stattdessen per einfachem ICMP-Ping
überwachen lässt (siehe dessen `docs/ZABBIX.md`).

| Projekt | Zabbix | PRTG |
|---|---|---|
| Sensormeter | [ZABBIX.md](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/docs/ZABBIX.md) · [Template](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/docs/zabbix-template-sensormeter.yaml) | [PRTG.md](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/docs/PRTG.md) · [Template](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/docs/prtg-template-sensormeter.odt) |
| Sensormeter WLAN | [ZABBIX.md](https://github.com/peterhagelhof7-cmd/sensormeter-wlan/blob/main/docs/ZABBIX.md) · [Template](https://github.com/peterhagelhof7-cmd/sensormeter-wlan/blob/main/docs/zabbix-template-sensormeter-wlan.yaml) | [PRTG.md](https://github.com/peterhagelhof7-cmd/sensormeter-wlan/blob/main/docs/PRTG.md) · [Template](https://github.com/peterhagelhof7-cmd/sensormeter-wlan/blob/main/docs/prtg-template-sensormeter-wlan.odt) |
| Sensormeter Display | [ZABBIX.md](https://github.com/peterhagelhof7-cmd/sensormeter-display/blob/main/docs/ZABBIX.md) (ICMP-only) · [Template](https://github.com/peterhagelhof7-cmd/sensormeter-display/blob/main/docs/zabbix-template-sensormeter-display.yaml) | – |
| Sensormeter PoE | [ZABBIX.md](https://github.com/peterhagelhof7-cmd/sensormeter-poe/blob/main/docs/ZABBIX.md) · [Template](https://github.com/peterhagelhof7-cmd/sensormeter-poe/blob/main/docs/zabbix-template-sensormeter-poe.yaml) | [PRTG.md](https://github.com/peterhagelhof7-cmd/sensormeter-poe/blob/main/docs/PRTG.md) · [Template](https://github.com/peterhagelhof7-cmd/sensormeter-poe/blob/main/docs/prtg-template-sensormeter-poe.odt) |

**Wichtig:** Sensormeter WLAN hat ein **eigenes, abweichendes**
OID-Schema (kein LAN-Interface, kein zweiter Sensor → WLAN-IP und
RSSI liegen auf anderen OID-Positionen als bei Sensormeter/Sensormeter
PoE) – dessen Zabbix- und PRTG-Templates sind deshalb NICHT mit den
beiden anderen austauschbar, siehe die jeweiligen `ZABBIX.md`/`PRTG.md`.

### `scripts/flash.ps1` — gemeinsames Setup-/Flash-Skript

Liegt identisch in allen vier Projekt-Repos (`scripts/flash.ps1`) —
installiert Python/Git/PlatformIO bei Bedarf, klont/aktualisiert das
gewählte Repo, baut und flasht. Fragt zuerst interaktiv (oder per
`-Project sensormeter|wlan|display|poe`), welches der vier Projekte
gemeint ist — unabhängig davon, welches Repo gerade lokal ausgecheckt
ist, lässt sich darüber jedes der vier einrichten. Seit Sensormeter PoE
versioniert (`$FlashScriptVersion`, aktuell `1.1.0`) und mit einem
Hinweis zur PlatformIO-Paket-Pool-Isolation versehen (Sensormeter PoE
braucht für W5500-Ethernet-Support die Community-Platform "pioarduino"
statt des offiziellen "espressif32" — beide registrieren Pakete unter
denselben Namen im global geteilten `~/.platformio`-Pool, ein
ungeschützter Build hätte die Pakete der anderen drei Projekte
überschrieben; Sensormeter PoEs `platformio.ini` isoliert das inzwischen
per eigenem `core_dir`).

**Geplant, noch nicht umgesetzt:** Mac-Unterstützung, ausdrücklich nur für
Apple-Silicon-Macs (ARM, kein Intel-Mac) — siehe Entscheidungsprotokoll im
Sensormeter-Repo für offene Fragen zur Umsetzung (PowerShell-Core-
Wiederverwendung vs. eigenes `flash.sh`, macOS-Portnamen, winget-Ersatz).

→ [scripts/flash.ps1 im Sensormeter-Repo](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/scripts/flash.ps1)

### `scripts/convert-logo.ps1` — Anbieter-Logo-Konverter fürs Branding-Feature

Liegt identisch in allen vier Projekt-Repos. Konvertiert ein beliebiges
Anbieter-Logo (PNG/JPG/BMP/…) in das fürs Anbieter-Branding-Feature
kompatible Rohformat — fragt zuerst interaktiv (oder per
`-Display sensormeter|wlan|poe|display|custom`), für welches Display
konvertiert werden soll, und reduziert Auflösung **und Farbtiefe**
konsequent auf das, was das jeweilige Display tatsächlich darstellen kann,
statt nur die Pixelmaße anzupassen:

| Display | Zielformat |
|---|---|
| Sensormeter / Sensormeter WLAN (OLED SSD1306, 128×64) | 1-Bit-Monochrom, 1024 Byte |
| Sensormeter PoE (OLED SH1107, 128×128) | 1-Bit-Monochrom, 2048 Byte |
| Sensormeter Display (TFT ST7789P3, Farbe) | RGB565, 128×64, 16.384 Byte — bewusst dieselbe Zielgröße wie die OLED-Projekte, nur Farbtiefe abweichend |

Das Quellbild wird seitenverhältnistreu eingepasst (nicht verzerrt) und
zentriert mit einer wählbaren Padding-Farbe (Default Schwarz) aufgefüllt.
Alle vier Projekte haben inzwischen ein implementiertes Branding-Feature
(`BrandingManager`, siehe jeweiliges `docs/entscheidungen.md`) und
konsumieren das hier erzeugte Format direkt.

**Zwei beim Bauen gefundene und behobene Bugs**:
- PowerShells `-shl`/`-shr` behalten den Typ des *linken* Operanden bei —
  `System.Drawing.Color.R/.G/.B` sind `System.Byte`, ein `Byte -shl 11`
  überläuft dadurch beim RGB565-Packen stillschweigend statt auf `Int32`
  erweitert zu werden (aus reinem Weiß wurde ohne `[int]`-Cast z. B.
  `0x00FF` statt `0xFFFF`). Gefunden per generiertem Testlogo +
  unabhängigem Python/Pillow-Rückbau, mit expliziten `[int]`-Casts behoben.
- Der `-Display display`-Preset nutzte zunächst fälschlich die native
  Panel-Auflösung 240×320 (Portrait) statt der tatsächlichen
  Bildschirm-Koordinaten im Landschaftsbetrieb (320×240) — beim
  Implementieren des zugehörigen `BrandingManager` bei Sensormeter Display
  bemerkt und auf 128×64 vereinheitlicht.

Sensormeter Display hat außerdem einen dokumentierten, nicht auf echter
Hardware verifizierten Vorbehalt: das Panel läuft mit
`TFT_RGB_ORDER=0` (BGR), unter dem bereits andernorts in dessen Firmware
einzelne benannte Farben empirisch getauscht werden mussten. Logos werden
bewusst in Standard-RGB565 gepackt statt vorab zu kompensieren — der
Schalter `-SwapRedBlue` ist der Escape-Hatch, falls sich auf echter
Hardware zeigt, dass doch getauscht werden muss.

→ [scripts/convert-logo.ps1 im Sensormeter-Repo](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/scripts/convert-logo.ps1)

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

Funktioniert unverändert für Sensormeter, Sensormeter WLAN und
Sensormeter PoE, ohne dass vorher bekannt sein muss, welche Variante
gerade angesprochen wird:

| Variante | Antwortet auf Zweig `.4.x` (Sensor 2)? | Antwortet auf `.2.3.0` (WLAN-RSSI bei LAN+WLAN)? |
|---|---|---|
| Sensormeter / Sensormeter PoE | Nein (Sensor 2 deaktiviert) | Ja |
| Sensormeter / Sensormeter PoE PRO | Ja | Ja |
| Sensormeter WLAN | Nein (kein Sensor 2 möglich) | Nein (nur ein Interface, RSSI liegt dort auf `.2.2.0`) |

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

- Gemeinsame SNMP-Basis-OID `.1.3.6.1.4.1.99999.x` (SNMP v1/v2c, read-only)
  bei den drei Agent-Projekten — Sensormeter Display kann Geräte aus allen
  drei Produktlinien ohne Codeänderung abfragen. **Nicht 100 % identisch:**
  Sensormeter WLAN hat wegen fehlendem LAN-Interface und fehlendem zweiten
  Sensor ein eigenes, verschobenes Sub-Schema unter `.2.x` und keinen
  `.4.x`-Zweig (siehe Feature-Vergleich oben und die jeweilige `PRTG.md`).
- Fallback-WLAN-Konvention `installer`/`installer` bei Verbindungsverlust
  (echter, selbst aufgespannter Access Point bei WLAN/PoE; Sensormeter
  selbst tritt stattdessen noch einem bestehenden Netz mit diesem Namen
  bei, siehe dessen `entscheidungen.md`).
- Gleiches Architekturmuster: Manager-Klassen mit `begin()`/`loop()`,
  mutex-geschützte zentrale Datenhaltung, LittleFS/NVS-Persistenz mit
  sicherem Schreib-Umschreib-Mechanismus.
- Einheitliches Webdesign (Navy/Orange/Cream-Palette) über alle
  Weboberflächen hinweg.
- Identisches RJ45-Modularanschluss-Pin-**Rollen**-Schema bei Sensormeter
  und Sensormeter PoE (Pin 3/4 I2C, Pin 5 externer DHT, Pin 6/7
  Relais-Steuerung/-Feedback) — die konkreten GPIO-Nummern unterscheiden
  sich zwangsläufig (anderer Chip), Steckmodule sind aber zwischen beiden
  Projekten austauschbar.
- Gemeinsames Einrichtungs-Skript [`scripts/flash.ps1`](https://github.com/peterhagelhof7-cmd/sensormeter/blob/main/scripts/flash.ps1)
  (liegt identisch in allen vier Repos) — installiert Abhängigkeiten,
  klont, baut und flasht jedes der vier Projekte.
- Werksreset mit wählbarem Umfang (Alles/Konfiguration/Messwerte/Branding)
  über die Weboberfläche sowie eine Serial-Kommandozeile über USB
  (`status`, `dhcp`, `ip`, `wifi`, `reset[ all]`, bei Sensormeter und
  Sensormeter PoE zusätzlich `dump`/`upload` für ein XML-Config-Backup) bei
  allen vier Projekten — zuerst bei Sensormeter WLAN gebaut und dort auf
  echter Hardware verifiziert, dann auf die anderen drei übertragen (bei
  Sensormeter Display musste dafür die Reset-Grundlage selbst erst neu
  entworfen werden, da es zuvor gar keinen Werksreset gab, siehe Feature-
  Vergleich oben).
- Home-Assistant/MQTT-Anbindung erst bei Sensormeter WLAN eingeführt,
  dann unverändert im Konzept auf Sensormeter (WT32-ETH01) übertragen
  (Sensor-Rolle, Transport per einfachem `WiFiClient` funktioniert dort
  interface-unabhängig für LAN **und** WLAN) und bei Sensormeter PoE um
  eine Aktor-Rolle (Relais) erweitert; Matter wurde für Sensormeter PoE
  bewusst geprüft und verworfen
  (W5500/CHIP-SDK-Treiberlücke, Arduino- vs. ESP-IDF-Konflikt,
  3-MB-No-OTA-Partitionsanforderung) — MQTT ist die funktionale
  Alternative, siehe dessen `entscheidungen.md`.

## Über dieses Repository

Entstanden in Zusammenarbeit mit [Claude](https://claude.com/claude-code)
(Anthropic) als KI-Coding-Assistent.
