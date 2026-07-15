# RJ45-Steckmodule — Entwurfsübersicht

Zentrale Ablage für die Hardware-Entwürfe der über den RJ45-Modularanschluss
steckbaren Erweiterungsmodule. Betrifft nur **Sensormeter** (WT32-ETH01)
und **Sensormeter PoE** (ESP32-S3-ETH) — beide haben eine RJ45-Buchse mit
identischem Pin-**Rollen**-Schema (siehe unten), die konkreten GPIO-Nummern
auf der jeweiligen Geräteseite unterscheiden sich zwangsläufig (anderer
Chip). Steckmodule sind dadurch zwischen beiden Projekten austauschbar.
Sensormeter WLAN und Sensormeter Display haben keinen RJ45-Modularanschluss
und sind hier nicht relevant.

**Stand 2026-07-15**: Modulliste vollständig überarbeitet — sie bildet jetzt
ausschließlich die tatsächlich beschaffte Hardware ab (siehe
`sensormeter-family/beschaffte-sensoren-uebersicht.txt`, Foto-Abgleich),
statt generischer Chip-Vorschläge. Frühere Einzelmodule (reines BME280,
reines AHT20/21, BME280+CCS811-Kombi, DHT22, Reed-Türkontakt) sind entfallen
und durch die unten gelisteten, tatsächlich vorliegenden Module ersetzt.
**Firmware-Einpflege für sensormeter/sensormeter-poe steht noch aus** — diese
Seite und die Modul-Dokumente beschreiben vorerst nur die Hardware-Seite.

Quelle der Wahrheit für die Pin-Rollen bleiben die jeweiligen
`docs/verdrahtungsplan.html`/`docs/verdrahtungsschema-*.pdf` in
`sensormeter/repo` und `sensormeter-poe/repo` — dieses Verzeichnis
dokumentiert nur die **modulseitige** Sicht (was muss auf dem Stecker-PCB
jedes Moduls verdrahtet sein), nicht die geräteseitige GPIO-Zuordnung.

## RJ45-Pinbelegung (Modulseite, geräteunabhängig)

