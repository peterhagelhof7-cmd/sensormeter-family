# BH1750-Sensormodul (Kategorie 1 — Bus-Modul)

Umgebungslicht-/Lux-Sensor (GY-302-Breakout) — steckt in die RJ45-Buchse
von Sensormeter oder Sensormeter PoE.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [bh1750-verdrahtungsplan.html](bh1750-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Reine Hardware-Vorarbeit: der Chip steht in `SensorDetector.cpp`s
KNOWN_CHIPS-Tabelle und wird beim I2C-Scan zuverlässig als „BH1750"
erkannt — `SensorManager` liest den Messwert (Lux) aber **nicht** aus, da
Helligkeit nicht ins bestehende Temperatur/Feuchte-Datenmodell von
„Sensor 2" passt. Siehe `README.md`, Abschnitt „Firmware-Lücke".

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen | Modul ist das letzte/einzige am Gerät |

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-1-Modul: Pin 1/2/3/4 als echter Bus-Abgriff, gleichzeitig zur
OUT-Buchse durchgereicht (kein Terminieren). Pin 5/6/7/8 irrelevant,
1:1 durchgeschleift.

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

Board-Pin ADDR (5. Pin des GY-302) legt die I2C-Adresse fest: auf GND
(oder offen, interner Pull-down auf vielen Breakouts) → 0x23; auf VCC →
0x5C. Auf dem Modul fest verdrahtet, nicht am Gerät wählbar.

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male), direkt zum
Board verdrahtet. Nur 4 Adern (Pin 1/2/3/4), ADDR fest auf dem Board
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
| BH1750-Breakout, GY-302 (I2C, 5-Pin inkl. ADDR) | 1 | ADDR auf GND oder VCC legen für 0x23/0x5C |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. Vormodul |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul — Pin 3/4 bleiben live |
| Platinenverdrahtung IN↔OUT | 1 Satz | Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff |
| Litze zum Breakout | 4-adrig | Länge je nach Einbausituation |
| Gehäuse | 1 | optional |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BH1750-Breakout, GY-302 | 1 | wie Standard |
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
| ADDR | — | auf dem Board fest auf GND oder VCC gelegt, nicht zur RJ45-Buchse geführt |

## Bekannte Einschränkungen

- **Wird erkannt, aber nicht ausgelesen** (Stand `README.md`
  „Firmware-Lücke") — Lux passt nicht ins bestehende
  Temperatur/Feuchte-Datenmodell, braucht einen eigenen Datentyp quer
  durch DataManager/SNMP/MQTT/Web-UI/CSV.
- **Adresskollision möglich**, falls gleichzeitig ein weiteres Modul mit
  0x23/0x5C am Bus hängt (aktuell kein anderes entworfenes Modul in
  diesem Adressbereich).
