# BME280-Sensormodul (Kategorie 1 — Bus-Modul)

Externer I2C-Sensor für Temperatur, Luftfeuchte **und** Luftdruck — erstes
Kategorie-1-Modul der Familie, steckt in die RJ45-Buchse von Sensormeter
oder Sensormeter PoE und wird von `SensorDetector::runDetection()` beim
Boot bzw. auf Anfrage automatisch am I2C-Bus erkannt (Adresse 0x76/0x77,
siehe `KNOWN_CHIPS` in `SensorDetector.cpp` in beiden Firmware-Repos) —
setzt „Sensor 2 aktiv" automatisch, genau wie das DHT22-Modul.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [bme280-verdrahtungsplan.html](bme280-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja — **echter Bus-Abgriff**, Pin 1/2/3/4 bleiben auf der OUT-Buchse ebenfalls live (kein Terminieren, siehe `README.md`) | Nein — Kette endet hier vollständig |
| Weitere I2C-/Kategorie-2-Module danach | Möglich (Multi-Drop-Bus), solange sich I2C-Adressen nicht überschneiden | Nicht möglich |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung) | Niedriger (nur Kabel + Stecker) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren I2C- und/oder Kategorie-2-Modulen stehen | Modul ist das letzte/einzige am Gerät, keine Kette geplant |

Für die Firmware sind beide Varianten identisch (`SensorDetector` liest in
beiden Fällen denselben I2C-Bus) — der Unterschied ist rein mechanisch.
Anders als bei Kategorie-2-Modulen wird bei Standard **nichts terminiert**:
Pin 3/4 sind gleichzeitig „genutzt" (Sensor angeschlossen) und
„durchgeschleift" (echter Bus, kein Schalter) — siehe `README.md`,
Abschnitt „Durchschleif-Regel".

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-1-Modul: Pin 1/2/5/6/7/8 werden 1:1 von IN nach OUT
durchgeschleift (unverändert, dieses Modul nutzt sie nicht). Pin 3/4
(SCL/SDA) werden auf dem Modul-PCB **abgegriffen und gleichzeitig
weitergereicht** — kein Terminieren, ein weiteres I2C-Modul (oder ein
Kategorie-2-Modul auf Pin 5/6/7) kann dahinterstecken.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | BME280 VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | BME280 GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | BME280 SCL (Bus-Abgriff) | **ebenfalls live** (= IN Pin 3, kein Terminieren) |
| 4 | SDA | BME280 SDA (Bus-Abgriff) | **ebenfalls live** (= IN Pin 4, kein Terminieren) |
| 5 | Einzelpin A (DHT/Kontakt) | — (unbenutzt) | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | — (unbenutzt) | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | — (unbenutzt) | durchgeschleift (= IN Pin 7) |
| 8 | Reserve | — (unbenutzt) | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zum BME280 verdrahtet. Nur Pin 1/2/3/4
werden angeschlossen.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | BME280 VCC |
| 2 | GND | BME280 GND |
| 3 | SCL | BME280 SCL |
| 4 | SDA | BME280 SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BME280-Breakout (I2C, 4-Pin: VCC/GND/SCL/SDA) | 1 | SDO-Pin legt die Adresse fest (siehe Hinweis unten) |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | **nur falls der Bus noch keinen Pull-up hat** — vor dem Bestücken prüfen, siehe Hinweis unten |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul in der Kette — Pin 3/4 bleiben live, nichts terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff) | 1 Satz | siehe Pinbelegungstabelle oben |
| Litze zum BME280-Breakout (4-adrig) | nach Bedarf | Länge je nach Einbausituation |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse mit 2 RJ45-Durchbrüchen |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BME280-Breakout (I2C, 4-Pin) | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | Länge je nach Einbausituation, kein Zwischenstecker |
| Gehäuse (optional) | 1 | kein RJ45-Durchbruch nötig |

