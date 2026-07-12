# RJ45-Steckmodule — Entwurfsübersicht

Zentrale Ablage für die Hardware-Entwürfe der über den RJ45-Modularanschluss
steckbaren Erweiterungsmodule. Betrifft nur **Sensormeter** (WT32-ETH01)
und **Sensormeter PoE** (ESP32-S3-ETH) — beide haben eine RJ45-Buchse mit
identischem Pin-**Rollen**-Schema (siehe unten), die konkreten GPIO-Nummern
auf der jeweiligen Geräteseite unterscheiden sich zwangsläufig (anderer
Chip). Steckmodule sind dadurch zwischen beiden Projekten austauschbar.
Sensormeter WLAN und Sensormeter Display haben keinen RJ45-Modularanschluss
und sind hier nicht relevant.

Quelle der Wahrheit für die Pin-Rollen bleiben die jeweiligen
`docs/verdrahtungsplan.html`/`docs/verdrahtungsschema-*.pdf` in
`sensormeter/repo` und `sensormeter-poe/repo` — dieses Verzeichnis
dokumentiert nur die **modulseitige** Sicht (was muss auf dem Stecker-PCB
jedes Moduls verdrahtet sein), nicht die geräteseitige GPIO-Zuordnung.

## RJ45-Pinbelegung (Modulseite, geräteunabhängig)

