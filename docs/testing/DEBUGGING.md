# WortSpion - Debugging und Entwicklung

Dieses Dokument enthält Informationen zur Fehlerbehebung, Debugging-Strategien und bekannten Fallstricken in der WortSpion-App.

## Bekannte Herausforderungen

### 1. Spieleinstellungen-Management

Eine zentrale Herausforderung im System ist die korrekte Propagierung von Benutzereinstellungen durch verschiedene Komponenten.

#### Schlüsselprobleme:

- **Konsistente Schlüssel**: Zwischen GameSetupScreen, GameBloc, und PlayerBloc müssen identische SharedPreferences-Schlüssel verwendet werden
- **Validierungsregeln**: Die min/max-Validierung für Spieleranzahl und Spionanzahl muss sorgfältig koordiniert werden
- **Spezialfall-Behandlung**: Bestimmte Spielkonfigurationen (wie 3 Spione bei 5 Spielern) benötigen spezielle Behandlung

#### Empfohlene Lösungen:

- Zentrale Definition der SharedPreferences-Schlüssel zur Vermeidung von Inkonsistenzen
- Explizite Verifizierung der geladenen Einstellungen nach kritischen Operationen
- Umfassendes Logging an Schlüsselpunkten im Datenfluss

### 2. Rollenzuweisung

Die korrekte Zuweisung von Spielerrollen ist ein kritischer Prozess, bei dem mehrere Komponenten involviert sind.

#### Schlüsselprobleme:

- **Validierung der Rollenverteilung**: Sicherstellen, dass die Anzahl der Spione gültig ist (impostorCount ≤ playerCount - 2)
- **Datenübergabe**: Korrekte Übermittlung der Konfiguration zwischen GameBloc, RoleRevealScreen und RoundBloc
- **Zufallsgenerator**: Gleichmäßige Verteilung der Rollen bei wiederholten Spielen

#### Empfohlene Lösungen:

- Mehrschichtige Validierung (UI, GameBloc, RoundBloc, Repository)
- Logging der Rollenverteilung in RoundRepositoryImpl.assignRoles
- Direkte Abfrage der Datenbank zur Bestätigung der gespeicherten Werte

## Debugging-Strategie

### 1. Strukturiertes Logging

Für effektives Debugging wurden strategische Logging-Punkte im Code implementiert:

```dart
// Format: Komponentenname: Nachrichtentext
print("GameBloc: Loaded settings from SharedPreferences:");
print("- impostorCount = $impostorCount");
```

Die wichtigsten Logging-Positionen sind:

- **GameSetupScreen._saveSettings**: Bestätigung der gespeicherten Einstellungen
- **GameBloc._loadSavedSettings**: Überprüfung der geladenen Einstellungen
- **PlayerBloc._onRegisterPlayers**: Überprüfung der für das Spiel verwendeten Einstellungen
- **RoundBloc._onStartRound**: Verifizierung der für die Rollenzuweisung verwendeten Parameter
- **RoundRepositoryImpl.assignRoles**: Überprüfung der tatsächlich zugewiesenen Rollen

### 2. Verifizierung

Bei kritischen Operationen werden folgende Verifizierungsschritte empfohlen:

1. **SharedPreferences**: Nach dem Speichern direkt den gespeicherten Wert wieder abrufen und prüfen
2. **Datenbank**: Nach dem Speichern das Objekt erneut aus der Datenbank lesen
3. **Rollenzuweisung**: Nach der Zuweisung die tatsächliche Verteilung überprüfen:
   ```dart
   print("Assigned roles: ${roles.where((r) => r.isImpostor).length} impostors out of ${roles.length} players.");
   ```

## Behobene Fehler

### Spionenanzahl-Problem

**Problem**: Bei einer Konfiguration von 3 Spionen mit 5 Spielern wurde die Einstellung auf 2 Spione überschrieben.

**Ursache**: Der "Smart Default"-Algorithmus in GameBloc hat die Einstellungen überschrieben, basierend auf dem Verhältnis impostorCount > playerCount / 3.

**Lösung**: 
1. Anpassung der Validierungslogik für ein höheres Verhältnis (impostorCount <= playerCount - 2)
2. Spezialfall-Behandlung für 5 Spieler mit 3 Spionen
3. Konsistente Verwendung von SharedPreferences für die Einstellungspersistenz
4. Direkter Zugriff auf SharedPreferences in PlayerBloc statt Abhängigkeit von GameBloc

**Code-Änderungen**:
```dart
// GameBloc: Spezialfall für 5 Spieler mit 3 Spionen
if (playerCount == 5 && _lastImpostorCount == 3) {
  // Dies ist eine gültige Konfiguration
  impostorCount = 3;
}

// PlayerBloc: Direkte Abfrage der Einstellungen
final prefs = await SharedPreferences.getInstance();
final impostorCount = prefs.getInt('game_impostor_count') ?? 1;
```

### Datenbankaktualisierungsproblem

**Problem**: Spieleinstellungen wurden gespeichert, aber nicht korrekt in die Datenbank übernommen.

**Ursache**: Der GameRepositoryImpl.createGame-Aufruf erhielt nicht die aktuellen Einstellungen.

**Lösung**:
1. Verifikation des Game-Objekts nach der Erstellung
2. Debugging-Ausgaben für die Datenbankoperationen
3. Konsistente Verwaltung der Spieleinstellungen in GameBloc

## Auswirkungen auf die Spielmechanik

### Unterstützte Konfigurationen

Basierend auf den implementierten Fixes unterstützt die App jetzt die folgenden Konfigurationen:

- **Standardkonfigurationen**:
  - 3-4 Spieler: 1 Spion
  - 5-6 Spieler: 1-2 Spione
  - 7+ Spieler: 1-3 Spione

- **Spezielle Konfigurationen**:
  - 5 Spieler mit 3 Spionen: Hohe Schwierigkeit, aber spielbar (2 Nichtspione)
  - 4 Spieler mit 2 Spionen: Hohe Schwierigkeit, aber spielbar (2 Nichtspione)

### Grundregel

Die fundamentale Regel für alle Konfigurationen ist: `impostorCount <= playerCount - 2`. 
Dies stellt sicher, dass immer mindestens 2 Nichtspione im Spiel sind, was für ein ausgewogenes Spielerlebnis wichtig ist.

## Fazit

Die WortSpion-App verwendet ein komplexes System aus mehreren BLoC-Komponenten und persistenten Speicherschichten. 
Die wichtigsten Erkenntnisse aus der Debugging-Session und den vorgenommenen Verbesserungen sind:

1. Konsistente Schlüssel für SharedPreferences verwenden
2. Datenbankoperationen verifizieren und protokollieren
3. Spezielle Spielsituationen explizit behandeln
4. Validierungsregeln an mehreren Stellen im Code anwenden
5. Umfassendes Logging für kritische Operationen implementieren

Diese Erkenntnisse verbessern nicht nur die aktuelle Implementierung, sondern bieten auch eine solide Grundlage für zukünftige Erweiterungen wie den Mehrspieler-Modus.