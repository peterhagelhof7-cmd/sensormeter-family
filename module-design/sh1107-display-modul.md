# Externes Display-Modul (SH1107) — Kategorie 1, aber kein Sensor

1,5″-OLED (128×128, SH1107-Controller) — steckt in die RJ45-Buchse von
Sensormeter oder Sensormeter PoE und spiegelt dieselben rotierenden
Infoseiten wie das interne Display, nur auf größerer Fläche.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [sh1107-display-verdrahtungsplan.html](sh1107-display-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Familienweite Entscheidung: alle Sensormeter-Geräte außer Sensormeter
Display nutzen intern künftig dasselbe kleine SSD1306 (0,96″, 128×64) —
das größere SH1107 (vorher bei Sensormeter PoE intern verbaut) steht
seither nur noch als optionales **externes** RJ45-Steckmodul zur
Verfügung. Elektrisch ein normales Kategorie-1-Bus-Modul (Pin 1/2/3/4),
aber kein Sensor — läuft auf `0x3D` statt `0x3C` (interne Displayadresse
ist belegt) und liefert keinen Messwert für „Sensor 2", sondern zeigt
dieselben rotierenden Infoseiten (Systemname, IPs, Uhrzeit, Sensorwerte,
Status, WLAN-Signal, optional Branding) wie das interne Display, nur
größer — eigene, unabhängige Zeitbasis (`ExternalDisplayManager`), keine
Boot-Countdown-Seite und keine Fallback-AP-Sonderseite (die bleiben Aufgabe
des internen Displays).

**Bereits in Firmware umgesetzt** (anders als alle anderen Module dieser
Liste): `ExternalDisplayManager` in sensormeter/repo und
sensormeter-poe/repo, inklusive konfigurierbarer Slide-Seitenauswahl und
Slide-Dauer über die Weboberfläche.

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

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Display VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | Display GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | Display SCL (Bus-Abgriff) | bleibt live (= IN Pin 3) |
| 4 | SDA | Display SDA (Bus-Abgriff) | bleibt live (= IN Pin 4) |
| 5 | Einzelpin A (DHT/Kontakt) | unbenutzt | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | unbenutzt | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | unbenutzt | durchgeschleift (= IN Pin 7) |
| 8 | 5V | unbenutzt | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male), direkt zum
Display verdrahtet. Nur 4 Adern (Pin 1/2/3/4).

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | Display VCC |
| 2 | GND | Display GND |
| 3 | SCL | Display SCL |
| 4 | SDA | Display SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| SH1107-OLED-Breakout, 1,5″ 128×128 (I2C, 4-Pin) | 1 | Adresse 0x3D fest, kein Adress-Wahlpin am Breakout |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. Vormodul |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul — Pin 3/4 bleiben live |
| Platinenverdrahtung IN↔OUT | 1 Satz | Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff |
| Litze zum Display | 4-adrig | Länge je nach Einbausituation |
| Gehäuse | 1 | empfohlen, Display braucht mechanischen Schutz/Sichtfenster |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| SH1107-OLED-Breakout | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | kein Zwischenstecker |
| Gehäuse | 1 | empfohlen |

## Verdrahtungstabelle

| Display-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| GND | 2 | GND |
| SCL | 3 | I2C-Takt |
| SDA | 4 | I2C-Daten |

## Bekannte Einschränkungen

- **Kein Boot-Countdown, keine Fallback-AP-Sonderseite** — diese bleiben
  an den Boot-/Reset-Ablauf gebunden und Aufgabe des internen Displays;
  das externe Modul ist reine Zusatzanzeige für den Normalbetrieb.
- **Logo auf der Branding-Seite nicht dargestellt**: das gespeicherte
  Anbieter-Logo ist für das interne SSD1306 (128×64) formatiert — auf dem
  128×128 großen externen Display würde dasselbe Bitmap verzerrt
  dargestellt. Nur der Vendor-Name als Text erscheint, kein Logo-Bitmap.
  Ein eigenes 128×128-Logoformat ist (noch) nicht umgesetzt.
- **Adresskollision ausgeschlossen** mit anderen I2C-Sensor-Modulen dieser
  Liste (0x3D liegt außerhalb aller verwendeten Sensor-Adressbereiche) —
  aber wie bei jedem I2C-Modul: kein zweites Display-Modul gleichzeitig
  sinnvoll (identische Adresse).
