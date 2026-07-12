# DHT22-Sensormodul (Kategorie 2 — Direkt-Modul)

Externer Temperatur-/Feuchte-Sensor („Sensor 2") — steckt in die RJ45-Buchse
von Sensormeter oder Sensormeter PoE und schaltet den Systemtyp automatisch
auf „Sensormeter PRO" bzw. „Sensormeter PoE PRO" um, sobald erkannt bzw.
manuell aktiviert (siehe `SensorDetector`/`ConfigManager` in beiden
Firmware-Repos).

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [dht22-verdrahtungsplan.html](dht22-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig, auch Kategorie-1-Pins (3/4) |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung) | Niedriger (nur Kabel + Stecker) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen | Modul ist das letzte/einzige am Gerät, keine Kette geplant |

Beide Varianten sind für die Firmware identisch (dieselben drei Adern
VCC/GND/DATA auf denselben Pins) — der Unterschied ist rein mechanisch.

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-2-Modul mit **zwei** RJ45-Buchsen (IN + OUT) gemäß der
Durchschleif-Regel in `README.md`: Pin 1/2/3/4/8 werden 1:1 von IN nach
OUT durchgeschleift, Pin 5 wird auf dem Modul-PCB abgegriffen (DHT22
DATA) und auf der OUT-Buchse **terminiert** (nicht weitergereicht) — so
kann in derselben Kette kein zweites Pin-5-Modul (z. B. ein Türkontakt)
versehentlich dahinterhängen. Pin 6/7 (Relais) sind für dieses Modul
irrelevant und werden ebenfalls einfach durchgeschleift, damit ein
Relais-Modul weiter hinten in der Kette funktioniert.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | DHT22 VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | DHT22 GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | — (unbenutzt) | durchgeschleift (= IN Pin 3) |
| 4 | SDA | — (unbenutzt) | durchgeschleift (= IN Pin 4) |
| 5 | Einzelpin A (DHT-Data) | DHT22 DATA (+ Pull-up, siehe unten) | **terminiert, nicht verbunden** |
| 6 | Relais-Steuerung | — (unbenutzt) | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | — (unbenutzt) | durchgeschleift (= IN Pin 7) |
| 8 | Reserve | — (unbenutzt) | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zum DHT22 verdrahtet. Nur Pin 1/2/5
werden überhaupt angeschlossen, alle anderen Pins bleiben am Stecker
unbeschaltet (n.c.) — es gibt nichts zum Durchschleifen, da keine zweite
Buchse existiert.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | DHT22 VCC |
| 2 | GND | DHT22 GND |
| 5 | Einzelpin A (DHT-Data) | DHT22 DATA (+ Pull-up, siehe unten) |
| 3, 4, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| DHT22 (AM2302), 3-Draht-Breakout | 1 | Temperatur/Feuchte, siehe Pull-up-Hinweis unten |
| Pull-up-Widerstand 4,7 kΩ | 0–1 | nur falls das Breakout keinen eigenen Pull-up mitbringt — siehe Hinweis |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul in der Kette, Pin 5 hier terminiert |
| Kurzes Patchkabel/Platinenverdrahtung IN↔OUT (Pin 1/2/3/4/6/7/8) | 1 Satz | Durchschleifung auf dem Modul-PCB, siehe Tabelle oben |
| Kabel/Stichleitung zum DHT22-Breakout (3-adrig) | nach Bedarf | Länge je nach Einbausituation |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse mit 2 RJ45-Durchbrüchen |

**Steckerkonvention**: analog zu bestehenden Grove-/Ethernet-Ketten
bekommt jedes Standard-Modul zwei **Buchsen** (female), die Verbindung
zwischen Gerät und Modul bzw. zwischen zwei Modulen erfolgt über ein
normales Patchkabel mit Steckern (male) an beiden Enden — damit ist die
Kettenreihenfolge beliebig steckbar.

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| DHT22 (AM2302), 3-Draht-Breakout | 1 | wie Standard |
| Pull-up-Widerstand 4,7 kΩ | 0–1 | wie Standard |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 3-adrig, mit Stecker vergossen/gecrimpt | 1 | Länge je nach Einbausituation, kein Zwischenstecker |
| Schrumpfschlauch/Mini-Gehäuse am Sensor (optional) | 1 | kein RJ45-Durchbruch nötig |

Spart eine Buchse und die Durchschleif-Verdrahtung, kostet aber die
Kettenfähigkeit vollständig — auch für ein Kategorie-1-Modul, das sonst
hinter diesem Modul stecken könnte (siehe „Bekannte Einschränkungen").

## Verdrahtungstabelle

| DHT22-Pin | RJ45-Pin (IN, abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| DATA | 5 | Einzelpin A (DHT-Data) |
| GND | 2 | GND |
| NC *(nur bei 4-Pin-Rohsensor, nicht bei 3-Pin-Breakout)* | — | nicht verbunden |

Alle übrigen Pins (1/2/3/4/6/7/8) werden zusätzlich 1:1 auf die OUT-Buchse
durchverdrahtet (siehe Pinbelegungstabelle oben) — nur Pin 5 endet am
DHT22 und wird nicht weitergeführt.

## Hinweis zum Pull-up-Widerstand

Die meisten fertigen DHT22-Breakout-Boards (3-Pin, kleine blaue PCB) haben
bereits einen eingebauten Pull-up auf DATA. Bei einem nackten 4-Pin-DHT22
(ohne Breakout-PCB) muss der 4,7-kΩ-Pull-up zusätzlich auf dem Modul
ergänzt werden. Vor dem Bau mit einem Multimeter zwischen DATA und VCC
prüfen (sollte ~4,7 kΩ zeigen) — einen doppelten Pull-up vermeiden (Gerät
*und* Modul), das senkt den effektiven Widerstand unnötig (zwei parallele
4,7 kΩ ergeben 2,35 kΩ) und ist unsauber, auch wenn es meist noch
funktioniert.

## Bekannte Einschränkungen

- **Schließt sich mit dem [Türkontakt-Modul](tuerkontakt-modul.md) gegenseitig
  aus** (beide auf Pin 5, ein Steckplatz gleichzeitig) — siehe `README.md`.
- **Firmware unterscheidet nicht zwischen DHT11 und DHT22** als Kategorie
  (`SensorDetector` erkennt nur „DHT-Sensor" allgemein, laut Lastenheft
  bewusst so, da eine Unterscheidung unzuverlässig wäre) — für Sensor 2
  wird aber im Lesecode konkret `DHT22` fest verdrahtet
  (`SensorManager`/`SensorDetector`, `dhtProbe(PIN_DHT_EXTERNAL, DHT22)`).
  Ein versehentlich gestecktes DHT11-Modul auf diesem Steckplatz liefert
  falsche oder keine Werte.
- **Durchschleifung (nur Standard)**: Pin 1/2/3/4/6/7/8 werden zur
  OUT-Buchse weitergereicht, Pin 5 wird terminiert — dadurch ist in
  derselben Kette zusätzlich ein Kategorie-1-Modul (I2C) und/oder ein
  Relais-Modul (Pin 6+7) kombinierbar, aber kein zweites Pin-5-Modul
  (siehe `README.md`, Abschnitt „Durchschleif-Regel"). Empfohlene
  Kettenlänge: maximal 1 Kategorie-1- + 1 Kategorie-2-Modul (siehe
  dortige Begründung zum aufgehobenen GND-Sternpunkt).
- **Lite hat keine Kettenfähigkeit**: die Lite-Variante besitzt keine
  OUT-Buchse — dahinter kann weder ein zweites Kategorie-2- noch ein
  Kategorie-1-Modul stecken. Nur sinnvoll, wenn dieses Modul das letzte
  bzw. einzige am Gerät ist.
- **Auto-Erkennung**: `SensorDetector::runDetection()` probiert bei
  fehlgeschlagenem I2C-Scan einen DHT-Leseversuch auf Pin 5 — aber nur,
  wenn `cfg.pin5Mode == "sensor"` gesetzt ist (Default). Bei Erfolg wird
  „Sensor 2 aktiv" automatisch gesetzt (ein bereits manuell deaktivierter
  Schalter wird dabei nie stillschweigend wieder aktiviert). Kein
  bekanntes Problem für dieses Modul — anders als beim
  [Türkontakt-Modul](tuerkontakt-modul.md), für das aus genau diesem Grund
  (ein offener Kontakt ist elektrisch nicht von „nichts gesteckt"
  unterscheidbar) **keine** Auto-Erkennung existiert, sondern der
  Modultyp „Sensor"/„Kontakt" auf Pin 5 immer manuell gewählt wird.
