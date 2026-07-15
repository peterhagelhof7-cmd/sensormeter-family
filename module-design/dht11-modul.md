# DHT11-Sensormodul (Kategorie 2 — Direkt-Modul)

Externer Temperatur-/Feuchte-Sensor („Sensor 2") mit geringerer Genauigkeit/
Auflösung als DHT21/DHT22 (nur Ganzzahlwerte) — steckt in die RJ45-Buchse
von Sensormeter oder Sensormeter PoE und schaltet den Systemtyp automatisch
auf „Sensormeter PRO" bzw. „Sensormeter PoE PRO" um, sobald erkannt bzw.
manuell aktiviert.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss). Hinweis: Sensormeter (WT32-ETH01) nutzt intern
bereits ein DHT11 als Sensor 1 (fest verbaut, kein RJ45-Bezug) — dieses
Modul betrifft ausschließlich den externen Sensor-2-Anschluss auf Pin 5.

**Interaktiver Verdrahtungsplan:** [dht11-verdrahtungsplan.html](dht11-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Elektrisch/mechanisch identisch zu einem DHT22/DHT21 auf demselben
Steckplatz — 3 Adern (VCC/GND/DATA), gleiche Pull-up-Topologie. **Braucht
aber eine Firmware-Anpassung**, bevor es korrekt gelesen wird: der externe
Lesepfad ist in `SensorDetector.cpp` (Erkennungs-Leseversuch) und
`SensorManager.cpp` (Sensor-2-Betrieb) aktuell fest auf den Bibliothekstyp
`DHT22` codiert. Ein echtes DHT11 an Pin 5 würde mit falschen
Timing-/Skalierungsannahmen gelesen. Siehe `README.md`, Abschnitt
„Firmware-Lücke".

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig, auch Kategorie-1-Pins (3/4) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen | Modul ist das letzte/einzige am Gerät |

Beide Varianten sind für die Firmware identisch (dieselben drei Adern
VCC/GND/DATA auf denselben Pins) — der Unterschied ist rein mechanisch.

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-2-Modul: Pin 1/2/3/4/8 werden 1:1 von IN nach OUT
durchgeschleift, Pin 5 wird auf dem Modul-PCB abgegriffen (DHT11 DATA)
und auf der OUT-Buchse **terminiert** — so kann in derselben Kette kein
zweites Pin-5-Modul (DHT21, Türkontakt) versehentlich dahinterhängen.
Pin 6/7 (Relais) sind für dieses Modul irrelevant und werden ebenfalls
durchgeschleift.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Pull-up-Widerstand (oberes Ende) + DHT11 VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | DHT11 GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | unbenutzt | durchgeschleift (= IN Pin 3) |
| 4 | SDA | unbenutzt | durchgeschleift (= IN Pin 4) |
| 5 | Einzelpin A (DHT-Data) | Pull-up (unteres Ende) + DHT11 DATA | **terminiert, nicht verbunden** |
| 6 | Relais-Steuerung | unbenutzt | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | unbenutzt | durchgeschleift (= IN Pin 7) |
| 8 | 5V | unbenutzt | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male), direkt zum
DHT11 verdrahtet. Nur 3 Adern (Pin 1/2/5).

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | DHT11 VCC + Pull-up (oberes Ende) |
| 2 | GND | DHT11 GND |
| 5 | Einzelpin A (DHT-Data) | DHT11 DATA + Pull-up (unteres Ende) |
| 3, 4, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

Anders als beim [Türkontakt-Modul](tuerkontakt-modul.md) braucht das
DHT-Protokoll einen echten externen Pull-up — auch die Lite-Variante
kommt daher nicht ohne den Widerstand aus.

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| DHT11-Sensor (3-Pin: VCC/DATA/GND) | 1 | |
| Pull-up-Widerstand 4,7 kΩ | 1 | auf dem Modul, Pin 1 → Pin 5 |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. Vormodul |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul, Pin 5 hier terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/3/4/6/7/8) | 1 Satz | Durchschleifung |
| Kabel zum DHT11 (3-adrig) | nach Bedarf | Länge je nach Einbausituation |
| Gehäuse | 1 | optional |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| DHT11-Sensor | 1 | wie Standard |
| Pull-up-Widerstand 4,7 kΩ | 1 | auf dem Modul (nicht am Gerät, anders als Türkontakt-Lite) |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende |
| Kabel, 3-adrig, mit Stecker vergossen/gecrimpt | 1 | kein Zwischenstecker |
| Gehäuse | 1 | optional |

## Verdrahtungstabelle

| DHT11-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 (+ Pull-up-Widerstand oberes Ende) |
| DATA | 5 | Einzelpin A (+ Pull-up-Widerstand unteres Ende) |
| GND | 2 | GND |

## Bekannte Einschränkungen

- **Firmware liest aktuell mit falscher Typ-Annahme**: `dhtProbe`
  (Erkennung) und `dhtExternal` (Betrieb) sind fest als `DHT22`
  instanziiert — braucht eine Typ-Auswahl (DHT11/DHT21/DHT22), bevor
  dieses Modul korrekte Werte liefert.
- **Geringere Genauigkeit/Auflösung** als DHT21/DHT22 (nur
  Ganzzahlwerte, ±2°C/±5%RH typisch) — für Anwendungen mit höheren
  Genauigkeitsanforderungen [DHT21](dht21-modul.md) bevorzugen.
- **Schließt sich mit DHT21/Türkontakt gegenseitig aus** (alle auf Pin 5,
  ein Steckplatz gleichzeitig).
