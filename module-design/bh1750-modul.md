# BH1750-Sensormodul (Kategorie 1 — Bus-Modul)

Externer I2C-Lichtsensor (Umgebungshelligkeit in Lux) — steckt in die
RJ45-Buchse von Sensormeter oder Sensormeter PoE und wird von
`SensorDetector::runDetection()` beim Boot bzw. auf Anfrage automatisch am
I2C-Bus erkannt (Adresse 0x23/0x5C, bereits in `KNOWN_CHIPS` in
`SensorDetector.cpp` in beiden Firmware-Repos hinterlegt) — setzt „Sensor 2
aktiv" automatisch, genau wie das DHT22- und BME280-Modul. **Wie bei
BME280 liest die Firmware die Messwerte aktuell aber noch nicht aus**
(siehe „Bekannte Einschränkungen") — dieser Entwurf ist bewusst reine
Hardware-Vorarbeit.

Anders als DHT22/BME280/AHT20/21 misst dieses Modul **keine**
Temperatur/Feuchte, sondern Helligkeit — eine echte Ergänzung statt einer
Dopplung bereits vorhandener Messgrößen (siehe Kandidaten-Vergleich in der
Konversation).

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [bh1750-verdrahtungsplan.html](bh1750-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja — echter Bus-Abgriff, Pin 1/2/3/4 bleiben auf der OUT-Buchse ebenfalls live (kein Terminieren, siehe `README.md`) | Nein — Kette endet hier vollständig |
| Weitere I2C-/Kategorie-2-Module danach | Möglich (Multi-Drop-Bus), solange sich I2C-Adressen nicht überschneiden | Nicht möglich |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung) | Niedriger (nur Kabel + Stecker) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren I2C- und/oder Kategorie-2-Modulen stehen | Modul ist das letzte/einzige am Gerät, keine Kette geplant |

Für die Firmware sind beide Varianten identisch (`SensorDetector` liest in
beiden Fällen denselben I2C-Bus) — der Unterschied ist rein mechanisch.
Wie beim BME280-Modul wird bei Standard **nichts terminiert**: Pin 3/4
sind gleichzeitig „genutzt" und „durchgeschleift" (echter Bus, kein
Schalter) — siehe `README.md`, Abschnitt „Durchschleif-Regel".

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-1-Modul: Pin 1/2/5/6/7/8 werden 1:1 von IN nach OUT
durchgeschleift (unverändert, dieses Modul nutzt sie nicht). Pin 3/4
(SCL/SDA) werden auf dem Modul-PCB **abgegriffen und gleichzeitig
weitergereicht** — kein Terminieren, ein weiteres I2C-Modul (oder ein
Kategorie-2-Modul auf Pin 5/6/7) kann dahinterstecken.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | BH1750 VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | BH1750 GND + ADDR (siehe Hinweis) | durchgeschleift (= IN Pin 2) |
| 3 | SCL | BH1750 SCL (Bus-Abgriff) | **ebenfalls live** (= IN Pin 3, kein Terminieren) |
| 4 | SDA | BH1750 SDA (Bus-Abgriff) | **ebenfalls live** (= IN Pin 4, kein Terminieren) |
| 5 | Einzelpin A (DHT/Kontakt) | — (unbenutzt) | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | — (unbenutzt) | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | — (unbenutzt) | durchgeschleift (= IN Pin 7) |
| 8 | Reserve | — (unbenutzt) | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zum BH1750 verdrahtet. Nur Pin 1/2/3/4
werden angeschlossen.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | BH1750 VCC |
| 2 | GND | BH1750 GND + ADDR |
| 3 | SCL | BH1750 SCL |
| 4 | SDA | BH1750 SDA |
| 5, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BH1750-Breakout (I2C, 5-Pin: VCC/GND/SCL/SDA/ADDR) | 1 | ADDR fest auf GND verdrahtet → Adresse 0x23 (Default, siehe Hinweis unten) |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | nur falls der Bus noch keinen Pull-up hat — vor dem Bestücken prüfen |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul in der Kette — Pin 3/4 bleiben live, nichts terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/5/6/7/8 durchschleifen, Pin 3/4 als Bus-Abgriff) | 1 Satz | siehe Pinbelegungstabelle oben |
| Litze zum BH1750-Breakout (4-adrig + ADDR-Brücke auf GND) | nach Bedarf | Länge je nach Einbausituation |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse mit 2 RJ45-Durchbrüchen |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| BH1750-Breakout (I2C, 5-Pin) | 1 | wie Standard |
| Pull-up-Widerstände 4,7 kΩ (SCL + SDA) | 0–2 | wie Standard, nur falls nötig |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 4-adrig, mit Stecker vergossen/gecrimpt | 1 | Länge je nach Einbausituation, kein Zwischenstecker |
| Gehäuse (optional) | 1 | kein RJ45-Durchbruch nötig, transparent/lichtdurchlässig über dem Sensor empfohlen |

