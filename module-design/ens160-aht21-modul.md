# ENS160+AHT21-Kombimodul (Kategorie 1 — Bus-Modul)

Kombi-Breakout mit zwei separaten I2C-Chips auf einer Platine: ENS160
(Luftgüte: eCO2/TVOC/AQI) und AHT21 (Temperatur/Feuchte, elektrisch
identisch zu AHT20) — steckt in die RJ45-Buchse von Sensormeter oder
Sensormeter PoE.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [ens160-aht21-verdrahtungsplan.html](ens160-aht21-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Genau ein gemeinsamer I2C-Anschluss für beide Chips — kein separates
Zugreifen auf nur einen der beiden möglich.

**Nur der AHT21-Teil ist heute nutzbar:** analog zum
[AHT20+BMP280-Kombimodul](aht20-bmp280-modul.md) gewinnt AHT21 (fest
0x38) den Adress-Scan immer vor ENS160 (typisch 0x52/0x53, per ADD-Pin
wählbar) — `SensorDetector` erkennt „AHT20/AHT21" zuverlässig,
`SensorManager` liest Temperatur+Feuchte. Der ENS160-Teil (Luftgüte)
bleibt für die Firmware unerreichbar, solange AHT21 mitgesteckt ist —
und ist zusätzlich aktuell **gar nicht** in `SensorDetector`s
KNOWN_CHIPS-Tabelle eingetragen, würde also selbst alleinstehend nur als
„unbekanntes I2C-Gerät" erkannt. Siehe `README.md`, Abschnitt
„Firmware-Lücke".

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
Nur der I2C-Betrieb ist vorgesehen (Board unterstützt zusätzlich SPI,
hier ungenutzt).

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Board 3V3 | durchgeschleift (= IN Pin 1) |
| 2 | GND | Board GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | Board SCL (Bus-Abgriff) | bleibt live (= IN Pin 3) |
| 4 | SDA | Board SDA (Bus-Abgriff) | bleibt live (= IN Pin 4) |
| 5 | Einzelpin A (DHT/Kontakt) | unbenutzt | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | unbenutzt | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | unbenutzt | durchgeschleift (= IN Pin 7) |
| 8 | 5V | unbenutzt | durchgeschleift (= IN Pin 8) |

Board-Pins (8-Pin-Leiste: VIN/3V3/GND/SCL/SDA/ADD/CS/INT): **3V3**-Pin
direkt verwenden (nicht VIN — das Board hat einen eigenen Spannungsregler
für VIN, den 3V3-Pin nutzt man, um genau die vom Gerät gelieferten 3,3V
direkt einzuspeisen). **CS** fest auf 3V3 (HIGH) legen — sonst SPI-Modus.
**ADD** legt die ENS160-Adresse fest (0x52/0x53, boardabhängig). **INT**
unbenutzt (Interrupt-Ausgang, hier nicht verdrahtet, reines Polling).

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male), direkt zum
Board verdrahtet. Nur 4 Adern (Pin 1/2/3/4); CS/ADD fest auf dem Board
verdrahtet, VIN/INT unbenutzt.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | Board 3V3 |
| 2 | GND | Board GND |
| 3 | SCL | Board SCL |
| 4 | SDA | Board SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| ENS160+AHT21-Breakout (I2C/SPI, 8-Pin) | 1 | 3V3-Pin nutzen (nicht VIN), CS auf 3V3 (I2C-Modus) |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. Vormodul |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul — Pin 3/4 bleiben live |
| Platinenverdrahtung IN↔OUT | 1 Satz | Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff |
| Litze zum Breakout | 4-adrig | + CS-Bruecke auf dem Modul-PCB nach 3V3 |
| Gehäuse | 1 | optional |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| ENS160+AHT21-Breakout | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | kein Zwischenstecker |
| Gehäuse | 1 | optional |

## Verdrahtungstabelle

| Board-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| 3V3 | 1 | 3V3 |
| GND | 2 | GND |
| SCL | 3 | I2C-Takt |
| SDA | 4 | I2C-Daten |
| CS | — | auf dem Board fest auf 3V3 gebrückt (I2C-Modus) |
| ADD | — | auf dem Board fest verdrahtet (Adresswahl ENS160) |
| VIN, INT | — | unbenutzt, nicht zur RJ45-Buchse geführt |

## Bekannte Einschränkungen

- **ENS160-Teil (Luftgüte) faktisch nicht nutzbar**, solange AHT21
  mitgesteckt ist — Adress-Scan-Vorrang (0x38 vor 0x52/0x53). Selbst mit
  Firmware-Erweiterung müsste der Scan-Mechanismus angepasst werden
  (mehrere Treffer statt „erster genügt").
- **ENS160 aktuell nicht in `SensorDetector`s KNOWN_CHIPS** — würde auch
  alleinstehend nur als „unbekanntes I2C-Gerät" geloggt, nicht namentlich
  erkannt. Braucht einen neuen Tabelleneintrag.
- **Kein eigener Datentyp „Luftgüte"** (eCO2/TVOC/AQI) in
  DataManager/SNMP/MQTT/Web-UI/CSV.
