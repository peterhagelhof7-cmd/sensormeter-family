# BME280+CCS811-Kombimodul (Kategorie 1 — Bus-Modul)

Kombiniertes Klimamodul mit **zwei** I2C-Chips auf einer Platine: BME280
(Temperatur/Feuchte/Druck) und CCS811 (eCO₂/TVOC-Luftqualität). Beide
hängen am selben I2C-Bus (unterschiedliche Adressbereiche, keine
Kollision) und werden von `SensorDetector::runDetection()` erkennbar
sein, sobald die entsprechenden Adressen in `KNOWN_CHIPS` ergänzt sind
(siehe „Bekannte Einschränkungen" — CCS811 fehlt dort aktuell noch).

**Warum kombiniert statt zwei Einzelmodule?** CCS811 liefert genauere
eCO₂/TVOC-Werte, wenn ihm die aktuelle Umgebungstemperatur und
-luftfeuchte zur Kompensation mitgeteilt werden (`setEnvironmentalData()`
im CCS811-Treiber). Da BME280 genau diese beiden Werte misst und auf
demselben Modul-PCB sitzt, kann die Kompensation ohne Umweg über das
Gerät direkt zwischen den beiden Chips auf dem Modul selbst zugeführt
werden (I2C-seitig durch das Gerät, das beide Chips ausliest und den
Kompensationswert zurückschreibt — siehe „Bekannte Einschränkungen" zum
aktuellen Firmware-Stand).

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [bme280-ccs811-verdrahtungsplan.html](bme280-ccs811-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja — echter Bus-Abgriff, Pin 1/2/3/4 bleiben auf der OUT-Buchse ebenfalls live | Nein — Kette endet hier vollständig |
| Weitere I2C-/Kategorie-2-Module danach | Möglich (BME280 0x76/0x77, CCS811 0x5A/0x5B belegen den Bus, andere Adressen bleiben frei) | Nicht möglich |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung) | Niedriger (nur Kabel + Stecker) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren I2C- und/oder Kategorie-2-Modulen stehen | Modul ist das letzte/einzige am Gerät, keine Kette geplant |

Wie bei allen Kategorie-1-Modulen wird bei Standard **nichts terminiert**
— Pin 3/4 sind gleichzeitig „genutzt" und „durchgeschleift". Ein
**zweites** komplettes Kombimodul in derselben Kette würde trotzdem
kollidieren (beide Chip-Typen jeweils mit derselben Adressmenge) — dafür
müssten an einem zweiten Modul BEIDE Chips gleichzeitig auf ihre
jeweilige Alternativadresse umgestellt werden (BME280 SDO → VCC, CCS811
ADDR → VCC).

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-1-Modul: Pin 1/2/5/6/7/8 werden 1:1 von IN nach OUT
durchgeschleift (unverändert, dieses Modul nutzt sie nicht). Pin 3/4
(SCL/SDA) werden auf dem Modul-PCB **abgegriffen und gleichzeitig
weitergereicht** — kein Terminieren. Beide Chips hängen parallel am
selben internen SCL/SDA-Netz des Moduls.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | BME280 VCC + CCS811 VCC (parallel) | durchgeschleift (= IN Pin 1) |
| 2 | GND | BME280 GND + CCS811 GND + CCS811 WAK (parallel) | durchgeschleift (= IN Pin 2) |
| 3 | SCL | BME280 SCL + CCS811 SCL (Bus-Abgriff, parallel) | **ebenfalls live** (= IN Pin 3, kein Terminieren) |
| 4 | SDA | BME280 SDA + CCS811 SDA (Bus-Abgriff, parallel) | **ebenfalls live** (= IN Pin 4, kein Terminieren) |
| 5 | Einzelpin A (DHT/Kontakt) | — (unbenutzt) | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | — (unbenutzt) | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | — (unbenutzt) | durchgeschleift (= IN Pin 7) |
| 8 | Reserve | — (unbenutzt) | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zu beiden Chips verdrahtet (intern
parallel). Nur Pin 1/2/3/4 werden angeschlossen.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | BME280 VCC + CCS811 VCC |
| 2 | GND | BME280 GND + CCS811 GND + CCS811 WAK |
| 3 | SCL | BME280 SCL + CCS811 SCL |
| 4 | SDA | BME280 SDA + CCS811 SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BME280-Breakout (I2C, 4-Pin) | 1 | SDO-Pin fest auf GND → Adresse 0x76 |
| CCS811-Breakout (I2C, mit WAK-Pin) | 1 | ADDR-Pin fest auf GND → Adresse 0x5A, WAK fest auf GND (dauerhaft aktiv) |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat — vor dem Bestücken prüfen (gilt für beide Chips gemeinsam, nur ein Pull-up-Paar pro Bus) |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul — Pin 3/4 bleiben live, nichts terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff) | 1 Satz | siehe Pinbelegungstabelle oben |
| Interne Verdrahtung BME280↔CCS811 (VCC/GND/SCL/SDA parallel) | 1 Satz | beide Chips teilen sich dieselben vier Leitungen auf dem Modul-PCB |
| WAK-Brücke CCS811 → GND | 1 | dauerhafte Aktivierung, kein dynamisches Wecken vorgesehen |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse mit 2 RJ45-Durchbrüchen, luftdurchlässig für beide Sensoren |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BME280-Breakout (I2C, 4-Pin) | 1 | wie Standard |
| CCS811-Breakout (I2C, mit WAK-Pin) | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | kein Zwischenstecker |
| Interne Verdrahtung BME280↔CCS811 + WAK-Brücke | wie Standard | siehe oben |
| Gehäuse (optional) | 1 | kein RJ45-Durchbruch nötig, luftdurchlässig |

