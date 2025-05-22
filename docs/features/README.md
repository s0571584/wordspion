# WortSpion - Spielfunktionen

Dieses Dokument beschreibt die detaillierten Spielfunktionen und -mechaniken der WortSpion-App.

## Spielkonzept

WortSpion ist ein soziales Deduktionsspiel, bei dem Spieler ein gemeinsames Wort kennen, während Spione (Impostoren) versuchen, unentdeckt zu bleiben und das Hauptwort zu erraten.

## Spielablauf

### 1. Spielvorbereitung

- **Spielerregistrierung**: Sequentielles Eingeben der Spielernamen
- **Spieleinstellungen**: Konfigurieren von Spieleranzahl, Spionanzahl, Rundenanzahl und Timer
- **Kategorieauswahl**: Auswahl der Wortkategorien für das Spiel

### 2. Rollenverteilung

- **Zufällige Zuweisung**: Zufällige Auswahl von Spionen für jede Runde
- **Wortzuweisung**: 
  - Teammitglieder erhalten das Hauptwort
  - Spione erhalten ein Täuschungswort
- **Option "Spione kennen sich"**: Bei Aktivierung sehen Spione die Namen der anderen Spione

### 3. Rollenanzeige

- **Privates Anzeigen**: Jeder Spieler sieht seine Rolle und das entsprechende Wort nacheinander
- **Sicherheitsfunktion**: "Verstanden & Weitergeben"-Button für kontrollierten Übergang zum nächsten Spieler

### 4. Diskussionsphase

- **Offene Diskussion**: Spieler diskutieren über das Wort, ohne es direkt zu nennen
- **Fragen und Beschreibungen**: Spieler stellen Fragen und geben Hinweise, die mit dem Wort zusammenhängen
- **Aufdeckung von Spionen**: Teammitglieder versuchen, Spione zu identifizieren
- **Worterratung**: Spione versuchen, das Hauptwort zu erraten

### 5. Abstimmungsphase

- **Timer**: Konfigurierbarer Countdown für die Abstimmung
- **Spielerauswahl**: Jeder Spieler wählt einen verdächtigen Spieler aus
- **Mehrheitsentscheidung**: Der Spieler mit den meisten Stimmen wird beschuldigt
- **Stichwahl**: Bei Gleichstand gibt es eine Stichwahl

### 6. Auflösung

- **Rollenaufdeckung**: Die Rollen der beschuldigten Spieler werden aufgedeckt
- **Worterratung**: Nicht aufgedeckte Spione haben die Möglichkeit, das Hauptwort zu erraten
- **Punkteverteilung**: Basierend auf dem Ergebnis werden Punkte vergeben
- **Rundenergebnis**: Anzeige, welche Seite gewonnen hat

### 7. Rundenübergang

- **Punkteübersicht**: Anzeige des aktuellen Punktestands
- **Nächste Runde**: Start der nächsten Runde mit neuen Rollen und Wörtern
- **Spielende**: Nach der festgelegten Anzahl von Runden endet das Spiel

## Kernmechaniken

### 1. Punktesystem

- **Team gewinnt**: +2 Punkte für jedes Teammitglied wenn alle Spione identifiziert werden
- **Spione gewinnen**: +3 Punkte für Spione wenn mindestens ein Spion unentdeckt bleibt
- **Wort-Bonus**: +2 zusätzliche Punkte für einen Spion, der das Hauptwort korrekt errät
- **Fehlabstimmung**: -1 Punkt für das Team, wenn ein Teammitglied fälschlicherweise ausgewählt wird

### 2. Wortauswahl

- **Kategoriebasiert**: Wörter werden aus den ausgewählten Kategorien gewählt
- **Schwierigkeitsgrade**: Wörter haben unterschiedliche Schwierigkeitsgrade (1-5)
- **Täuschungswort-Algorithmus**: 
  - Auswahl basierend auf Ähnlichkeitsbeziehungen
  - Bevorzugung mittlerer Ähnlichkeit für ausgewogenes Spiel
  - Fallback auf Wörter aus derselben Kategorie

### 3. Timer-Funktionalität

- **Konfigurierbar**: 30 Sekunden bis 5 Minuten
- **Visuelles Feedback**: Farbwechsel bei ablaufendem Timer
- **Automatisches Ende**: Erzwungenes Ende der Phase nach Ablauf des Timers

## Spielmodi

### 1. Einzelgerät-Modus (V1)

- **Gemeinsame Nutzung**: Ein Gerät wird herumgegeben
- **Privatsphäre**: Rollenanzeige mit "Verstanden & Weitergeben"-Mechanismus
- **Offline-Spiel**: Keine Internetverbindung erforderlich
- **Lokale Speicherung**: Punktestände und Spielfortschritt werden lokal gespeichert

### 2. Mehrspieler-Modus (zukünftige V2)

- **Online-Mehrspieler**: Jeder Spieler nutzt sein eigenes Gerät
- **Spielräume**: Erstellung von privaten Spielräumen mit Einladungscodes
- **Echtzeit-Synchronisation**: Spielzustände werden über Supabase synchronisiert

