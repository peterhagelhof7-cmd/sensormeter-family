# AHT20+BMP280-Kombimodul (Kategorie 1 — Bus-Modul)

Kombi-Breakout mit zwei separaten I2C-Chips auf einer Platine: AHT20
(Temperatur/Feuchte) und BMP280 (Druck+Temperatur, **keine** Feuchte) —
steckt in die RJ45-Buchse von Sensormeter oder Sensormeter PoE und
schaltet den Systemtyp automatisch auf „Sensormeter PRO" bzw.
„Sensormeter PoE PRO" um, sobald erkannt bzw. manuell aktiviert.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [aht20-bmp280-verdrahtungsplan.html](aht20-bmp280-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Beschafftes Board (Aufdruck „AHT20+BMP280 SimpleRobot") mit genau **einem**
gemeinsamen 4-Pin-I2C-Anschluss für beide Chips — kein separates Zugreifen
auf nur einen der beiden Chips möglich, beide hängen fest am selben Bus.

**Wichtig — nur der AHT20-Teil ist heute nutzbar:** `SensorDetector.cpp`
scannt I2C-Adressen aufsteigend und bricht beim ersten Treffer ab. AHT20
liegt fest auf 0x38, BMP280 auf 0x76/0x77 (werksseitig fest, das Board
bricht CSB/SDO nicht heraus) — 0x38 wird immer zuerst gefunden und
gewinnt. Der BMP280-Teil (Druck) ist dadurch für die Firmware faktisch
unsichtbar, solange AHT20 am selben Bus hängt, unabhängig davon, ob der
Chip elektrisch korrekt funktioniert. Siehe `README.md`, Abschnitt
„Firmware-Lücke".

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig, auch Kategorie-2-Pins |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen | Modul ist das letzte/einzige am Gerät |

Für die Firmware sind beide Varianten identisch — der Unterschied ist rein
mechanisch.

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-1-Modul: Pin 1/2/3/4 werden als echter Bus-Abgriff genutzt UND
gleichzeitig zur OUT-Buchse durchgereicht (kein Terminieren, siehe
`README.md`). Pin 5/6/7/8 sind für dieses Modul irrelevant und werden
1:1 durchgeschleift.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Board VDD | durchgeschleift (= IN Pin 1) |
| 2 | GND | Board GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | Board SCL (Bus-Abgriff) | bleibt live (= IN Pin 3) |
| 4 | SDA | Board SDA (Bus-Abgriff) | bleibt live (= IN Pin 4) |
| 5 | Einzelpin A (DHT/Kontakt) | unbenutzt | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | unbenutzt | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | unbenutzt | durchgeschleift (= IN Pin 7) |
| 8 | 5V | unbenutzt | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male), direkt zum
Board verdrahtet. Nur 4 Adern (Pin 1/2/3/4).

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | Board VDD |
| 2 | GND | Board GND |
| 3 | SCL | Board SCL |
| 4 | SDA | Board SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| AHT20+BMP280-Breakout (I2C, 4-Pin) | 1 | AHT20 fest 0x38, BMP280 werksseitig fest 0x76/0x77 (kein SDO-Pin herausgeführt) |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat — vor dem Bestücken prüfen |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. Vormodul |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul — Pin 3/4 bleiben live |
| Platinenverdrahtung IN↔OUT | 1 Satz | Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff |
| Litze zum Breakout | 4-adrig | Länge je nach Einbausituation |
| Gehäuse | 1 | optional, 2 RJ45-Durchbrüche |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| AHT20+BMP280-Breakout (I2C, 4-Pin) | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | kein Zwischenstecker |
| Gehäuse | 1 | optional |

## Verdrahtungstabelle

| Board-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VDD | 1 | 3V3 |
| SDA | 4 | I2C-Daten |
| GND | 2 | GND |
| SCL | 3 | I2C-Takt |

## Bekannte Einschränkungen

- **BMP280-Teil (Druck) faktisch nicht nutzbar**, solange AHT20 mitgesteckt
  ist — Adress-Scan-Vorrang (0x38 < 0x76/0x77), siehe „Zweck" oben und
  `README.md` „Firmware-Lücke". Selbst mit Firmware-Erweiterung müsste der
  Scan-Mechanismus angepasst werden (mehrere Treffer statt „erster
  genügt"), um beide Chips gleichzeitig zu nutzen.
- **BMP280-Adresse nicht wählbar**: dieses konkrete Board bricht CSB/SDO
  nicht auf eigene Pins heraus — die Werksadresse (i.d.R. 0x76) ist fix.
  Kollidiert dadurch potenziell mit einem zusätzlich gesteckten
  eigenständigen [BMP280-Modul](bmp280-modul.md), falls dessen SDO auf
  denselben Wert gelegt wird — in der Praxis ohnehin unerheblich, da der
  BMP280-Teil laut Scan-Vorrang nie erreicht wird.
- **Kein eigener Datentyp „Druck"** in DataManager/SNMP/MQTT/Web-UI/CSV
  (Firmware-Lücke, siehe `README.md`).