| Pin | Signal | Bus-fähig? | Bedeutung |
|---|---|---|---|
| 1 | 3V3 | — | Versorgung, alle 3,3V-Module |
| 2 | GND | — | Rückführung — bei den Modulen bewusst als Kette durchgeschleift (siehe „Durchschleif-Regel" unten), **nicht** zu verwechseln mit der geräteinternen Verdrahtung (Display etc.), die weiterhin sternförmig bleibt |
| 3 | SCL | ✅ Ja | I2C-Takt, gemeinsamer Bus mit dem OLED-Display des Geräts |
| 4 | SDA | ✅ Ja | I2C-Daten, gemeinsamer Bus |
| 5 | Einzelpin A | ❌ Nein | DHT-Data **oder** Kontakt-Eingang (siehe Kategorie 2) — genau ein Modul |
| 6 | Einzelpin B (Relais-Steuerung) | ❌ Nein | active LOW, genau ein Relais |
| 7 | Einzelpin C (Relais-Feedback) | ❌ Nein | optional, gehört zum Relais-Modul auf Pin 6 |
| 8 | 5V | — | Versorgungsspannung vom Gerät (Board-Eingang, kein GPIO) — für Module, die mehr als 3,3V brauchen. Auf ausdrücklichen Beschluss festgelegt, siehe „5V auf Pin 8" unten. **Erstes Modul, das diesen Pin tatsächlich nutzt: das Relais-Modul** (siehe unten). |

**5V auf Pin 8**: bis zu dieser Entscheidung war Pin 8 als „Reserve" auf
einen GPIO des jeweiligen Geräts herausgeführt (bei Sensormeter/
WT32-ETH01 sogar ein Boot-Strapping-Pin, der zwingend LOW sein musste).
Er trägt jetzt fest die 5V-Versorgungsschiene des Geräts — nutzbar für
Module, die mehr als 3,3V brauchen, ohne einen eigenen Aufwärtswandler zu
benötigen. Der frühere GPIO (bei Sensormeter: `IO12`, ein
Flash-Spannungs-Boot-Strapping-Pin) ist deshalb **nicht mehr** mit der
RJ45-Buchse verbunden — sein Pull-down bleibt weiterhin geräteintern
nötig, nur ohne jede Verbindung zum Modulanschluss. Siehe die jeweiligen
`docs/entscheidungen.md` in `sensormeter/repo` und `sensormeter-poe/repo`
(„RJ45 Pin 8: 5V statt Reserve").

**Achtung bei 5V-Modulen**: Pin 8 ist NICHT 3,3V-tolerant im Sinne der
übrigen Pins — ein Modul, das seine VCC an Pin 8 anschließt, bekommt 5V,
nicht 3,3V. Nur Module verwenden, die das vertragen bzw. gezielt dafür
ausgelegt sind. Belastbarkeit/Strombudget der 5V-Schiene ist mangels
gebauter Hardware noch nicht gegen ein echtes Schaltbild verifiziert.

Pull-up-Widerstände sitzen grundsätzlich **auf dem Modul**, nicht auf dem
Gerät — das Gerät stellt nur die Pins zur Verfügung. Zwei getrennte Fälle:

- **SDA/SCL (Kategorie 1, Bus)**: 4,7 kΩ nach 3V3, aber **nur, falls der
  Bus noch keinen Pull-up hat** — der gemeinsame Bus mit dem OLED-Display
  des Geräts kann dort bereits einen mitbringen (viele Breakouts haben
  einen eingebauten Pull-up). Vor dem Bestücken mit Multimeter prüfen, ein
  doppelter Pull-up (Gerät/Display *und* Modul) senkt den effektiven
  Widerstand unnötig — Schritt-für-Schritt-Anleitung inkl. Verdrahtungsbildern
  für beide Fälle (mit/ohne vorhandenen Pull-up) in
  [i2c-grundlagen.html](i2c-grundlagen.html) / `.pdf`.
- **Pin 5 (Kategorie 2, DHT/Kontakt)**: 4,7 kΩ nach 3V3 bei der
  **Standard-Variante** — **Ausnahme**: die Lite-Variante des
  [Türkontakt-Moduls](tuerkontakt-modul.md) verzichtet bewusst auf den
  externen Pull-up und nutzt stattdessen den internen Pull-up des
  jeweiligen Geräte-GPIO — Lite-Module sind also nicht pauschal
  pull-up-frei vom Gerät, das ist eine modulspezifische Entscheidung.

## Durchschleif-Regel (IN + OUT an jedem Modul)

**Jedes Modul bekommt zwei RJ45-Buchsen** (IN vom Gerät bzw. vorherigen
Modul, OUT zum nächsten) — Ziel: an einem Kabelstrang lassen sich immer
ein Kategorie-1- **und** ein Kategorie-2-Modul gleichzeitig betreiben, in
beliebiger Reihenfolge (Gerät→Kat1→Kat2 oder Gerät→Kat2→Kat1).

- **1 (3V3), 2 (GND), 3 (SCL), 4 (SDA), 8 (5V)**: immer 1:1
  durchgeschleift, unabhängig von der Modulkategorie.
- **Der jeweils vom Modul exklusiv genutzte Einzelpin (5 bei DHT/
  Türkontakt, 6+7 beim Relais) wird auf der OUT-Buchse NICHT
  durchgeschleift**, sondern terminiert (nicht verbunden). Das erzwingt
  die „genau ein Modul dieser Art"-Regel schon auf Hardware-Ebene.
- Kategorie-1-Module (I2C) terminieren dagegen **nichts** zusätzlich —
  Pin 3/4 sind bei ihnen gleichzeitig „genutzt" UND „durchgeschleift"
  (echter Bus-Abgriff, kein Schalter).

**Bewusste Abweichung von der bisherigen Geräte-Doku**: die
`verdrahtungsplan.html`-Dokumente der Hauptgeräte legen GND intern als
Sternpunkt fest („keine Daisy-Chains") — das gilt weiterhin für die
Verdrahtung **innerhalb** des Geräts. Für die **Modulkette** wird das hier
bewusst aufgehoben (max. 1 Kategorie-1- + 1 Kategorie-2-Modul, also
maximal ein zusätzlicher Steckverbinder-Hop — vernachlässigbarer
Spannungsabfall).

## Zwei Modulkategorien

### Kategorie 1 — Bus-Module (I2C)

Nutzen Pin 1/2/3/4. Da I2C ein echter Multi-Drop-Bus ist, können
zusätzlich zum vorgesehenen einen Kategorie-2-Modul auch **mehrere**
Kategorie-1-Module gleichzeitig in derselben Kette stecken, solange sich
die I2C-Adressen nicht überschneiden.

**Wichtiger Erkennungs-Hinweis für alle I2C-Module**: `SensorDetector.cpp`
scannt Adressen aufsteigend (0x08–0x77) und wertet seit 2026-07-15 **alle**
gefundenen Adressen aus (kein Abbruch beim ersten Treffer mehr, siehe
`docs/entscheidungen.md` in `sensormeter/repo`/`sensormeter-poe/repo`) —
mehrere gleichzeitig gesteckte I2C-Chips werden also erkannt und geloggt.
**Tatsächlich gelesen wird von `SensorManager` aber weiterhin nur eines**:
das mit der numerisch **niedrigeren** Adresse gewinnt als „primäres"
Gerät, der Rest bleibt für den Lesepfad unerreichbar. Das ist bei beiden
Kombimodulen unten relevant.

| Modul | I2C-Adresse(n) | Status |
|---|---|---|
| [AHT20+BMP280-Kombimodul](aht20-bmp280-modul.md) | AHT20 0x38 (fest) + BMP280 0x76/0x77 | Entworfen. AHT20 (0x38) gewinnt den Scan immer vor BMP280 — Temperatur/Feuchte sofort nutzbar, Druck (BMP280) bleibt für die Firmware unerreichbar, solange AHT20 mitgesteckt ist. |
| [BH1750-Modul](bh1750-modul.md) | 0x23/0x5C (ADDR-Pin) | Entworfen. Chip steht in `SensorDetector` KNOWN_CHIPS, wird aber nicht ausgelesen (Lux passt nicht ins Temperatur/Feuchte-Datenmodell von „Sensor 2"). |
| [BMP280-Modul](bmp280-modul.md) | 0x76/0x77 (SDO-Pin) | Entworfen. **Achtung**: `SensorDetector` prüft nur die Adresse, nicht die Chip-ID — ein alleinstehendes BMP280 wird fälschlich als „BME280" erkannt. `Adafruit_BME280::begin()` prüft die Chip-ID selbst und schlägt sauber fehl („nicht erreichbar"), liefert aber keine echten Messwerte. Druck ist noch kein Datentyp im Firmware-Modell. |
| [ENS160+AHT21-Kombimodul](ens160-aht21-modul.md) | AHT21 0x38 (fest) + ENS160 0x52/0x53 (ADD-Pin) | Entworfen. AHT21 (0x38) gewinnt den Scan immer vor ENS160 — Temperatur/Feuchte sofort nutzbar, Luftgüte (ENS160) bleibt unerreichbar UND ENS160 steht aktuell gar nicht in KNOWN_CHIPS (auch alleinstehend nur „unbekanntes Gerät"). |

### Anzeige-Modul (Kategorie 1, aber kein Sensor)

Familienweite Entscheidung: alle Sensormeter-Geräte außer Sensormeter
Display nutzen intern dasselbe kleine SSD1306 (0,96″, 128×64) — das
größere SH1107 (1,5″, 128×128) steht als optionales **externes**
RJ45-Steckmodul zur Verfügung. Elektrisch ein normales
Kategorie-1-Bus-Modul (Pin 1/2/3/4), aber kein Sensor — läuft auf `0x3D`
statt `0x3C` (interne Displayadresse ist belegt).

| Modul | I2C-Adresse | Status |
|---|---|---|
| [Externes Display-Modul (SH1107)](sh1107-display-modul.md) | 0x3D (fest) | Entworfen, in Firmware bereits umgesetzt (`ExternalDisplayManager`, sensormeter + sensormeter-poe). |

### Kategorie 2 — Direkt-Module (Einzelpin)

Belegen zusätzlich einen dedizierten Einzelpin (5, 6 oder 7) — genau
**ein** Modul dieser Art gleichzeitig steckbar, aber dank
Durchschleif-Regel trotzdem mit einem Kategorie-1-Modul in derselben
Kette kombinierbar.

| Modul | Pin(s) | Status |
|---|---|---|
| [DHT11-Modul](dht11-modul.md) | 5 | Entworfen. Firmware-Lesepfad für Pin 5 ist aktuell fest auf Typ `DHT22` codiert — Anpassung nötig, bevor ein echtes DHT11 korrekt gelesen wird. |
| [DHT21-Modul](dht21-modul.md) (AM2301) | 5 | Entworfen. Gleiche Einschränkung wie DHT11 — Firmware braucht die separate `DHT21`-Typkonstante statt der festen `DHT22`-Annahme. |
| [Türkontakt-Modul](tuerkontakt-modul.md) | 5 (gemeinsam mit DHT11/DHT21, siehe unten) | Entworfen, jetzt auf Basis eines mechanischen Mikroschalters mit Rollenhebel (COM/NO/NC) statt eines Reed-/Magnetkontakts — elektrisch/logisch identisch nutzbar, siehe Modul-Dokument für die Polaritäts-Hinweise (COM+NO). |
| [Relais/Aktor-Modul](relais-modul.md) | 6 (Steuerung) + 7 (Feedback) | Entworfen, Firmware (`RelayManager`) fertig. Verdrahtung jetzt auf **Pin 8 (5V)** statt Pin 1 (3,3V) umgestellt — das beschaffte Songle SRD-05VDC-SL-C ist eine 5V-Spule, siehe Modul-Dokument. |

**DHT11/DHT21 und Türkontakt teilen sich Pin 5, schließen sich gegenseitig
aus** (genau ein Modul dieser Art gleichzeitig gesteckt). Elektrisch
identische Pull-up-Topologie bei DHT-Varianten (Pin 5 → 4,7 kΩ → 3V3);
der Mikroschalter braucht denselben Pull-up als reinen Kontaktabschluss.

**Bekannte Einschränkung der Auto-Erkennung, in der Firmware gelöst durch
rein manuelle Modultyp-Wahl**: ein Kontakt-Modul wäre bei einer
DHT-Leseversuch-basierten Auto-Erkennung nur erkennbar, wenn der Kontakt
beim Scan **geschlossen** ist (Pin auf LOW) — ein offener Kontakt sieht
elektrisch identisch aus wie „nichts gesteckt". Umgesetzt wurde daher
**keine** Auto-Erkennung für dieses Modul, sondern eine rein manuelle
Modultyp-Auswahl „Sensor"/„Kontakt" auf der Einstellungsseite
(`cfg.pin5Mode`).

## Firmware-Lücke (Stand 2026-07-15)

Die Firmware-Einpflege der oben gelisteten Module steht für
sensormeter/sensormeter-poe **noch komplett aus** — diese Seite
dokumentiert vorerst nur die Hardware. Konkret offen:

1. **AHT20+BMP280 / ENS160+AHT21**: funktionieren bereits *teilweise*
   ohne Änderung (AHT20/AHT21-Anteil, da `SensorDetector`/`SensorManager`
   „AHT20/AHT21" bereits kennt und liest) — der jeweils zweite Chip
   (BMP280/ENS160) bleibt ungenutzt.
2. **BMP280 (einzeln)**: braucht einen echten Chip-ID-Check in
   `SensorDetector`, um nicht fälschlich als BME280 behandelt zu werden,
   plus einen neuen Datentyp „Druck" quer durch
   DataManager/SNMP/MQTT/Web-UI/CSV.
3. **BH1750**: braucht einen neuen Datentyp „Helligkeit/Lux" (analog).
4. **ENS160**: braucht zusätzlich einen neuen Eintrag in
   `SensorDetector`s KNOWN_CHIPS (wird aktuell gar nicht erkannt) plus
   einen neuen Datentyp „Luftgüte" (eCO2/TVOC/AQI).
5. **DHT11/DHT21**: braucht eine Typ-Auswahl statt der aktuell fest
   codierten `DHT22`-Annahme im externen Lesepfad (`SensorDetector.cpp`,
   `SensorManager.cpp`).
6. **Relais**: Firmware ist bereits vollständig fertig
   (`RelayManager`) — hier ist nur die Hardware-Verdrahtung (Pin 8 statt
   Pin 1) zu beachten, keine Firmware-Änderung nötig.

## Stückliste-Konvention

Jedes Modul bekommt eine eigene Datei `<modulname>.md` in diesem
Verzeichnis mit mindestens:

1. **Zweck** — was das Modul misst/steuert, welche(s) Gerät(e) es
   unterstützt (Sensormeter / Sensormeter PoE / beide)
2. **Varianten** — Standard (2 Buchsen, durchschleifbar) vs. Lite (1
   Kabel mit Stecker, keine Kettenfähigkeit)
3. **Pinbelegung des Modul-Steckers** — welche der 8 RJ45-Pins wie
   beschaltet werden, je Variante — **immer alle 8 Pins benannt**, auch
   unbenutzte (als „n.c." bzw. „unbenutzt")
4. **Stückliste** — Bauteile, Werte, Anzahl, je Variante
5. **Verdrahtungstabelle** — Bauteil-Pin → RJ45-Pin
6. **Bekannte Einschränkungen** — Auto-Erkennungs-Grenzen, gegenseitiger
   Ausschluss, Firmware-Lücken, fehlende Kettenfähigkeit bei Lite

Jedes Modul bekommt außerdem eine eigene interaktive HTML-Visualisierung
`<modulname>-verdrahtungsplan.html` (anklickbare Drähte, Start-/Zielpin-
Anzeige, Umschalter Standard/Lite, alle 8 RJ45-Pins immer mit Nummer und
Signal beschriftet — auch unbenutzte, ausgegraut).
