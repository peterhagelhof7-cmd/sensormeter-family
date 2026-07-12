# Türkontakt-Modul (Kategorie 2 — Direkt-Modul)

Reed-/Magnetkontakt (Tür- oder Fensterkontakt) — steckt in dieselbe
RJ45-Buchse wie das DHT22-Sensormodul (Pin 5, mutual exclusive, siehe
`README.md`). Ausgewertet über `ContactManager` und die Modultyp-Auswahl
„Kontakt" in der Einstellungsseite (Abschnitt „Externe Schnittstelle" →
Kategorie 2), siehe `sensormeter/repo/docs/entscheidungen.md`.

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [tuerkontakt-verdrahtungsplan.html](tuerkontakt-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig, auch Kategorie-1-Pins (3/4) |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung) | Niedriger (nur Kabel + Stecker) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen | Modul ist das letzte/einzige am Gerät, keine Kette geplant |

Beide Varianten sind für die Firmware identisch (dieselben Adern
VCC/GND/DATA auf denselben Pins wie das DHT22-Modul) — der Unterschied
ist rein mechanisch.

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-2-Modul mit **zwei** RJ45-Buchsen (IN + OUT). Pin 1/2/3/4/8
werden 1:1 von IN nach OUT durchgeschleift, Pin 5 wird auf dem Modul-PCB
abgegriffen und auf der OUT-Buchse **terminiert** — so kann in derselben
Kette kein zweites Pin-5-Modul (z. B. ein DHT22) versehentlich
dahinterhängen. Pin 6/7 (Relais) sind für dieses Modul irrelevant und
werden ebenfalls einfach durchgeschleift.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Pull-up-Widerstand (oberes Ende) | durchgeschleift (= IN Pin 1) |
| 2 | GND | Reed-Kontakt (Anschluss B) | durchgeschleift (= IN Pin 2) |
| 3 | SCL | — (unbenutzt) | durchgeschleift (= IN Pin 3) |
| 4 | SDA | — (unbenutzt) | durchgeschleift (= IN Pin 4) |
| 5 | Einzelpin A (Kontakt-Data) | Pull-up (unteres Ende) + Reed-Kontakt (Anschluss A) | **terminiert, nicht verbunden** |
| 6 | Relais-Steuerung | — (unbenutzt) | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | — (unbenutzt) | durchgeschleift (= IN Pin 7) |
| 8 | Reserve | — (unbenutzt) | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zum Reed-Kontakt verdrahtet. Nur Pin
1/2/5 werden überhaupt angeschlossen.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 1 | 3V3 | Pull-up-Widerstand (oberes Ende) |
| 2 | GND | Reed-Kontakt (Anschluss B) |
| 5 | Einzelpin A (Kontakt-Data) | Pull-up (unteres Ende) + Reed-Kontakt (Anschluss A) |
| 3, 4, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| Reed-/Magnetkontakt (2-Draht, potentialfrei) | 1 | z. B. handelsüblicher Alarmanlagen-Türkontakt |
| Pull-up-Widerstand 4,7 kΩ | 1 | auf dem Modul, nicht am Gerät — siehe Hinweis unten |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. vorherigen Modul in der Kette |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul in der Kette, Pin 5 hier terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/3/4/6/7/8) | 1 Satz | Durchschleifung auf dem Modul-PCB, siehe Tabelle oben |
| Kabel zum Reed-Kontakt (2-adrig) | nach Bedarf | Länge je nach Einbausituation (Türrahmen ↔ Modul) |
| Gehäuse (optional) | 1 | z. B. kleines 3D-gedrucktes Gehäuse mit 2 RJ45-Durchbrüchen |

### Lite-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| Reed-/Magnetkontakt (2-Draht, potentialfrei) | 1 | wie Standard |
| Pull-up-Widerstand 4,7 kΩ | 1 | wie Standard |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 2-adrig zzgl. Zuleitung zum Stecker, mit Stecker vergossen/gecrimpt | 1 | kein Zwischenstecker |
| Gehäuse (optional) | 1 | kein RJ45-Durchbruch nötig |

