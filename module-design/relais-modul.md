# Relais/Aktor-Modul (Kategorie 2 — Direkt-Modul)

Schaltbarer Aktor („Relais") — steckt in die RJ45-Buchse von Sensormeter
oder Sensormeter PoE. Rein manuell aktivierbar (kein Auto-Erkennungsweg)
und über Weboberfläche, REST-API (`/api/relay`) sowie MQTT schaltbar;
zusätzlich anhand eines Sensor-Schwellenwerts oder des Kontaktzustands
automatisch steuerbar (`RelayManager::loop()`).

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [relais-verdrahtungsplan.html](relais-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Beschafftes Bauteil: Songle SRD-05VDC-SL-C, 1-Kanal-Relaismodul,
Low-Level-Trigger (active LOW). Ansteuerlogik passt 1:1 zu
`RelayManager` — Firmware ist bereits vollständig fertig, keine
Codeänderung nötig.

**Stand 2026-07-15 — Spannungsversorgung auf Pin 8 (5V) umgestellt**: die
frühere Fassung dieses Dokuments zog die Relaisplatinen-VCC von Pin 1
(3,3V). Das beschaffte Modul ist aber ausdrücklich als „05VDC" (5V-Spule)
beschriftet — viele günstige SRD-05VDC-Boards haben zwar eine
3,3V-verträgliche Ansteuerlogik (Optokoppler-Vorstufe), aber eine Spule,
die bei 3,3V nicht zuverlässig zieht/hält. Die RJ45-Pin-8-Entscheidung
(siehe `README.md` bzw. `docs/entscheidungen.md` in `sensormeter/repo`
und `sensormeter-poe/repo`, „RJ45 Pin 8: 5V statt Reserve") nennt „manche
Relais-Spulen" wörtlich als Beispielgrund für die 5V-Schiene auf Pin 8 —
dieses Modul ist der erste tatsächliche Anwendungsfall dafür. **Vor dem
Verbau trotzdem mit Multimeter/Testaufbau verifizieren, ob das konkrete
Exemplar bei 5V zuverlässig schaltet.**

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig, auch Kategorie-1-Pins (3/4) |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung) | Niedriger (nur Kabel + Stecker) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen | Modul ist das letzte/einzige am Gerät, keine Kette geplant |

Beide Varianten sind für die Firmware identisch (dieselben Adern
VCC/GND/CTRL/FB auf denselben Pins) — der Unterschied ist rein
mechanisch.

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-2-Modul, belegt als einziges **zwei** dedizierte Einzelpins
(6 + 7) statt nur einem. Pin 1/2/3/4/5 werden 1:1 von IN nach OUT
durchgeschleift, Pin 6+7 werden auf dem Modul-PCB abgegriffen und auf der
OUT-Buchse **terminiert** — kein zweites Relais-Modul kann dahinter
kollidieren. **Pin 8 (5V) versorgt die Relaisplatine direkt** und wird
zusätzlich durchgeschleift, damit ein weiteres 5V-Modul dahinter
funktioniert.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | unbenutzt | durchgeschleift (= IN Pin 1) |
| 2 | GND | Relaisplatine GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | unbenutzt | durchgeschleift (= IN Pin 3) |
| 4 | SDA | unbenutzt | durchgeschleift (= IN Pin 4) |
| 5 | Einzelpin A (DHT/Kontakt) | unbenutzt | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | Relaisplatine IN (Steuersignal, active LOW) | **terminiert, nicht verbunden** |
| 7 | Relais-Feedback | Relaisplatine Feedback-Kontakt (optional) | **terminiert, nicht verbunden** |
| 8 | 5V | Relaisplatine VCC | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zur Relaisplatine verdrahtet.
**Minimalausführung: nur 3 Adern (Pin 2/6/8)** — Feedback (Pin 7) ist ein
rein optionaler 4. Draht.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 2 | GND | Relaisplatine GND |
| 6 | Relais-Steuerung | Relaisplatine IN (active LOW) |
| 7 *(optional)* | Relais-Feedback | Relaisplatine Feedback-Kontakt — nur verdrahten, falls vorhanden |
| 8 | 5V | Relaisplatine VCC |
| 1, 3, 4, 5 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| Relaismodul, Low-Level-Trigger, 5V-Spule (Songle SRD-05VDC-SL-C o. ä.) | 1 | Ansteuerung active LOW passend zu `RelayManager` — kein Pegelwandler nötig |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul in der Kette, Pin 6+7 hier terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/3/4/5/8) | 1 Satz | Durchschleifung auf dem Modul-PCB |
| Litze zur Relaisplatine, 3-adrig (VCC/GND/CTRL) | 1 Satz | VCC jetzt von Pin 8 (5V), nicht Pin 1 |
| Zusätzliche Ader für Feedback (optional) | 0–1 | nur falls die Relaisplatine einen Feedback-Kontakt bietet |
| Gehäuse (optional) | 1 | beachte Schaltspannung/-strom auf der Lastseite |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| Relaismodul, Low-Level-Trigger, 5V-Spule | 1 | wie Standard |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 3-adrig (VCC/GND/CTRL), mit Stecker vergossen/gecrimpt | 1 | VCC jetzt von Pin 8 (5V), nicht Pin 1 |
| Zusätzliche Ader für Feedback (optional) | 0–1 | nur falls genutzt |
| Gehäuse (optional) | 1 | Lastseite trotzdem sicher isolieren |

## Verdrahtungstabelle

| Relaisplatine-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 8 | 5V |
| GND | 2 | GND |
| IN (Steuersignal) | 6 | Relais-Steuerung, active LOW |
| Feedback-Kontakt *(optional)* | 7 | Relais-Feedback |

Bei der Standard-Variante werden alle übrigen Pins (1/2/3/4/5) zusätzlich
1:1 auf die OUT-Buchse durchverdrahtet, Pin 8 (5V) ebenfalls durchgeschleift
— nur Pin 6/7 enden auf der Relaisplatine und werden nicht weitergeführt.

## Hinweis zur Ansteuerung

`RelayManager` treibt Pin 6 **active LOW** (LOW = Relais eingeschaltet,
HIGH = ausgeschaltet — sicherer Boot-Default). Ein handelsübliches
Low-Level-Trigger-Relaismodul (fast alle Songle-Boards mit
Optokoppler-Vorstufe) passt direkt, ohne zusätzlichen Pegelwandler oder
Transistor. High-Level-Trigger-Module (selten, meist explizit
beschriftet) invertieren das Verhalten und dürfen hier **nicht**
verwendet werden.

Das Feedback auf Pin 7 ist **optional** und rein informativ
(`RelayManager::feedbackOn()` hat keinen Einfluss auf den kommandierten
Zustand). Das Gerät aktiviert bereits selbst einen internen Pull-up auf
Pin 7 (`RelayManager::begin()` setzt `INPUT_PULLUP`) — ein externer
Pull-up-Widerstand auf dem Modul ist **nie** nötig.

## Bekannte Einschränkungen

- **Spannung bei diesem konkreten Exemplar nicht verifiziert**: die
  Umstellung von Pin 1 (3,3V) auf Pin 8 (5V) folgt der SRD-05VDC-
  Beschriftung, wurde aber noch nicht an echter Hardware nachgemessen
  (kein Board zum Erstellungszeitpunkt dieses Dokuments final verbaut).
  Vor dem endgültigen Verbau prüfen.
- **Keine Auto-Erkennung möglich**: liefert kein auswertbares Rücksignal
  für `SensorDetector` — Aktivierung erfolgt immer manuell über die
  Einstellungsseite.
- **Zwei Einzelpins statt einem**: belegt Pin 6 UND Pin 7 gleichzeitig —
  weiterhin nur „ein Relais-Modul pro Gerät bzw. Kette" möglich.
- **Durchschleifung (nur Standard)**: Pin 1/2/3/4/5/8 werden zur
  OUT-Buchse weitergereicht, Pin 6/7 werden terminiert — dadurch ist in
  derselben Kette zusätzlich ein Kategorie-1-Modul (I2C) und/oder ein
  DHT/Kontakt-Modul (Pin 5) kombinierbar, aber kein zweites Relais-Modul.
- **Lite hat keine Kettenfähigkeit**.
- **Schaltzustand nicht persistiert**: `RelayManager` startet nach jedem
  Neustart sicherheitshalber immer mit AUS.
- **Automatisches Schalten überschreibt manuelles**: ist
  `relayAutoMode == "sensor"` aktiv, wird ein manuell gesetzter Zustand
  beim nächsten Durchlauf wieder überschrieben.
