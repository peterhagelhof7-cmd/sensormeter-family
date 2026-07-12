# Relais/Aktor-Modul (Kategorie 2 — Direkt-Modul)

Schaltbarer Aktor („Relais") — steckt in die RJ45-Buchse von Sensormeter
oder Sensormeter PoE. Rein manuell aktivierbar (kein Auto-Erkennungsweg,
siehe „Bekannte Einschränkungen") und über Weboberfläche, REST-API
(`/api/relay`) sowie MQTT schaltbar; seit der optionalen automatischen
Schaltlogik (`RelayManager::loop()`, siehe `sensormeter/repo/docs/
entscheidungen.md`) auch anhand eines Sensor-Schwellenwerts oder des
Kontaktzustands automatisch steuerbar.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [relais-verdrahtungsplan.html](relais-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

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
(6 + 7) statt nur einem. Pin 1/2/3/4/5/8 werden 1:1 von IN nach OUT
durchgeschleift, Pin 6+7 werden auf dem Modul-PCB abgegriffen und auf der
OUT-Buchse **terminiert** — kein zweites Relais-Modul kann dahinter
kollidieren.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Relaisplatine VCC | durchgeschleift (= IN Pin 1) |
| 2 | GND | Relaisplatine GND | durchgeschleift (= IN Pin 2) |
| 3 | SCL | — (unbenutzt) | durchgeschleift (= IN Pin 3) |
| 4 | SDA | — (unbenutzt) | durchgeschleift (= IN Pin 4) |
| 5 | Einzelpin A (DHT/Kontakt) | — (unbenutzt) | durchgeschleift (= IN Pin 5) |
| 6 | Relais-Steuerung | Relaisplatine IN (Steuersignal, active LOW) | **terminiert, nicht verbunden** |
| 7 | Relais-Feedback | Relaisplatine Feedback-Kontakt (optional) | **terminiert, nicht verbunden** |
| 8 | Reserve | — (unbenutzt) | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zur Relaisplatine verdrahtet.
**Minimalausführung: nur 3 Adern (Pin 1/2/6)** — Feedback (Pin 7) ist ein
rein optionaler 4. Draht, kein Pflichtbestandteil (siehe „Hinweis zur
Ansteuerung").

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | Relaisplatine VCC |
| 2 | GND | Relaisplatine GND |
| 6 | Relais-Steuerung | Relaisplatine IN (active LOW) |
| 7 *(optional)* | Relais-Feedback | Relaisplatine Feedback-Kontakt — nur verdrahten, falls die Relaisplatine einen bietet |
| 3, 4, 5, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| Relaismodul, Low-Level-Trigger (z. B. Songle SRD-05VDC-SL-C mit Treiberplatine) | 1 | Ansteuerung active LOW passend zu `RelayManager` — kein Pegelwandler nötig |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul in der Kette, Pin 6+7 hier terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/3/4/5/8) | 1 Satz | Durchschleifung auf dem Modul-PCB, siehe Tabelle oben |
| Litze zur Relaisplatine, 3-adrig (VCC/GND/CTRL) | 1 Satz | Minimalausführung, Länge je nach Einbausituation |
| Zusätzliche Ader für Feedback (optional) | 0–1 | nur falls die Relaisplatine einen Feedback-Kontakt bietet UND genutzt werden soll |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse mit 2 RJ45-Durchbrüchen, beachte Schaltspannung/-strom auf der Lastseite |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| Relaismodul, Low-Level-Trigger | 1 | wie Standard |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 3-adrig (VCC/GND/CTRL), mit Stecker vergossen/gecrimpt | 1 | Minimalausführung, kein Zwischenstecker |
| Zusätzliche Ader für Feedback (optional) | 0–1 | nur falls genutzt, sonst weglassen — kein Zusatzbauteil am Gerät nötig |
| Gehäuse (optional) | 1 | kein RJ45-Durchbruch nötig, Lastseite trotzdem sicher isolieren |

Spart eine Buchse und die Durchschleif-Verdrahtung, kostet aber die
Kettenfähigkeit vollständig — auch für ein Kategorie-1-Modul, das sonst
hinter diesem Modul stecken könnte (siehe „Bekannte Einschränkungen").

## Verdrahtungstabelle

| Relaisplatine-Pin | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| VCC | 1 | 3V3 |
| GND | 2 | GND |
| IN (Steuersignal) | 6 | Relais-Steuerung, active LOW |
| Feedback-Kontakt *(optional)* | 7 | Relais-Feedback |

Bei der Standard-Variante werden alle übrigen Pins (1/2/3/4/5/8) zusätzlich
1:1 auf die OUT-Buchse durchverdrahtet (siehe Pinbelegungstabelle oben) —
nur Pin 6/7 enden auf der Relaisplatine und werden nicht weitergeführt.

## Hinweis zur Ansteuerung

`RelayManager` treibt Pin 6 **active LOW** (LOW = Relais eingeschaltet,
HIGH = ausgeschaltet — sicherer Boot-Default, da `pinMode(...,OUTPUT);
digitalWrite(...,HIGH);` beim Start noch vor der eigentlichen
Konfiguration läuft). Ein handelsübliches Low-Level-Trigger-Relaismodul
(fast alle 5V/3,3V-Songle-Boards mit Optokoppler-Vorstufe) passt direkt,
ohne zusätzlichen Pegelwandler oder Transistor auf dem Modul selbst.
High-Level-Trigger-Module (selten, meist explizit beschriftet) invertieren
das Verhalten und dürfen hier **nicht** verwendet werden, ohne die
Ansteuerlogik im Modul selbst zu invertieren.

Das Feedback auf Pin 7 ist **optional** und rein informativ
(`RelayManager::feedbackOn()` hat keinen Einfluss auf den kommandierten
Zustand) — viele einfache Relaismodule bieten dafür keinen eigenen
Kontakt; in dem Fall Pin 7 am Modul einfach unbeschaltet lassen. Das
Gerät aktiviert bereits selbst einen internen Pull-up auf Pin 7
(`RelayManager::begin()` setzt `INPUT_PULLUP`) — ein externer
Pull-up-Widerstand auf dem Modul ist **nie** nötig, egal ob Feedback
genutzt wird oder nicht, und zwar bei **beiden** Varianten (anders als
beim [Türkontakt-Modul](tuerkontakt-modul.md), wo nur die Lite-Variante
den internen Pull-up nutzt und die Standard-Variante bewusst einen
externen Widerstand vorsieht). Das Weglassen von Feedback spart daher
wirklich nur die vierte Ader, kein Bauteil.

## Bekannte Einschränkungen

- **Keine Auto-Erkennung möglich**: anders als [DHT22](dht22-modul.md)/I2C-Sensoren
  liefert ein Relaismodul kein auswertbares Rücksignal für
  `SensorDetector` — das Aktivieren erfolgt daher immer manuell über die
  Einstellungsseite („Relais aktiv").
- **Zwei Einzelpins statt einem**: als einziges Kategorie-2-Modul belegt
  dieses Modul zwei dedizierte Pins (6 **und** 7) gleichzeitig — dennoch
  weiterhin nur „ein Relais-Modul pro Gerät bzw. Kette“ möglich, da beide
  Pins fest dem Relais zugeordnet sind.
- **Durchschleifung (nur Standard)**: Pin 1/2/3/4/5/8 werden zur
  OUT-Buchse weitergereicht, Pin 6/7 werden terminiert — dadurch ist in
  derselben Kette zusätzlich ein Kategorie-1-Modul (I2C) und/oder ein
  [DHT22](dht22-modul.md)-/[Kontakt](tuerkontakt-modul.md)-Modul (Pin 5)
  kombinierbar, aber kein zweites Relais-Modul (siehe `README.md`,
  Abschnitt „Durchschleif-Regel").
  Empfohlene Kettenlänge: maximal 1 Kategorie-1- + 1 Kategorie-2-Modul.
- **Lite hat keine Kettenfähigkeit**: die Lite-Variante besitzt keine
  OUT-Buchse — dahinter kann weder ein zweites Kategorie-2- noch ein
  Kategorie-1-Modul stecken.
- **Schaltzustand nicht persistiert**: `RelayManager` startet nach jedem
  Neustart des Geräts sicherheitshalber immer mit AUS — ein wieder
  angelaufenes Gerät reaktiviert einen zuvor eingeschalteten Verbraucher
  nicht stumm. Gilt unabhängig von der Modul-Variante.
- **Automatisches Schalten überschreibt manuelles**: ist die automatische
  Schaltbedingung aktiv (`relayAutoMode == "sensor"`), wird ein manuell
  gesetzter Zustand beim nächsten Durchlauf wieder überschrieben — siehe
  `sensormeter/repo/docs/entscheidungen.md`.
