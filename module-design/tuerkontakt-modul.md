# Türkontakt-Modul (Mikroschalter, Kategorie 2 — Direkt-Modul)

Mechanischer Endschalter/Mikroschalter mit Rollenhebel (SPDT, COM/NO/NC) —
steckt in dieselbe RJ45-Buchse wie DHT11/DHT21 (Pin 5, mutual exclusive,
siehe `README.md`). Ausgewertet über `ContactManager` und die
Modultyp-Auswahl „Kontakt" in der Einstellungsseite (Abschnitt „Externe
Schnittstelle" → Kategorie 2).

**Kompatible Geräte:** Sensormeter (WT32-ETH01), Sensormeter PoE
(ESP32-S3-ETH). Nicht relevant für Sensormeter WLAN/Display (kein
RJ45-Modularanschluss).

**Interaktiver Verdrahtungsplan:** [tuerkontakt-verdrahtungsplan.html](tuerkontakt-verdrahtungsplan.html)
(Standard- und Lite-Variante, anklickbare Drähte).

## Zweck

Beschafftes Bauteil: ein mechanischer Mikroschalter mit Rollenhebel
(Aufdruck „5A 125V~ 10T85", CE-gekennzeichnet, 3 Anschlüsse COM/NO/NC) —
**kein** Reed-/Magnetkontakt. Braucht direkten mechanischen Kontakt/Druck
auf den Hebel (z. B. durch die Türkante selbst oder eine Nocke), keinen
Magneten wie ein klassischer Alarmanlagen-Türkontakt.

Elektrisch/logisch trotzdem voll kompatibel: `ContactManager` erwartet nur
einen simplen potentialfreien Schalter zwischen Pin 5 und Pin 2 (GND),
unabhängig vom Auslösemechanismus — es werden nur **zwei** der drei
Anschlüsse verwendet.

**Polarität beachten**: `ContactManager`/Web-UI erwarten „Tür/Fenster zu"
= Kontakt geschlossen = Pin 5 auf LOW. Dafür **COM + NO** verwenden (nicht
COM + NC): der Schalter ist offen (Pin 5 bleibt HIGH über den Pull-up),
solange der Hebel nicht gedrückt ist (Tür offen), und schließt (Pin 5 →
LOW), sobald der Hebel gedrückt wird (Tür zu, Hebel wird von der
Türkante/Nocke betätigt). COM+NC würde die Logik invertieren.

## Varianten

| | Standard | Lite |
|---|---|---|
| Buchsen | 2 (IN + OUT) | 0 — fest angeschlagenes Kabel mit RJ45-**Stecker** (male) |
| Adern | 3 (VCC/GND/DATA), externer Pull-up auf dem Modul | **2 (nur GND/DATA)**, kein Pull-up auf dem Modul |
| Pull-up | Extern, 4,7 kΩ auf dem Modul-PCB | Keiner — nutzt den internen ESP32-Pull-up (`ContactManager::begin()` setzt `INPUT_PULLUP`) |
| Kabellänge/Schirmung | Kein dokumentiertes Limit | **Richtwert max. 3 m, geschirmtes Kabel** (Störfestigkeit, kein Timing-Limit) |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig, auch Kategorie-1-Pins (3/4) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen, oder längere/exponierte Kabelwege | Kurze, saubere Kabelführung, letztes/einziges Modul am Gerät |

Für die Firmware sind beide Varianten identisch (`ContactManager` liest in
beiden Fällen denselben Pin 5 als LOW-aktiv) — der Unterschied ist
elektrisch (Pull-up-Quelle) und mechanisch (Buchsen/Kettenfähigkeit).

## Pinbelegung des Modul-Steckers

### Standard (2 Buchsen)

Kategorie-2-Modul: Pin 1/2/3/4/8 werden 1:1 von IN nach OUT
durchgeschleift, Pin 5 wird auf dem Modul-PCB abgegriffen und auf der
OUT-Buchse **terminiert** — so kann in derselben Kette kein zweites
Pin-5-Modul (DHT11/DHT21) versehentlich dahinterhängen. Pin 6/7 (Relais)
sind für dieses Modul irrelevant und werden ebenfalls durchgeschleift.

| RJ45-Pin | Signal | IN-Buchse | OUT-Buchse |
|---|---|---|---|
| 1 | 3V3 | Pull-up-Widerstand (oberes Ende) | durchgeschleift (= IN Pin 1) |
| 2 | GND | Mikroschalter COM | durchgeschleift (= IN Pin 2) |
| 3 | SCL | unbenutzt | durchgeschleift (= IN Pin 3) |
| 4 | SDA | unbenutzt | durchgeschleift (= IN Pin 4) |
| 5 | Einzelpin A (Kontakt-Data) | Pull-up (unteres Ende) + Mikroschalter NO | **terminiert, nicht verbunden** |
| 6 | Relais-Steuerung | unbenutzt | durchgeschleift (= IN Pin 6) |
| 7 | Relais-Feedback | unbenutzt | durchgeschleift (= IN Pin 7) |
| 8 | 5V | unbenutzt | durchgeschleift (= IN Pin 8) |

### Lite (1 Kabel mit Stecker, 2-Draht)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male), direkt zum
Mikroschalter verdrahtet. Nur Pin 2/5 werden angeschlossen — **kein
Pull-up, kein Pin 1 (3V3)** nötig, da `ContactManager::begin()` bereits
`INPUT_PULLUP` auf dem Gerät aktiviert.

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 2 | GND | Mikroschalter COM |
| 5 | Einzelpin A (Kontakt-Data) | Mikroschalter NO — Pull-up kommt vom Gerät (intern) |
| 1, 3, 4, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

**Richtwert: max. 3 m Kabellänge, geschirmtes Kabel verwenden** (Schirm auf
GND auflegen) — konservative Empfehlung wegen Störfestigkeit (schwächerer
interner Pull-up), kein durch Signaltiming begründetes Limit.

## Stückliste

### Standard-Variante

| Bauteil | Menge | Hinweis |
|---|---|---|
| Mikroschalter mit Rollenhebel (SPDT, COM/NO/NC, z. B. „5A 125V~") | 1 | nur COM + NO verwenden, NC bleibt unbeschaltet |
| Pull-up-Widerstand 4,7 kΩ | 1 | auf dem Modul, nicht am Gerät |
| RJ45-Buchse, 8P8C (female), IN | 1 | zum Gerät bzw. Vormodul |
| RJ45-Buchse, 8P8C (female), OUT | 1 | zum nächsten Modul, Pin 5 hier terminiert |
| Platinenverdrahtung IN↔OUT (Pin 1/2/3/4/6/7/8) | 1 Satz | Durchschleifung |
| Kabel zum Mikroschalter (2-adrig) | nach Bedarf | Länge je nach Einbausituation (Türrahmen ↔ Modul) |
| Montagewinkel/-halterung für den Rollenhebel | 1 | mechanische Betätigung durch Türkante/Nocke sicherstellen |
| Gehäuse | 1 | optional |

### Lite-Variante (2-Draht)

| Bauteil | Menge | Hinweis |
|---|---|---|
| Mikroschalter mit Rollenhebel | 1 | wie Standard, nur COM + NO |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende |
| Kabel, 2-adrig, **geschirmt**, max. 3 m, mit Stecker vergossen/gecrimpt | 1 | Schirm auf GND (Pin 2) auflegen |
| Montagewinkel/-halterung | 1 | wie Standard |
| Gehäuse | 1 | optional |

Kein Pull-up-Widerstand nötig (Gerät liefert ihn intern) — spart
zusätzlich zur Buchse und Durchschleif-Verdrahtung auch das einzige
Bauteil dieser Variante, kostet dafür die Kettenfähigkeit vollständig.

## Verdrahtungstabelle

### Standard

| Mikroschalter-Anschluss | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| — (Pull-up 4,7 kΩ, oberes Ende) | 1 | 3V3 |
| NO | 5 | Einzelpin A (+ Pull-up-Widerstand unteres Ende) |
| COM | 2 | GND |
| NC | — | nicht angeschlossen |

### Lite

| Mikroschalter-Anschluss | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| NO | 5 | Einzelpin A — Pull-up kommt vom Gerät (intern) |
| COM | 2 | GND |
| NC | — | nicht angeschlossen |

Beide Varianten: der Pull-up (extern bei Standard, intern bei Lite) hält
Pin 5 im Ruhezustand (Hebel nicht gedrückt, Tür/Fenster offen) auf HIGH;
wird der Hebel gedrückt (Tür/Fenster zu), schaltet COM↔NO durch und zieht
Pin 5 nach GND (LOW) — `ContactManager::isClosed()` liest genau dieses LOW
als „geschlossen".

## Bekannte Einschränkungen

- **COM+NO zwingend, nicht COM+NC**: eine Verwechslung invertiert die
  Kontaktlogik (Gerät würde „offen" und „geschlossen" vertauscht melden).
  Vor der Montage mit Multimeter durchmessen, welcher Anschluss NO ist.
- **Mechanische statt magnetische Auslösung**: anders als ein klassischer
  Reed-/Magnetkontakt braucht dieser Schalter direkten physischen Druck
  auf den Rollenhebel — Einbauort/Montage muss das berücksichtigen
  (Hebelweg, Betätigungspunkt durch Türkante oder Nocke).
- **Schließt sich mit DHT11/DHT21 gegenseitig aus** (beide auf Pin 5, ein
  Steckplatz gleichzeitig, elektrisch identische Pull-up-Topologie).
- **Auto-Erkennung nur bei geschlossenem Kontakt zuverlässig**:
  `SensorDetector::runDetection()` probiert bei fehlgeschlagenem I2C-Scan
  einen DHT-Leseversuch auf Pin 5 — betrifft dieses Modul nicht direkt
  (Modultyp wird rein manuell auf „Kontakt" gestellt), aber ein offener
  Kontakt ist elektrisch nicht von „kein Modul gesteckt" unterscheidbar
  (beide HIGH über den Pull-up) — daher grundsätzlich keine verlässliche
  Auto-Erkennung für diese Modulklasse möglich, die Modultyp-Wahl bleibt
  bewusst manuell.
- **Durchschleifung (nur Standard)**: Pin 1/2/3/4/6/7/8 werden zur
  OUT-Buchse weitergereicht, Pin 5 wird terminiert — dadurch ist in
  derselben Kette zusätzlich ein Kategorie-1-Modul (I2C) und/oder ein
  Relais-Modul (Pin 6+7) kombinierbar, aber kein zweites Pin-5-Modul.
- **Lite hat keine Kettenfähigkeit** und ist auf 3 m geschirmtes Kabel
  begrenzt (Richtwert, Störfestigkeit).
- **Kein eigener MQTT-/SNMP-Datenpfad**: der Kontaktzustand ist aktuell
  nur über Weboberfläche/REST-API (`/api/contact`) und das lokale
  Ereignisprotokoll sichtbar — ein binärer Zustand passt nicht in das
  Temperatur/Feuchte-Schema von Sensor 2.