Spart eine Buchse und die Durchschleif-Verdrahtung, kostet aber die
Kettenfähigkeit vollständig — kein weiteres I2C- oder Kategorie-2-Modul
kann dahinterstecken (siehe „Bekannte Einschränkungen").

## Verdrahtungstabelle

| Chip-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| BME280 VCC, CCS811 VCC | 1 | 3V3 |
| BME280 GND, CCS811 GND, CCS811 WAK | 2 | GND |
| BME280 SCL, CCS811 SCL | 3 | I2C-Takt |
| BME280 SDA, CCS811 SDA | 4 | I2C-Daten |

Bei der Standard-Variante werden zusätzlich Pin 1/2/5/6/7/8 1:1 auf die
OUT-Buchse durchverdrahtet, und Pin 3/4 bleiben als echter Bus-Abgriff
**ebenfalls** auf der OUT-Buchse live (kein Terminieren).

## Hinweis zu Pull-up, Adressen und WAK-Pin

**Pull-up**: wie bei allen I2C-Modulen — vor dem Bestücken prüfen, ob der
gemeinsame Bus (führt zum Display des Geräts) bereits einen Pull-up hat.
Nur **ein** Pull-up-Paar pro Bus, auch wenn zwei Chips auf demselben
Modul sitzen — nicht pro Chip verdoppeln.

**I2C-Adressen**: BME280 auf `0x76` (SDO → GND) oder `0x77` (SDO → VCC),
CCS811 auf `0x5A` (ADDR → GND, Default vieler Breakouts) oder `0x5B`
(ADDR → VCC) — die beiden Chip-Typen überschneiden sich nie, unabhängig
von der jeweiligen Adresswahl. Ein zweites Kombimodul in derselben Kette
braucht trotzdem **beide** Chips auf der jeweils anderen Adresse.

**WAK-Pin (nur CCS811)**: CCS811 braucht diesen Pin aktiv LOW, um auf
I2C-Anfragen zu reagieren — auf diesem Modul fest auf GND verdrahtet
(dauerhaft „wach"), da kein dynamisches Energiemanagement vorgesehen ist.
Manche CCS811-Breakouts (z. B. Adafruit) haben WAK bereits werkseitig auf
GND vorverdrahtet — beim konkret verwendeten Breakout prüfen, ob die
Brücke noch ergänzt werden muss.

## Bekannte Einschränkungen

- **CCS811 fehlt noch in `SensorDetector::KNOWN_CHIPS`**: anders als
  BME280 (bereits hinterlegt) wird CCS811 vom I2C-Scan aktuell **nicht**
  als bekannter Chip erkannt — der Scan würde ihn nur als
  „I2C-Sensor (unbekannt, 0x5A)" melden. Ergänzung der Adressen 0x5A/0x5B
  in `KNOWN_CHIPS` ist eine ausstehende, einfache Firmware-Änderung
  (analog zu den bereits hinterlegten Chips), aber noch nicht umgesetzt.
- **Werte werden aktuell NICHT ausgelesen — nur BME280 potenziell
  erkannt**: `SensorManager::readExternalSensorIfEnabled()` liest
  „Sensor 2" ausschließlich per DHT-Protokoll auf Pin 5, unabhängig davon,
  was `SensorDetector` am I2C-Bus gefunden hat. Weder BME280- noch
  CCS811-Werte gelangen aktuell in „Sensor 2" — siehe `README.md`,
  Abschnitt „Firmware-Lücke". Bei diesem Kombimodul kommt hinzu, dass die
  aktuelle Firmware ohnehin nur **einen** I2C-Sensor als „Sensor 2"
  vorsieht — zwei gleichzeitig gewollte Chips (Klimadaten UND
  Luftqualität) brauchen eine entsprechend erweiterte Datenstruktur, nicht
  nur einen I2C-Lesepfad. Dieses Modul ist damit noch deutlicher reine
  Hardware-Vorarbeit als die Einzelchip-Module.
- **Temp/Feuchte-Kompensation nicht automatisiert**: die auf dem Modul
  physisch mögliche Kompensation (BME280-Werte an CCS811 übergeben)
  erfordert einen periodischen I2C-Schreibzugriff vom Gerät aus
  (`setEnvironmentalData()`), der in der aktuellen Firmware nicht
  existiert — reiner Hardware-Entwurf, die Verkabelung ist vorbereitet,
  die Firmware-Logik dafür fehlt komplett.
- **CCS811-Einbrennzeit**: laut Datenblatt ca. 48 Stunden Erstbetrieb für
  stabile Werte, danach ca. 20 Minuten Warmlauf nach jedem Einschalten —
  ein Hardware-/Nutzungshinweis, unabhängig von der Firmware.
- **Erkennt nur den ersten Treffer**: `SensorDetector::runDetection()`
  bricht den I2C-Scan beim ersten gefundenen Gerät ab — bei diesem Modul
  wird je nach Scan-Reihenfolge nur einer der beiden Chips (vermutlich
  BME280 auf 0x76, niedrigere Adresse zuerst im Scan) überhaupt als
  Treffer gemeldet, nicht beide.
- **Kein Terminieren auf Pin 3/4 (nur Standard)**: der Bus bleibt auf der
  OUT-Buchse live — ein Fehlstecken (Adresskollision) führt zu einer
  echten Buskollision statt einer offenen Leitung.
- **Lite hat keine Kettenfähigkeit**: die Lite-Variante besitzt keine
  OUT-Buchse — dahinter kann weder ein zweites Kategorie-1- noch ein
  Kategorie-2-Modul stecken.