## Zusätzliche Funktionen

### 1. Wortdatenbank

- **Umfangreiche Kategorien**: 8+ Kategorien mit jeweils 50+ Wörtern
- **Erweiterbar**: Regelmäßige Updates mit neuen Wörtern
- **Benutzerfreundlich**: Kategorieauswahl für thematische Spiele

### 2. Spieleinstellungen

- **Spieleranzahl**: 3-10 Spieler
- **Spionanzahl**: 1-3 Spione (abhängig von der Spieleranzahl)
  - Für 3-4 Spieler: Empfohlen 1 Spion
  - Für 5-6 Spieler: Empfohlen 1-2 Spione
  - Für 7+ Spieler: Empfohlen 2-3 Spione
  - **Wichtig**: Es wird immer mindestens 2 Nicht-Spione geben (Validierungsregel: impostorCount ≤ playerCount - 2)
  - **Besondere Konfigurationen**: Die App unterstützt auch spezielle Spielmodi wie 3 Spione bei 5 Spielern (hohe Schwierigkeit)
- **Rundenanzahl**: Frei wählbar (Standard: 3-5)
- **Timer-Dauer**: Manuell einstellbar (30 Sekunden bis 5 Minuten)
- **Spion-Erkennung**: Option "Spione kennen sich" (an/aus)

### 3. Spielverwaltung

- **Spieler-Entfernung**: Möglichkeit, Spieler während des Spiels zu entfernen
- **Spielpause**: Pausieren und Fortsetzen des Spiels
- **Spielabbruch**: Vorzeitiges Beenden eines Spiels
- **Spielstatistiken**: Übersicht über vergangene Runden und Ergebnisse

## Zukünftige Erweiterungen (V2)

### 1. Benutzerkonten

- **Registrierung/Anmeldung**: Erstellung persönlicher Konten
- **Statistiken**: Persönliche Spielstatistiken und Erfolge
- **Freundesliste**: Hinzufügen und Einladen von Freunden


## Benutzerflüsse

### 1. Neues Spiel starten

```
Startbildschirm → Neues Spiel → Spieleinstellungen → Spielerregistrierung → Spielbeginn
```

### 2. Rundenablauf

```
Rollenverteilung → Rollenanzeige → Diskussion → Abstimmung → Auflösung → Punkteverteilung
```

### 3. Spielende

```
Letzte Rundenergebnisse → Gesamtpunktestand → Gewinner-Anzeige → Zurück zum Startbildschirm/Neues Spiel
```

## Technische Implementierungsdetails

### 1. Spielerstellung und Einstellungsverwaltung

Die Spielerstellung folgt einem präzisen Workflow:

1. **Einstellungen konfigurieren**: In GameSetupScreen werden Spielparameter festgelegt (Spieler, Spione, Runden, etc.) und in SharedPreferences gespeichert.

2. **Spielerinitalisierung**: 
   - Der PlayerBloc erstellt ein initiates Spielobjekt und lädt die konfigurierten Einstellungen aus SharedPreferences.
   - Bei der Erstellung werden Validierungen durchgeführt, um gültige Spielkonfigurationen sicherzustellen.
   - Spezielle Fallbehandlung für bestimmte Konfigurationen, z.B. 3 Spione bei 5 Spielern:
   ```dart
   // Beispiel für Spezialfall-Behandlung
   if (playerCount == 5 && _lastImpostorCount == 3) {
     // Dies ist eine gültige Konfiguration mit 3 Spionen und 2 Zivilisten
     impostorCount = 3;
   }
   ```

3. **Spielpersistenz**: Die Einstellungen werden in mehreren Schichten persistiert:
   - SharedPreferences für sessionübergreifende Persistenz
   - GameBloc für Laufzeit-Verwaltung
   - SQLite-Datenbank für das aktuelle Spiel

### 2. Rollenzuweisung und Verteilung

Der Prozess der Rollenzuweisung umfasst mehrere Schritte:

1. **Abrufen der Spielkonfiguration**:
   - Das RoleRevealScreen liest die Spielkonfiguration aus der Datenbank
   - Spielparameter (inkl. impostorCount) werden dem RoundBloc übermittelt

2. **Rollenverwaltung durch RoundBloc**:
   - Spielerliste wird gemischt (shuffled)
   - Die konfigurierte Anzahl von Spionen wird zufällig ausgewählt
   - Rollen werden in der Datenbank gespeichert

3. **Rollenverifizierung**:
   - Das `assignRoles` Repository prüft nochmals die Logik: `impostorCount <= players.length - 2`
   - Bei Diskrepanzen wird eine Warnung protokolliert und die Anzahl entsprechend angepasst

Dieser Funktionsüberblick bietet eine umfassende Darstellung der Spielmechaniken und -funktionen von WortSpion, sowohl für die aktuelle Einzelgerät-Version als auch für die geplante Mehrspieler-Erweiterung.