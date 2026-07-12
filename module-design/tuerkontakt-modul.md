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
| Adern | 3 (VCC/GND/DATA), externer Pull-up auf dem Modul | **2 (nur GND/DATA)**, kein Pull-up auf dem Modul |
| Pull-up | Extern, 4,7 kΩ auf dem Modul-PCB | Keiner — nutzt den internen ESP32-Pull-up (`ContactManager::begin()` setzt `INPUT_PULLUP`) |
| Kabellänge/Schirmung | Kein dokumentiertes Limit (starker externer Pull-up gibt deutlich mehr Störreserve) | **Richtwert max. 3 m, geschirmtes Kabel** — konservative Empfehlung, kein berechneter Grenzwert, siehe Hinweis unten |
| Durchschleifen | Ja, siehe `README.md` „Durchschleif-Regel" | Nein — Kette endet hier vollständig, auch Kategorie-1-Pins (3/4) |
| Preis/Aufwand | Höher (2. Buchse + Durchschleif-Verdrahtung + Widerstand) | Niedriger (nur 2-adriges Kabel + Stecker, kein Bauteil) |
| Einsatzzweck | Modul soll in einer Kette mit weiteren Modulen stehen, oder längere/exponierte Kabelwege | Kurze, saubere Kabelführung, letztes/einziges Modul am Gerät |

Für die Firmware sind beide Varianten identisch (`ContactManager` liest in
beiden Fällen denselben Pin 5 als LOW-aktiv) — der Unterschied ist
elektrisch (Pull-up-Quelle) und mechanisch (Buchsen/Kettenfähigkeit).

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

### Lite (1 Kabel mit Stecker, 2-Draht)

Kein IN/OUT mehr — ein einzelner RJ45-**Stecker** (male) am Ende eines
fest angeschlagenen Kabels, direkt zum Reed-Kontakt verdrahtet. Nur Pin
2/5 werden angeschlossen — **kein Pull-up, kein Pin 1 (3V3)** nötig, da
`ContactManager::begin()` bereits `INPUT_PULLUP` auf dem Gerät aktiviert
(anders als beim DHT22-Modul, dessen Protokoll einen echten externen
Pull-up braucht — ein simpler mechanischer Kontakt nicht).

| RJ45-Pin | Signal | Verbunden mit |
|---|---|---|
| 2 | GND | Reed-Kontakt (Anschluss B) |
| 5 | Einzelpin A (Kontakt-Data) | Reed-Kontakt (Anschluss A) — Pull-up kommt vom Gerät (intern) |
| 1, 3, 4, 6, 7, 8 | — | nicht angeschlossen (n.c.) |

**Richtwert: max. 3 m Kabellänge, geschirmtes Kabel verwenden** (Schirm
auf GND auflegen). Kein durch Signaltiming begründetes Limit — die
RC-Einschwingzeit des internen Pull-ups gegen die Kabelkapazität liegt
selbst bei deutlich über 3 m noch weit unterhalb der ~50-ms-Abfragerate
von `ContactManager::loop()` und ist damit irrelevant. Der eigentliche
Grund ist **Störfestigkeit**: der interne ESP32-Pull-up (~45 kΩ) ist
deutlich schwächer als der externe 4,7-kΩ-Widerstand der Standard-Variante
und wird daher leichter durch eingekoppelte Störungen (Netzbrumm,
Schaltnetzteile) oder Leckströme (Feuchtigkeit/Staub auf der
Kabelisolierung, z. B. bei einem Außenkontakt) verfälscht. 3 m ist ein
konservativer Richtwert für „kurzes, sauber verlegtes Innenraumkabel",
keine berechnete physikalische Grenze — bei längerer, im Freien liegender
oder neben Netzleitungen verlegter Kabelführung lieber die Standard-
Variante mit externem Pull-up verwenden. Siehe „Bekannte Einschränkungen".

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

### Lite-Variante (2-Draht)

| Bauteil | Menge | Hinweis |
|---|---|---|
| Reed-/Magnetkontakt (2-Draht, potentialfrei) | 1 | wie Standard |
| RJ45-Stecker, 8P8C (male) | 1 | fest am Kabelende, kein Gegenstück am Modul |
| Kabel, 2-adrig, **geschirmt**, max. 3 m, mit Stecker vergossen/gecrimpt | 1 | Schirm auf GND (Pin 2) auflegen, kein Zwischenstecker |
| Gehäuse (optional) | 1 | kein RJ45-Durchbruch nötig |

