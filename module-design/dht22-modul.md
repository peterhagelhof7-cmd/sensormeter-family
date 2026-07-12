# DHT22-Sensormodul (Kategorie 2 — Direkt-Modul)

Externer Temperatur-/Feuchte-Sensor („Sensor 2") — steckt in die RJ45-Buchse
von Sensormeter oder Sensormeter PoE und schaltet den Systemtyp automatisch
auf „Sensormeter PRO" bzw. „Sensormeter PoE PRO" um, sobald erkannt bzw.
manuell aktiviert (siehe `SensorDetector`/`ConfigManager` in beiden
Firmware-Repos).

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

## Pinbelegung des Modul-Steckers

Nur Pin 1, 2 und 5 werden genutzt — Kategorie-2-Modul, **eine** RJ45-Buchse,
kein Durchschleifen (siehe `README.md`).

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | DHT22 VCC |
| 2 | GND | DHT22 GND |
| 3 | SCL | — (nicht verbunden) |
| 4 | SDA | — (nicht verbunden) |
| 5 | Einzelpin A (DHT-Data) | DHT22 DATA (+ Pull-up, siehe unten) |
| 6 | Relais-Steuerung | — (nicht verbunden) |
| 7 | Relais-Feedback | — (nicht verbunden) |
| 8 | Reserve | — (nicht verbunden) |

## Stückliste

| Bauteil | Menge | Hinweis |
|---|---|---|
| DHT22 (AM2302), 3-Draht-Breakout | 1 | Temperatur/Feuchte, siehe Pull-up-Hinweis unten |
| Pull-up-Widerstand 4,7 kΩ | 0–1 | nur falls das Breakout keinen eigenen Pull-up mitbringt — siehe Hinweis |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Modulkabel, Gegenstück zur Buchse am Gerät |
| Kabel, 3-adrig (falls Breakout nicht direkt am Stecker sitzt) | nach Bedarf | Länge je nach Einbausituation |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse, je nach Einbausituation |

## Verdrahtungstabelle

| DHT22-Pin | RJ45-Pin | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| DATA | 5 | Einzelpin A (DHT-Data) |
| GND | 2 | GND |
| NC *(nur bei 4-Pin-Rohsensor, nicht bei 3-Pin-Breakout)* | — | nicht verbunden |

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

- **Schließt sich mit einem künftigen Türkontakt-Modul gegenseitig aus**
  (beide auf Pin 5, ein Steckplatz gleichzeitig) — siehe `README.md`.
- **Firmware unterscheidet nicht zwischen DHT11 und DHT22** als Kategorie
  (`SensorDetector` erkennt nur „DHT-Sensor" allgemein, laut Lastenheft
  bewusst so, da eine Unterscheidung unzuverlässig wäre) — für Sensor 2
  wird aber im Lesecode konkret `DHT22` fest verdrahtet
  (`SensorManager`/`SensorDetector`, `dhtProbe(PIN_DHT_EXTERNAL, DHT22)`).
  Ein versehentlich gestecktes DHT11-Modul auf diesem Steckplatz liefert
  falsche oder keine Werte.
- **Kein Durchschleifen** — genau ein Kategorie-2-Modul gleichzeitig
  steckbar (siehe `README.md`, Abschnitt „Kategorie 2").
- **Auto-Erkennung**: `SensorDetector::runDetection()` probiert bei
  fehlgeschlagenem I2C-Scan einen DHT-Leseversuch auf Pin 5 — bei Erfolg
  wird „Sensor 2 aktiv" automatisch gesetzt (ein bereits manuell
  deaktivierter Schalter wird dabei nie stillschweigend wieder aktiviert).
  Kein bekanntes Problem für dieses Modul (anders als beim künftigen
  Türkontakt-Modul, das nur bei geschlossenem Kontakt sicher erkannt wird).
