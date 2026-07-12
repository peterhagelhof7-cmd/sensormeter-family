# AHT20/21-Sensormodul (Kategorie 1 — Bus-Modul)

Externer I2C-Sensor für Temperatur und Luftfeuchte, werkskalibriert und
günstig — steckt in die RJ45-Buchse von Sensormeter oder Sensormeter PoE
und wird von `SensorDetector::runDetection()` beim Boot bzw. auf Anfrage
automatisch am I2C-Bus erkannt (feste Adresse 0x38, bereits in
`KNOWN_CHIPS` in `SensorDetector.cpp` in beiden Firmware-Repos hinterlegt)
— setzt „Sensor 2 aktiv" automatisch, genau wie das DHT22-/BME280-Modul.
**Wie bei BME280/BH1750 liest die Firmware die Messwerte aktuell aber
noch nicht aus** (siehe „Bekannte Einschränkungen") — dieser Entwurf ist
bewusst reine Hardware-Vorarbeit.

AHT20/21 misst **dasselbe** wie Sensor 1 (intern), Sensor 2/DHT22 und das
BME280-Modul (Temperatur + Feuchte) — kein neues Messprinzip, sondern eine
andere Preis-/Genauigkeitsklasse. Sinnvoll als günstige Alternative zum
DHT22-Modul, nicht als Ergänzung dazu.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [aht20-verdrahtungsplan.html](aht20-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja — echter Bus-Abgriff, Pin 1/2/3/4 bleiben auf der OUT-Buchse ebenfalls live (kein Terminieren, siehe `README.md`) | Nein — Kette endet hier vollständig |
| Weitere I2C-/Kategorie-2-Module danach | Möglich, aber **kein zweites AHT20/21** (feste Adresse, siehe Hinweis unten) | Nicht möglich |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung) | Niedriger (nur Kabel + Stecker) |
| Einsatzzweck | Modul soll in einer Kette mit anderen I2C-Chiptypen und/oder Kategorie-2-Modulen stehen | Modul ist das letzte/einzige am Gerät, keine Kette geplant |

Für die Firmware sind beide Varianten identisch (`SensorDetector` liest in
beiden Fällen denselben I2C-Bus) — der Unterschied ist rein mechanisch.
Wie bei BME280/BH1750 wird bei Standard **nichts terminiert**: Pin 3/4
sind gleichzeitig „genutzt" und „durchgeschleift" — siehe `README.md`,
Abschnitt „Durchschleif-Regel".

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-1-Modul: Pin 1/2/5/6/7/8 werden 1:1 von IN nach OUT
durchgeschleift (unverändert, dieses Modul nutzt sie nicht). Pin 3/4
(SCL/SDA) werden auf dem Modul-PCB **abgegriffen und gleichzeitig
weitergereicht** — kein Terminieren.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | AHT20/21 VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | AHT20/21 GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | AHT20/21 SCL (Bus-Abgriff) | **ebenfalls live** (= IN Pin 3, kein Terminieren) |
| 4 | SDA | AHT20/21 SDA (Bus-Abgriff) | **ebenfalls live** (= IN Pin 4, kein Terminieren) |
| 5 | Einzelpin A (DHT/Kontakt) | — (unbenutzt) | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | — (unbenutzt) | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | — (unbenutzt) | durchgeschleift (= IN Pin 7) |
| 8 | Reserve | — (unbenutzt) | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zum AHT20/21 verdrahtet. Nur Pin
1/2/3/4 werden angeschlossen.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | AHT20/21 VCC |
| 2 | GND | AHT20/21 GND |
| 3 | SCL | AHT20/21 SCL |
| 4 | SDA | AHT20/21 SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| AHT20- oder AHT21-Breakout (I2C, 4-Pin: VCC/GND/SCL/SDA) | 1 | feste Adresse 0x38, keine Adresswahl möglich |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat — vor dem Bestücken prüfen |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul in der Kette — Pin 3/4 bleiben live, nichts terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff) | 1 Satz | siehe Pinbelegungstabelle oben |
| Litze zum AHT20/21-Breakout (4-adrig) | nach Bedarf | Länge je nach Einbausituation |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse mit 2 RJ45-Durchbrüchen, luftdurchlässig |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| AHT20- oder AHT21-Breakout (I2C, 4-Pin) | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | Länge je nach Einbausituation, kein Zwischenstecker |
| Gehäuse (optional) | 1 | kein RJ45-Durchbruch nötig, luftdurchlässig |