Kein Pull-up-Widerstand nötig (siehe „Pinbelegung" oben) — spart zusätzlich
zur Buchse und Durchschleif-Verdrahtung auch das einzige Bauteil dieser
Variante. Kostet dafür die Kettenfähigkeit vollständig — auch für ein
Kategorie-1-Modul, das sonst hinter diesem Modul stecken könnte (siehe
„Bekannte Einschränkungen") — und ist auf 3 m geschirmtes Kabel begrenzt.

## Verdrahtungstabelle

### Standard

| Bauteil-Anschluss | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| Pull-up 4,7 kΩ, oberes Ende | 1 | 3V3 |
| Pull-up 4,7 kΩ, unteres Ende + Reed-Kontakt Anschluss A | 5 | Einzelpin A (Kontakt-Data) |
| Reed-Kontakt Anschluss B | 2 | GND |

Alle übrigen Pins (1/2/3/4/6/7/8) werden zusätzlich 1:1 auf die OUT-Buchse
durchverdrahtet — nur Pin 5 endet am Reed-Kontakt.

### Lite

| Bauteil-Anschluss | RJ45-Pin (abgegriffen) | Signal |
|---|---|---|
| Reed-Kontakt Anschluss A | 5 | Einzelpin A (Kontakt-Data) — Pull-up kommt vom Gerät (intern) |
| Reed-Kontakt Anschluss B | 2 | GND |

Beide Varianten: der Pull-up (extern bei Standard, intern bei Lite) hält
Pin 5 im Ruhezustand (Kontakt offen) auf HIGH; schließt der Reed-Kontakt
(Tür/Fenster zu), wird Pin 5 nach GND gezogen (LOW) —
`ContactManager::isClosed()` liest genau dieses LOW als „geschlossen".

## Hinweis zum Pull-up-Widerstand

Anders als beim DHT22-Modul bringt ein Reed-Kontakt selbst **keinen**
Pull-up mit (er ist ein reiner potentialfreier Schalter) — Pin 5 braucht
also in jedem Fall einen Pull-up, sonst liegt er bei offenem Kontakt in
der Luft (undefinierter Pegel, keine zuverlässige Erkennung). Zwei
Quellen dafür, je nach Variante:

- **Standard**: externer 4,7-kΩ-Widerstand auf dem Modul-PCB — derselbe
  Wert wie beim DHT22-Modul, damit sich beide Modultypen am selben
  Steckplatz identisch verhalten (keinen doppelten Pull-up bestücken,
  falls versehentlich beide gleichzeitig vorhanden wären — durch die
  gegenseitige Ausschlussregel ohnehin nicht vorgesehen).
- **Lite**: kein Bauteil auf dem Modul — `ContactManager::begin()`
  aktiviert `INPUT_PULLUP` direkt auf dem Geräte-Pin (~45 kΩ, deutlich
  schwächer als 4,7 kΩ). Für einen simplen mechanischen Kontakt (kein
  zeitkritisches Protokoll wie bei DHT22) elektrisch ausreichend — die
  RC-Einschwingzeit spielt bei jeder realistischen Kabellänge keine Rolle.
  Empfindlicher ist der schwache Pull-up aber gegenüber Störeinkopplung
  und Leckströmen, ein Effekt ohne scharfe Längengrenze. Der Richtwert
  „max. 3 m, geschirmt" (siehe Pinbelegung oben) ist daher eine
  konservative Empfehlung für kurze, saubere Innenraum-Verlegung, keine
  berechnete Grenze.

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
- **Lite: Richtwert max. 3 m, geschirmtes Kabel**: kein durch Signaltiming
  begründetes Limit (die RC-Einschwingzeit ist selbst bei deutlich mehr
  als 3 m irrelevant gegenüber dem ~50-ms-Abfragetakt) — der Grund ist
  Störfestigkeit. Da Lite ohne externen Pull-up auskommt und sich auf den
  schwächeren internen ESP32-Pull-up verlässt (siehe „Hinweis zum
  Pull-up-Widerstand"), ist es empfindlicher gegenüber eingekoppelten
  Störungen und Leckströmen als die Standard-Variante — ein Effekt ohne
  scharfe Längengrenze. 3 m + geschirmtes Kabel (Schirm auf GND) ist daher
  eine konservative Empfehlung für kurze, saubere Innenraumverlegung,
  keine berechnete Grenze — bei längeren oder exponierten Kabelwegen (z. B.
  Außentür, Verlegung entlang von Netzleitungen) die Standard-Variante mit
  externem Pull-up verwenden.
- **Kein eigener MQTT-/SNMP-Datenpfad** (Stand `sensormeter/repo/docs/
  entscheidungen.md` „Türkontakt auf RJ45 Pin 5"): der Kontaktzustand ist
  aktuell nur über Weboberfläche/REST-API (`/api/contact`) und das lokale
  Ereignisprotokoll sichtbar, ein binärer Zustand passt nicht in das
  Temperatur/Feuchte-Schema von Sensor 2. Betrifft nur die Firmware, nicht
  diesen Hardware-Entwurf.