| Pin | Signal | Bus-fähig? | Bedeutung |
|---|---|---|---|
| 1 | 3V3 | — | Versorgung, alle Module 3,3V-tolerant |
| 2 | GND | — | Rückführung — bei den Modulen bewusst als Kette durchgeschleift (siehe „Durchschleif-Regel" unten), **nicht** zu verwechseln mit der geräteinternen Verdrahtung (Display etc.), die weiterhin sternförmig bleibt |
| 3 | SCL | ✅ Ja | I2C-Takt, gemeinsamer Bus mit dem OLED-Display des Geräts |
| 4 | SDA | ✅ Ja | I2C-Daten, gemeinsamer Bus |
| 5 | Einzelpin A | ❌ Nein | DHT-Data **oder** Kontakt-Eingang (siehe Kategorie 2) — genau ein Modul |
| 6 | Einzelpin B (Relais-Steuerung) | ❌ Nein | active LOW, genau ein Relais |
| 7 | Einzelpin C (Relais-Feedback) | ❌ Nein | optional, gehört zum Relais-Modul auf Pin 6 |
| 8 | Reserve | — | Bei Sensormeter (WT32-ETH01) Boot-Strapping-Pin des Geräts (muss beim Boot LOW sein) — **geräteseitig** per Pull-down gelöst, Module müssen hier nichts tun. Bei Sensormeter PoE frei. |

Pull-up-Widerstände (4,7 kΩ nach 3V3) für SDA/SCL sowie für Pin 5 sitzen
**auf dem Modul**, nicht auf dem Gerät — das Gerät stellt nur die Pins zur
Verfügung, siehe jeweilige Modul-Stückliste.

## Durchschleif-Regel (IN + OUT an jedem Modul)

**Jedes Modul bekommt zwei RJ45-Buchsen** (IN vom Gerät bzw. vorherigen
Modul, OUT zum nächsten) — Ziel: an einem Kabelstrang lassen sich immer
ein Kategorie-1- **und** ein Kategorie-2-Modul gleichzeitig betreiben, in
beliebiger Reihenfolge (Gerät→Kat1→Kat2 oder Gerät→Kat2→Kat1).

- **1 (3V3), 2 (GND), 3 (SCL), 4 (SDA), 8 (Reserve)**: immer 1:1
  durchgeschleift, unabhängig von der Modulkategorie.
- **Der jeweils vom Modul exklusiv genutzte Einzelpin (5 bei
  DHT22/Türkontakt, 6+7 beim Relais) wird auf der OUT-Buchse NICHT
  durchgeschleift**, sondern terminiert (nicht verbunden). Das erzwingt
  die „genau ein Modul dieser Art"-Regel schon auf Hardware-Ebene: ein
  versehentlich weiter hinten in der Kette gestecktes zweites
  Einzelpin-Modul am selben Pin bekommt eine offene Leitung statt eines
  Kollision mit dem ersten Modul.
- Kategorie-1-Module (I2C) terminieren dagegen **nichts** zusätzlich —
  Pin 3/4 sind bei ihnen gleichzeitig „genutzt" UND „durchgeschleift"
  (echter Bus-Abgriff, kein Schalter).

**Bewusste Abweichung von der bisherigen Geräte-Doku**: die
`verdrahtungsplan.html`-Dokumente der Hauptgeräte legen GND intern als
Sternpunkt fest („keine Daisy-Chains") — das gilt weiterhin für die
Verdrahtung **innerhalb** des Geräts (WT32-ETH01/ESP32-S3-ETH-Board,
Display, etc.). Für die **Modulkette** wird das hier bewusst aufgehoben:
bei der vorgesehenen Kettenlänge (max. 1 Kategorie-1- + 1
Kategorie-2-Modul, also maximal ein zusätzlicher Steckverbinder-Hop) ist
der Spannungsabfall/Übergangswiderstand vernachlässigbar — ein etabliertes
Muster in vergleichbaren modularen Sensor-Ökosystemen (z. B. Grove-I2C-
Ketten). Die Kette bewusst kurz halten (nicht beliebig viele Module in
Serie hängen) — dafür ist die Empfehlung „ein Kat1 + ein Kat2" gedacht,
nicht als harte Firmware-Grenze, sondern als Auslegungsgrenze des
Hardware-Entwurfs.

## Zwei Modulkategorien

Ergibt sich direkt aus der Bus-Fähigkeit der Pins (siehe Tabelle oben) —
beide Kategorien haben nach der Durchschleif-Regel oben jeweils zwei
RJ45-Buchsen (IN + OUT):

### Kategorie 1 — Bus-Module (I2C)

Nutzen Pin 1/2/3/4. Da I2C ein echter Multi-Drop-Bus ist, können
zusätzlich zum vorgesehenen einen Kategorie-2-Modul auch **mehrere**
Kategorie-1-Module gleichzeitig in derselben Kette stecken, solange sich
die I2C-Adressen nicht überschneiden — die Zwei-Buchsen-Regel oben macht
das ohnehin möglich, auch wenn der Ausgangspunkt hier nur „1+1" war.
Bereits in `SensorDetector.cpp` (Sensormeter/Sensormeter PoE) als
erkennbare Chips hinterlegt:

- BME280 (Temperatur/Feuchte/Druck)
- SHT30/31/35 (Temperatur/Feuchte)
- AHT20/21 (Temperatur/Feuchte)
- BH1750 (Helligkeit)
- perspektivisch: SGP30/CCS811 (CO₂/VOC)

**Noch kein Modul aus dieser Kategorie entworfen** — folgt nach Kategorie 2.

### Kategorie 2 — Direkt-Module (Einzelpin)

Belegen zusätzlich einen dedizierten Einzelpin (5, 6 oder 7) — genau
**ein** Modul dieser Art gleichzeitig steckbar (der Einzelpin ist nicht
bus-fähig), aber dank Durchschleif-Regel oben trotzdem mit einem
Kategorie-1-Modul in derselben Kette kombinierbar. Der Einzelpin selbst
wird auf der OUT-Buchse terminiert, siehe oben.

| Modul | Pin(s) | Status |
|---|---|---|
| [DHT22-Sensormodul](dht22-modul.md) | 5 | ✅ entworfen |
| Türkontakt (Reed-/Magnetkontakt) | 5 (gemeinsam mit DHT22, siehe unten) | 📋 vorgemerkt |
| Relais/Aktor-Modul | 6 (Steuerung) + 7 (Feedback) | 📋 noch nicht entworfen (Firmware bereits fertig, siehe `sensormeter-poe`/`sensormeter` `entscheidungen.md`) |

**DHT22 und Türkontakt teilen sich Pin 5, schließen sich gegenseitig aus.**
Elektrisch identische Pull-up-Topologie (Pin 5 → 4,7 kΩ → 3V3, Sensor bzw.
Kontakt zieht die Leitung aktiv auf GND) — beide passen auf denselben
Steckplatz, nur eines der beiden kann gleichzeitig gesteckt sein.

**Bekannte Einschränkung der Auto-Erkennung für einen künftigen
Türkontakt**: `SensorDetector::runDetection()` versucht bei fehlgeschlagenem
I2C-Scan aktuell einen DHT-Leseversuch auf Pin 5. Ein Türkontakt-Modul
würde dabei nur erkannt, wenn der Kontakt beim Scan **geschlossen** ist
(Pin auf LOW) — ein offener Kontakt sieht elektrisch identisch aus wie
„nichts gesteckt" (Pull-up hält die Leitung HIGH), der DHT-Leseversuch
schlägt in beiden Fällen gleich fehl. Genau wie bei Sensor 2 heute schon
(„Erkennung setzt nur automatisch, deaktiviert nie automatisch") bräuchte
ein Türkontakt-Modul zusätzlich eine manuelle Override-Option in den
Einstellungen, um zuverlässig zu funktionieren, wenn die Tür beim
Boot-Scan gerade offen ist.

**Wichtiger Unterschied zu Sensor 2**: ein Türkontakt liefert nur
offen/geschlossen (binär), kein Temperatur-/Feuchte-Paar. Er kann daher
NICHT einfach den bestehenden „Sensor 2"-Datenpfad (SNMP-Zweig `.4.x`,
MQTT-`sensor`-Discovery, Web-UI-Sensorformular) mitbenutzen, sondern
bräuchte einen eigenen, neuen Datenpfad (eigenes Config-Feld, eigene
SNMP-OID, MQTT `binary_sensor` statt `sensor`) — das ist ein separates,
späteres Firmware-Thema und betrifft nur die Software, nicht den
Hardware-Entwurf des Steckers selbst (der ist mit dem DHT22-Modul bereits
identisch).

## Stückliste-Konvention

Jedes Modul bekommt eine eigene Datei `<modulname>.md` in diesem
Verzeichnis mit mindestens:

1. **Zweck** — was das Modul misst/steuert, welche(s) Gerät(e) es
   unterstützen (Sensormeter / Sensormeter PoE / beide)
2. **Pinbelegung des Modul-Steckers** — welche der 8 RJ45-Pins wie
   beschaltet werden
3. **Stückliste** — Bauteile, Werte, Anzahl
4. **Verdrahtungstabelle** — Bauteil-Pin → RJ45-Pin, analog zu den
   bestehenden `verdrahtungsplan.html`-Dokumenten der Hauptgeräte
5. **Bekannte Einschränkungen** — z. B. Auto-Erkennungs-Grenzen,
   gegenseitiger Ausschluss mit anderen Modulen am selben Pin

Eine interaktive HTML-Visualisierung (analog zu
`sensormeter/repo/docs/verdrahtungsplan.html`) ist für eine spätere Runde
vorgesehen, sobald mehrere Module fertig sind — die Text-/Tabellenform
hier ist die Grundlage dafür.