Spart eine Buchse und die Durchschleif-Verdrahtung, kostet aber die
Kettenfähigkeit vollständig — kein weiteres I2C- oder Kategorie-2-Modul
kann dahinterstecken (siehe „Bekannte Einschränkungen").

## Verdrahtungstabelle

| AHT20/21-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| GND | 2 | GND |
| SCL | 3 | I2C-Takt |
| SDA | 4 | I2C-Daten |

Bei der Standard-Variante werden zusätzlich Pin 1/2/5/6/7/8 1:1 auf die
OUT-Buchse durchverdrahtet, und Pin 3/4 bleiben als echter Bus-Abgriff
**ebenfalls** auf der OUT-Buchse live (kein Terminieren) — siehe
Pinbelegungstabelle oben.

## Hinweis zum Pull-up-Widerstand und zur festen I2C-Adresse

**Pull-up**: wie bei BME280/BH1750 — vor dem Bestücken prüfen, ob der
gemeinsame I2C-Bus (führt zum OLED-Display des Geräts) bereits einen
Pull-up hat, um einen doppelten Pull-up zu vermeiden.

**Feste Adresse — wichtigster Unterschied zu BME280/BH1750**: AHT20 und
AHT21 haben **keinen** Adress-Auswahlpin, beide sind fest auf `0x38`
verdrahtet. Anders als beim BME280-Modul (SDO-Pin, 0x76/0x77) oder
BH1750-Modul (ADDR-Pin, 0x23/0x5C) gibt es hier **keine Möglichkeit**,
zwei Module dieses Typs in derselben Kette zu betreiben — ein zweites
AHT20/21 würde immer mit dem ersten kollidieren. Wer zwei
Temperatur/Feuchte-Messpunkte am selben Gerät braucht, kombiniert
stattdessen ein AHT20/21-Modul mit einem DHT22-Modul (Pin 5, andere
Busart) oder einem BME280-Modul (umschaltbare Adresse).

## Bekannte Einschränkungen

- **Werte werden aktuell NICHT ausgelesen — nur erkannt**: `SensorManager::
  readExternalSensorIfEnabled()` liest „Sensor 2" ausschließlich per
  DHT-Protokoll auf Pin 5, unabhängig davon, was `SensorDetector` am
  I2C-Bus gefunden hat. Ein erkanntes AHT20/21 schaltet den Systemtyp
  zwar automatisch auf „PRO" um, der anschließende Leseversuch schlägt
  aber immer fehl, da auf Pin 5 kein DHT-Sensor hängt. Dieses Modul ist
  damit reine Hardware-Vorarbeit — siehe `README.md`, Abschnitt
  „Firmware-Lücke".
- **Redundant zu Sensor 1/2/DHT22/BME280**: misst dieselbe Größe
  (Temperatur/Feuchte) wie bereits vorhandene Datenpunkte — sinnvoll als
  günstigere/andere Genauigkeitsklasse, nicht als eigenständige neue
  Messgröße wie z. B. BH1750 (Helligkeit).
- **Keine zwei Module dieses Typs möglich**: feste I2C-Adresse `0x38`,
  kein Adress-Auswahlpin — siehe Hinweis oben.
- **Erkennt nur den ersten Treffer**: `SensorDetector::runDetection()`
  bricht den I2C-Scan beim ersten gefundenen Gerät ab — ein zweites
  I2C-Modul in derselben Kette wird nicht zusätzlich als eigener
  Datenpunkt erkannt/ausgelesen (gleiche Einschränkung wie bei allen
  anderen Kategorie-1-Modulen).
- **Kein Terminieren auf Pin 3/4 (nur Standard)**: der Bus bleibt auf der
  OUT-Buchse live — ein Fehlstecken (z. B. zwei I2C-Module mit derselben
  Adresse) führt zu einer echten Buskollision statt einer offenen
  Leitung.
- **Lite hat keine Kettenfähigkeit**: die Lite-Variante besitzt keine
  OUT-Buchse — dahinter kann weder ein zweites Kategorie-1- noch ein
  Kategorie-2-Modul stecken.
