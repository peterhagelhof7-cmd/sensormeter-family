# BMP280-Sensormodul (Kategorie 1 — Bus-Modul)

Alleinstehender Druck-/Temperatursensor (**keine** Feuchte) — steckt in
die RJ45-Buchse von Sensormeter oder Sensormeter PoE.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [bmp280-verdrahtungsplan.html](bmp280-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Reine Hardware-Vorarbeit — und aktuell **funktional problematisch**, wenn
allein (ohne AHT20 am selben Bus) gesteckt: `SensorDetector.cpp` kennt nur
die Adressen 0x76/0x77 und beschriftet jeden Treffer dort pauschal als
„BME280" (reine Adress-Prüfung, kein Chip-ID-Check). `SensorManager`
versucht daraufhin, es per `Adafruit_BME280`-Bibliothek als echtes BME280
auszulesen. Deren `begin()` prüft aber das Chip-ID-Register (BME280 =
0x60, BMP280 = 0x58) und schlägt bei einem echten BMP280 sauber fehl —
Ergebnis: Log-Eintrag „BME280 (0x76) nicht erreichbar", **keine** falschen
Messwerte, aber Sensor 2 bleibt dauerhaft leer, obwohl ein funktionierender
Chip steckt. Siehe `README.md`, Abschnitt „Firmware-Lücke".

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen | Modul ist das letzte/einzige am Gerät |

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-1-Modul: Pin 1/2/3/4 als echter Bus-Abgriff, gleichzeitig zur
OUT-Buchse durchgereicht. Pin 5/6/7/8 irrelevant, 1:1 durchgeschleift.
Nur der I2C-Betrieb ist vorgesehen — die SPI-Fähigkeit des Chips (CSB als
echter Chip-Select, SDO als MISO) wird hier nicht genutzt.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Board VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | Board GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | Board SCL (Bus-Abgriff) | bleibt live (= IN Pin 3) |
| 4 | SDA | Board SDA (Bus-Abgriff) | bleibt live (= IN Pin 4) |
| 5 | Einzelpin A (DHT/Kontakt) | unbenutzt | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | unbenutzt | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | unbenutzt | durchgeschleift (= IN Pin 7) |
| 8 | 5V | unbenutzt | durchgeschleift (= IN Pin 8) |

Board-Pins CSB und SDO (I2C-Modus): CSB fest auf VCC (HIGH) legen — sonst
schaltet der Chip in den SPI-Modus. SDO legt das letzte Adressbit fest:
auf GND → 0x76, auf VCC → 0x77.

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male), direkt zum
Board verdrahtet. Nur 4 Adern (Pin 1/2/3/4); CSB/SDO fest auf dem Board
verdrahtet.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | Board VCC |
| 2 | GND | Board GND |
| 3 | SCL | Board SCL |
| 4 | SDA | Board SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BMP280-Breakout (I2C/SPI, 6-Pin: VCC/GND/SCL/SDA/CSB/SDO) | 1 | CSB fest auf VCC (I2C-Modus), SDO legt 0x76/0x77 fest |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. Vormodul |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul — Pin 3/4 bleiben live |
| Platinenverdrahtung IN↔OUT | 1 Satz | Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff |
| Litze zum Breakout | 4-adrig | + CSB-Bruecke auf dem Modul-PCB nach VCC |
| Gehäuse | 1 | optional |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BMP280-Breakout | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | kein Zwischenstecker |
| Gehäuse | 1 | optional |

## Verdrahtungstabelle

| Board-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| GND | 2 | GND |
| SCL | 3 | I2C-Takt |
| SDA | 4 | I2C-Daten |
| CSB | — | auf dem Board fest auf VCC gebrückt (I2C-Modus), nicht zur RJ45-Buchse geführt |
| SDO | — | auf dem Board fest auf GND oder VCC gelegt (Adresswahl), nicht zur RJ45-Buchse geführt |

## Bekannte Einschränkungen

- **Fälschliche Erkennung als „BME280"**: reiner Adress-Scan ohne
  Chip-ID-Prüfung in `SensorDetector`. Praktische Folge: sauberer
  Fehlschlag beim Auslesen (`Adafruit_BME280::begin()` prüft die Chip-ID
  selbst), keine falschen Werte — aber Sensor 2 bleibt leer. Braucht eine
  echte Chip-ID-Unterscheidung in der Firmware, um korrekt erkannt zu
  werden (siehe `README.md` „Firmware-Lücke").
- **Kein eigener Datentyp „Druck"** in DataManager/SNMP/MQTT/Web-UI/CSV.
- **Keine Feuchte** — anders als BME280/AHT20/AHT21 liefert dieser Chip
  nur Temperatur und Druck.
- **Adresskollision möglich** mit dem [AHT20+BMP280-Kombimodul](aht20-bmp280-modul.md),
  falls dessen BMP280-Teil zufällig dieselbe SDO-Adresse hat und beide
  gleichzeitig am Bus hängen — in der Praxis unerheblich, siehe dortiges
  Modul-Dokument (Scan-Vorrang von AHT20).