Spart eine Buchse und die Durchschleif-Verdrahtung, kostet aber die
Kettenfähigkeit vollständig — kein weiteres I2C- oder Kategorie-2-Modul
kann dahinterstecken (siehe „Bekannte Einschränkungen").

## Verdrahtungstabelle

| BH1750-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| GND | 2 | GND |
| SCL | 3 | I2C-Takt |
| SDA | 4 | I2C-Daten |
| ADDR | 2 | fest auf GND (= Adresse 0x23) |

Bei der Standard-Variante werden zusätzlich Pin 1/2/5/6/7/8 1:1 auf die
OUT-Buchse durchverdrahtet, und Pin 3/4 bleiben als echter Bus-Abgriff
**ebenfalls** auf der OUT-Buchse live (kein Terminieren) — siehe
Pinbelegungstabelle oben.

## Hinweis zu Pull-up und I2C-Adresse

**Pull-up**: wie beim BME280-Modul — vor dem Bestücken prüfen, ob der
gemeinsame I2C-Bus (führt zum OLED-Display des Geräts) bereits einen
Pull-up hat, um einen doppelten Pull-up zu vermeiden.

**I2C-Adresse**: der ADDR-Pin des BH1750-Breakouts legt die Adresse fest —
auf GND (bzw. unbeschaltet auf den meisten Breakouts, die einen internen
Pull-down haben) ergibt `0x23`, auf 3V3 gelegt ergibt `0x5C`. Dieses Modul
ist standardmäßig fest auf `0x23` verdrahtet (ADDR → GND). Für ein
**zweites** BH1750-Modul in derselben Kette eine Variante mit ADDR → 3V3
bauen (Adresse `0x5C`), sonst kollidieren beide auf dem Bus. Beide Adressen
sind bereits in `SensorDetector.cpp`s `KNOWN_CHIPS`-Tabelle hinterlegt.

## Bekannte Einschränkungen

- **Erkennt nur den ersten Treffer**: `SensorDetector::runDetection()`
  bricht den I2C-Scan beim ersten gefundenen Gerät ab und setzt „Sensor 2
  aktiv" dafür — ein zweites I2C-Modul in derselben Kette wird nicht
  zusätzlich als eigener Datenpunkt erkannt/ausgelesen (gleiche
  Einschränkung wie beim BME280-Modul).
- **Kein Terminieren auf Pin 3/4 (nur Standard)**: der Bus bleibt auf der
  OUT-Buchse live — ein Fehlstecken (z. B. zwei Module mit derselben
  Adresse) führt zu einer echten Buskollision statt einer offenen
  Leitung. ADDR-Verdrahtung vor dem Verkabeln prüfen.
- **Lite hat keine Kettenfähigkeit**: die Lite-Variante besitzt keine
  OUT-Buchse — dahinter kann weder ein zweites Kategorie-1- noch ein
  Kategorie-2-Modul stecken.
- **Genauigkeit**: ±20 % (typisch, laut Datenblatt) — für eine grobe
  Hell/Dunkel-Unterscheidung bzw. Trendanzeige ausreichend, nicht für
  photometrisch präzise Messungen gedacht.
- **Werte werden aktuell NICHT ausgelesen — nur erkannt**: `SensorManager::
  readExternalSensorIfEnabled()` liest „Sensor 2" ausschließlich per
  DHT-Protokoll auf Pin 5, unabhängig davon, was `SensorDetector` am
  I2C-Bus gefunden hat. Ein erkanntes BH1750 schaltet den Systemtyp zwar
  automatisch auf „PRO" um, der anschließende Leseversuch schlägt aber
  immer fehl, da auf Pin 5 kein DHT-Sensor hängt. Zusätzlich behandelt die
  Firmware „Sensor 2" ohnehin als Temperatur/Feuchte-Paar (SNMP-Zweig
  `.4.x`, MQTT-`sensor`-Discovery mit °C/%) — selbst mit I2C-Lesepfad
  bräuchte ein Lux-Wert vermutlich einen eigenen Datentyp, kein
  Temperatur/Feuchte-Ersatz. Dieses Modul ist damit reine
  Hardware-Vorarbeit — siehe `README.md`, Abschnitt „Firmware-Lücke".