Spart eine Buchse und die Durchschleif-Verdrahtung, kostet aber die
Kettenfähigkeit vollständig — kein weiteres I2C- oder Kategorie-2-Modul
kann dahinterstecken (siehe „Bekannte Einschränkungen").

## Verdrahtungstabelle

| BME280-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| GND | 2 | GND |
| SCL | 3 | I2C-Takt |
| SDA | 4 | I2C-Daten |

Bei der Standard-Variante werden zusätzlich Pin 1/2/5/6/7/8 1:1 auf die
OUT-Buchse durchverdrahtet, und Pin 3/4 bleiben als echter Bus-Abgriff
**ebenfalls** auf der OUT-Buchse live (kein Terminieren, anders als bei
Kategorie-2-Modulen) — siehe Pinbelegungstabelle oben.

## Hinweis zum Pull-up-Widerstand und zur I2C-Adresse

**Pull-up**: BME280-Breakouts haben selten einen eigenen Pull-up auf
SCL/SDA. Der gemeinsame I2C-Bus führt aber bereits zum OLED-Display des
Geräts, und viele SSD1306-Display-Breakouts bringen selbst einen
eingebauten Pull-up mit — vor dem Bestücken mit einem Multimeter zwischen
SCL/SDA und 3V3 prüfen (sollte ~4,7 kΩ zeigen, falls schon vorhanden).
Einen doppelten Pull-up vermeiden (Display *und* dieses Modul), das senkt
den effektiven Widerstand unnötig (zwei parallele 4,7 kΩ ergeben 2,35 kΩ)
und belastet die Bustreiber stärker als nötig — analog zum bereits
dokumentierten Hinweis beim DHT22-Modul.

**I2C-Adresse**: BME280 unterstützt zwei Adressen, umschaltbar über den
SDO-Pin des Breakouts: SDO auf GND → `0x76`, SDO auf VCC (bzw. offen mit
internem Pull-up auf vielen Breakouts) → `0x77` — beide bereits in
`SensorDetector.cpp`s `KNOWN_CHIPS`-Tabelle hinterlegt. Wird ein zweites
BME280-Modul in derselben Kette gesteckt (Multi-Drop, siehe „Varianten"),
**müssen** beide unterschiedliche Adressen verwenden, sonst kollidieren
sie auf dem Bus — eines auf `0x76`, das andere auf `0x77` verdrahten.

## Bekannte Einschränkungen

- **Erkennt nur den ersten Treffer**: `SensorDetector::runDetection()`
  bricht den I2C-Scan beim ersten gefundenen Gerät ab („ein Modul
  erwartet") und setzt „Sensor 2 aktiv" dafür. Ein zweites BME280- oder
  anderes I2C-Modul in derselben Kette wird dadurch **nicht** zusätzlich
  als eigener Datenpunkt erkannt/ausgelesen — die aktuelle Firmware
  unterstützt nur einen einzigen aktiven I2C-Sensor als „Sensor 2".
  Mehrere I2C-Module gleichzeitig zu stecken ist hardwareseitig möglich
  (siehe Durchschleif-Regel), aber ohne Firmware-Erweiterung praktisch
  nur für zukünftige Auswertung vorbereitet, nicht heute nutzbar.
- **Kein Terminieren auf Pin 3/4 (nur Standard)**: anders als bei
  Kategorie-2-Modulen bleibt der Bus auf der OUT-Buchse live — ein
  Fehlstecken (z. B. zwei Module mit derselben I2C-Adresse) führt nicht
  zu einer offenen Leitung, sondern zu einer echten Buskollision. Adresse
  vor dem Verkabeln prüfen (siehe Hinweis oben).
- **Lite hat keine Kettenfähigkeit**: die Lite-Variante besitzt keine
  OUT-Buchse — dahinter kann weder ein zweites Kategorie-1- noch ein
  Kategorie-2-Modul stecken.
- **Teilt sich den Bus mit dem Display**: die I2C-Adresse `0x3C` des
  geräteinternen OLED-Displays ist beim Scan ausgenommen (siehe
  `SensorDetector.cpp`), ein BME280 auf `0x3C` wäre ohnehin unüblich
  (Standard-Displayadresse), aber grundsätzlich dürfen sich keine
  I2C-Adressen auf dem gemeinsamen Bus überschneiden.