Spart eine Buchse und die Durchschleif-Verdrahtung, kostet aber die
Kettenfähigkeit vollständig — auch für ein Kategorie-1-Modul, das sonst
hinter diesem Modul stecken könnte (siehe „Bekannte Einschränkungen").

## Verdrahtungstabelle

| Bauteil-Anschluss | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| Pull-up 4,7 kΩ, oberes Ende | 1 | 3V3 |
| Pull-up 4,7 kΩ, unteres Ende + Reed-Kontakt Anschluss A | 5 | Einzelpin A (Kontakt-Data) |
| Reed-Kontakt Anschluss B | 2 | GND |

Der Pull-up hält Pin 5 im Ruhezustand (Kontakt offen) auf HIGH; schließt
der Reed-Kontakt (Tür/Fenster zu), wird Pin 5 nach GND gezogen (LOW) —
`ContactManager::isClosed()` liest genau dieses LOW als „geschlossen".
Bei der Standard-Variante werden alle übrigen Pins (1/2/3/4/6/7/8)
zusätzlich 1:1 auf die OUT-Buchse durchverdrahtet — nur Pin 5 endet am
Reed-Kontakt.

## Hinweis zum Pull-up-Widerstand

Anders als beim DHT22-Modul bringt ein Reed-Kontakt selbst **keinen**
Pull-up mit (er ist ein reiner potentialfreier Schalter) — der
4,7-kΩ-Widerstand muss auf diesem Modul **immer** ergänzt werden, sonst
liegt Pin 5 bei offenem Kontakt in der Luft (undefinierter Pegel, keine
zuverlässige Erkennung). Denselben Widerstandswert wie beim DHT22-Modul
verwenden, damit sich beide Modultypen am selben Steckplatz identisch
verhalten (siehe „Bekannte Einschränkungen" im DHT22-Modul-Dokument zum
Vermeiden doppelter Pull-ups, falls versehentlich beide gleichzeitig
bestückt würden — was durch die gegenseitige Ausschlussregel ohnehin nicht
vorgesehen ist).

## Bekannte Einschränkungen

- **Schließt sich mit dem DHT22-Sensormodul gegenseitig aus** (beide auf
  Pin 5, ein Steckplatz gleichzeitig, elektrisch identische
  Pull-up-Topologie) — siehe `README.md`.
- **Auto-Erkennung nur bei geschlossenem Kontakt zuverlässig**:
  `SensorDetector::runDetection()` probiert bei fehlgeschlagenem I2C-Scan
  einen DHT-Leseversuch auf Pin 5 — das betrifft dieses Modul nicht direkt
  (Modultyp wird rein manuell auf „Kontakt" gestellt, siehe
  `sensormeter/repo/docs/entscheidungen.md`), aber ein offener Kontakt ist
  elektrisch nicht von „kein Modul gesteckt" unterscheidbar (beide HIGH
  über den Pull-up) — daher grundsätzlich keine verlässliche
  Auto-Erkennung für dieses Modul möglich, die Modultyp-Wahl bleibt
  bewusst manuell.
- **Durchschleifung (nur Standard)**: Pin 1/2/3/4/6/7/8 werden zur
  OUT-Buchse weitergereicht, Pin 5 wird terminiert — dadurch ist in
  derselben Kette zusätzlich ein Kategorie-1-Modul (I2C) und/oder ein
  Relais-Modul (Pin 6+7) kombinierbar, aber kein zweites Pin-5-Modul
  (siehe `README.md`, Abschnitt „Durchschleif-Regel"). Empfohlene
  Kettenlänge: maximal 1 Kategorie-1- + 1 Kategorie-2-Modul.
- **Lite hat keine Kettenfähigkeit**: die Lite-Variante besitzt keine
  OUT-Buchse — dahinter kann weder ein zweites Kategorie-2- noch ein
  Kategorie-1-Modul stecken.
- **Kein eigener MQTT-/SNMP-Datenpfad** (Stand `sensormeter/repo/docs/
  entscheidungen.md` „Türkontakt auf RJ45 Pin 5"): der Kontaktzustand ist
  aktuell nur über Weboberfläche/REST-API (`/api/contact`) und das lokale
  Ereignisprotokoll sichtbar, ein binärer Zustand passt nicht in das
  Temperatur/Feuchte-Schema von Sensor 2. Betrifft nur die Firmware, nicht
  diesen Hardware-Entwurf.
