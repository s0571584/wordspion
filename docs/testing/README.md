# WortSpion - Teststrategie

Diese Teststrategie beschreibt den Ansatz für das Testen der WortSpion-App. Sie umfasst verschiedene Testebenen, -methoden und -tools, um die Qualität und Zuverlässigkeit der Anwendung sicherzustellen.

## Testziele

1. **Funktionalität:** Sicherstellen, dass alle Spielmechaniken wie erwartet funktionieren
2. **Benutzerfreundlichkeit:** Gewährleisten einer intuitiven und angenehmen Benutzererfahrung
3. **Performance:** Überprüfen, dass die App flüssig läuft und Ressourcen effizient nutzt
4. **Datenbankintegrität:** Sicherstellen der korrekten Speicherung und Abrufung von Daten
5. **Sicherheit:** Sicherstellen, dass die Spiellogik nicht manipuliert werden kann (besonders wichtig für V2)
6. **Gerätekompatibilität:** Bestätigen, dass die App auf verschiedenen Geräten korrekt funktioniert

## Testebenen

### 1. Unit-Tests

**Ziel:** Überprüfung einzelner Funktionen und Klassen in Isolation

**Umfang:**
- Modelle (Game, Player, Round, Word)
- Repository-Implementierungen
- BLoC/Cubit-Logik
- Hilfsfunktionen und Utilities
- Datenbankoperationen

**Werkzeuge:**
- Flutter Test-Framework
- Mockito für Mocking von Abhängigkeiten
- BLoC Test für BLoC/Cubit-Tests
- SQLite-Mocks für Datenbankzugriffstests

**Beispiel für BLoC-Test:**
```dart
void main() {
  group('GameBloc', () {
    late GameBloc gameBloc;
    late MockGameRepository mockGameRepository;
    
    setUp(() {
      mockGameRepository = MockGameRepository();
      gameBloc = GameBloc(gameRepository: mockGameRepository);
    });
    
    tearDown(() {
      gameBloc.close();
    });
    
    test('Initial state should be GameInitial', () {
      expect(gameBloc.state, equals(GameInitial()));
    });
    
    blocTest<GameBloc, GameState>(
      'should emit GameLoading and then GameCreated when CreateGame event is added',
      build: () {
        when(mockGameRepository.createGame(any))
            .thenAnswer((_) async => Game(/* ... */));
        return gameBloc;
      },
      act: (bloc) => bloc.add(CreateGame(settings: GameSettings(/* ... */))),
      expect: () => [
        isA<GameLoading>(),
        isA<GameCreated>(),
      ],
      verify: (_) {
        verify(mockGameRepository.createGame(any)).called(1);
      },
    );
  });
}
```

**Code-Abdeckungsziel:** > 80% für Kern-Business-Logik

### 2. Widget-Tests

**Ziel:** Überprüfen der korrekten Darstellung und Interaktion von UI-Komponenten

**Umfang:**
- Wiederverwendbare Widgets (PlayerCard, RoleRevealCard, etc.)
- Screen-Widgets
- Navigation und Übergänge
- Form-Validierung

**Werkzeuge:**
- Flutter Widget Testing Framework
- Golden Tests für visuelle Regression-Tests

**Beispiel für Widget-Test:**
```dart
void main() {
  group('PlayerCard Widget', () {
    testWidgets('displays player name and score correctly', 
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerCard(
            name: 'Spieler 1',
            score: 5,
            isImpostor: false,
            showRole: true,
          ),
        ),
      ));
      
      expect(find.text('Spieler 1'), findsOneWidget);
      expect(find.text('5 Pkt.'), findsOneWidget);
      expect(find.text('Teammitglied'), findsOneWidget);
      expect(find.text('Spion'), findsNothing);
    });
    
    testWidgets('handles tap correctly', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlayerCard(
            name: 'Spieler 1',
            score: 5,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ));
      
      await tester.tap(find.byType(PlayerCard));
      expect(tapped, isTrue);
    });
  });
}
```

**Code-Abdeckungsziel:** > 70% für UI-Komponenten

### 3. Integration-Tests

**Ziel:** Überprüfen des Zusammenspiels verschiedener Komponenten im Systemkontext

**Umfang:**
- Vollständiger Spielablauf
- Datenfluss zwischen Repositories und BLoCs
- Navigation zwischen Screens
- Übergänge zwischen Spielphasen
- Datenbankinteraktionen

**Werkzeuge:**
- Flutter Integration Test
- In-Memory-SQLite-Datenbank für kontrollierte Tests

**Beispiel für Integrations-Test:**
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('End-to-end game flow', () {
    testWidgets('Complete game cycle works correctly', 
        (WidgetTester tester) async {
      // App starten
      app.main();
      await tester.pumpAndSettle();
      
      // Neues Spiel starten
      await tester.tap(find.text('Neues Spiel starten'));
      await tester.pumpAndSettle();
      
      // Einstellungen konfigurieren
      await tester.tap(find.text('Spiel starten'));
      await tester.pumpAndSettle();
      
      // Spielernamen eingeben
      await tester.enterText(find.byType(TextField), 'Spieler 1');
      await tester.tap(find.text('Spieler hinzufügen'));
      await tester.pumpAndSettle();
      
      // ... weitere Schritte für den gesamten Spielablauf
      
      // Überprüfen des Ergebnisbildschirms
      expect(find.text('RUNDENERGEBNIS'), findsOneWidget);
    });
  });
}
```

**Abdeckungsziel:** Alle kritischen Pfade durch die Anwendung

### 4. Datenbank-Tests

**Ziel:** Überprüfen der Datenbankoperationen und -integrität

**Umfang:**
- CRUD-Operationen für alle Entitäten
- Transaktionen und Atomarität
- Datenintegrität und Beziehungen
- Migrationen und Versionierung

**Werkzeuge:**
- In-Memory-SQLite für schnelle Tests
- Spezielle Test-Fixtures für Datenbank-Setup

**Beispiel für Datenbank-Test:**
```dart
void main() {
  late Database database;
  late GameRepositoryImpl repository;
  
  setUp(() async {
    // In-Memory-SQLite-Datenbank für Tests
    database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        // Tabellen erstellen
        await db.execute('''
          CREATE TABLE games (
            id TEXT PRIMARY KEY,
            player_count INTEGER NOT NULL,
            impostor_count INTEGER NOT NULL,
            round_count INTEGER NOT NULL,
            timer_duration INTEGER NOT NULL,
            impostors_know_each_other INTEGER DEFAULT 0,
            state TEXT NOT NULL,
            current_round INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL
          )
        ''');
        // Weitere Tabellen...
      },
    );
    
    repository = GameRepositoryImpl(database);
  });
  
  tearDown(() async {
    await database.close();
  });
  
  test('createGame should insert a new game record', () async {
    // Arrange
    final settings = GameSettings(
      playerCount: 6,
      impostorCount: 2,
      roundCount: 3,
      timerDuration: 60,
      impostorsKnowEachOther: true,
    );
    
    // Act
    final game = await repository.createGame(settings);
    
    // Assert
    final result = await database.query(
      'games',
      where: 'id = ?',
      whereArgs: [game.id],
    );
    
    expect(result.length, 1);
    expect(result.first['player_count'], 6);
    expect(result.first['impostor_count'], 2);
    expect(result.first['round_count'], 3);
    expect(result.first['timer_duration'], 60);
    expect(result.first['impostors_know_each_other'], 1);
  });
}
```

**Code-Abdeckungsziel:** > 90% für Datenbankoperationen

### 5. End-to-End-Tests

**Ziel:** Überprüfen der Anwendung in einer realen Umgebung

**Umfang:**
- Installation und Start der App
- Vollständige Spielsessions
- Speicherung und Wiederherstellung von Spielständen
- Performance auf Zielgeräten

**Werkzeuge:**
- Firebase Test Lab
- Manuelle Tests auf verschiedenen Geräten

**Testplan:**
1. App auf verschiedenen Android- und iOS-Geräten installieren
2. Vollständige Spielsession mit 3-5 Spielern durchführen
3. Performance-Metriken (FPS, Speicherverbrauch) überwachen
4. App beenden und neu starten, Zustandswiederherstellung prüfen

## Spezifische Testfälle

### Spiellogik-Tests

1. **Rollenverteilung:**
   - Test: Bei 6 Spielern und 2 Spionen werden genau 2 Spieler als Spione markiert
   - Erwartung: 2 Spieler erhalten Spion-Rolle, 4 Spieler erhalten Team-Rolle

2. **Wortzuweisung:**
   - Test: Teammitglieder erhalten das Hauptwort, Spione das Täuschungswort
   - Erwartung: Alle Teammitglieder sehen identisches Wort, alle Spione sehen identisches Täuschungswort

3. **Abstimmungsmechanik:**
   - Test: Jeder Spieler kann genau eine Stimme abgeben
   - Erwartung: Bei 6 Spielern werden insgesamt 6 Stimmen registriert

4. **Punkteberechnung:**
   - Test: Team gewinnt, wenn alle Spione identifiziert werden
   - Erwartung: Jedes Teammitglied erhält +2 Punkte

   - Test: Spione gewinnen, wenn mindestens ein Spion unentdeckt bleibt
   - Erwartung: Jeder Spion erhält +3 Punkte

   - Test: Teammitglied wird fälschlicherweise ausgewählt
   - Erwartung: Alle Teammitglieder erhalten -1 Punkt

### Datenbank-Tests

1. **CRUD-Operationen:**
   - Erstellen, Lesen, Aktualisieren und Löschen von Spielen
   - Erstellen, Lesen, Aktualisieren und Löschen von Spielern
   - Erstellen, Lesen, Aktualisieren und Löschen von Runden

2. **Datenintegrität:**
   - Fremdschlüsselbeziehungen werden korrekt durchgesetzt
   - Einschränkungen (Constraints) werden korrekt geprüft
   - Eindeutigkeitsbedingungen werden korrekt durchgesetzt

3. **Transaktionen:**
   - Atomare Operationen werden korrekt ausgeführt
   - Fehlerbehandlung bei Datenbankoperationen funktioniert korrekt
   - Rollback bei fehlgeschlagenen Transaktionen funktioniert korrekt

### UI-Tests

1. **Responsive Design:**
   - Test: App auf verschiedenen Bildschirmgrößen (Smartphone, Tablet)
   - Erwartung: UI passt sich an, alle Elemente sind sichtbar und zugänglich

2. **Übergabesicherheit:**
   - Test: Rollenanzeige zeigt nur nach expliziter Bestätigung das nächste Element
   - Erwartung: Keine Möglichkeit, versehentlich die Rolle eines anderen Spielers zu sehen

3. **Timer-Funktionalität:**
   - Test: Timer beginnt bei konfiguriertem Wert und zählt herunter
   - Erwartung: Timer endet genau bei 0 und löst entsprechendes Event aus

### Performanztests

1. **Datenbankperformance:**
   - Test: Mehrere Spielsessions mit verschiedenen Spielerzahlen
   - Erwartung: Keine signifikante Verzögerung bei Datenbankzugriffen

2. **Speicherverbrauch:**
   - Test: App über mehrere Spielrunden ausführen
   - Erwartung: Kein signifikanter Anstieg des Speicherverbrauchs (keine Memory Leaks)

3. **Renderingperformanz:**
   - Test: Animation des Timers und Screenübergänge
   - Erwartung: Konsistente 60 FPS, keine visuellen Aussetzer

4. **App-Größe:**
   - Test: APK-/IPA-Größe
   - Erwartung: < 30MB für die Release-Version

## Testumgebungen

### Entwicklungsumgebung
- Lokale Tests während der Entwicklung
- Einsatz von Hot Reload für schnelles Feedback
- Automatisierte Unit- und Widget-Tests bei jedem Build

### Continuous Integration
- Automatisierte Tests bei jedem Push/PR
- Code-Coverage-Bericht generieren
- Screenshot-Tests für UI-Komponenten

### Prerelease-Umgebung
- Verteilung über TestFlight (iOS) und Google Play Beta (Android)
- Eingeschränkter Benutzerkreis für Feedback
- Sammlung von Crash-Berichten und Telemetrie

## Teststrategie für die Mehrspieler-Version (V2)

Für die zukünftige Mehrspieler-Version mit Supabase-Integration werden zusätzliche Tests benötigt:

1. **Netzwerkteststrategie:**
   - Simulation verschiedener Netzwerkbedingungen (gute Verbindung, schlechte Verbindung, Disconnect)
   - Test der Wiederverbindungslogik
   - Validierung der Datenintegrität bei asynchroner Kommunikation

2. **Sicherheitstests:**
   - Penetrationstests für die Supabase-Implementierung
   - Überprüfung der Row-Level Security Policies
   - Test auf Client-seitige Manipulationsversuche

3. **Lasttests:**
   - Simulation mehrerer gleichzeitiger Spiele
   - Messung der Serverlatenz unter Last
   - Validierung der Skalierbarkeit

4. **Datenbankmigrationstests:**
   - Test der Migration von lokaler SQLite zu Supabase PostgreSQL
   - Validierung der Datenintegrität nach Migration
   - Test der Abwärtskompatibilität

## Fehlermanagement

1. **Fehlerkategorisierung:**
   - **Kritisch:** Spielabbruch, Datenverlust
   - **Hoch:** Beeinträchtigung des Spielerlebnisses
   - **Mittel:** Kleinere UI-Probleme, nicht-kritische Funktionalität
   - **Niedrig:** Kosmetische Fehler

2. **Fehlerberichtsformat:**
   ```
   ID: [Eindeutige ID]
   Titel: [Kurzbeschreibung]
   Schweregrad: [Kritisch/Hoch/Mittel/Niedrig]
   Schritte zur Reproduktion:
   1. [Schritt 1]
   2. [Schritt 2]
   ...
   Erwartetes Verhalten: [Beschreibung]
   Tatsächliches Verhalten: [Beschreibung]
   Umgebung: [Gerät, Betriebssystem, App-Version]
   Screenshot/Video: [Falls vorhanden]
   ```

3. **Bug-Tracking-Prozess:**
   1. Fehler identifizieren und dokumentieren
   2. Reproduzierbarkeit validieren
   3. Priorisieren basierend auf Schweregrad und Auswirkung
   4. Zuweisen an verantwortlichen Entwickler
   5. Beheben und Patch erstellen
   6. Verifikationstest durchführen
   7. Schließen des Bug-Reports

## Akzeptanzkriterien

Die folgenden Kriterien müssen erfüllt sein, bevor die App für die Veröffentlichung freigegeben wird:

1. **Funktionalität:**
   - Alle Spielfunktionen arbeiten fehlerfrei
   - Kein bekannter kritischer oder hoher Fehler
   - Volles Spielerlebnis ohne Unterbrechungen möglich

2. **Performance:**
   - Stabile 60 FPS auf Zielgeräten
   - App-Start < 3 Sekunden auf mittelklassigen Geräten
   - Datenbankoperationen < 100ms
   - Speicherverbrauch < 200MB während des Spiels

3. **Benutzerfreundlichkeit:**
   - Positive Rückmeldungen von Testern
   - Durchschnittliche Spielsession > 15 Minuten
   - Wiederholte Nutzung der App bei > 70% der Testnutzer

4. **Kompatibilität:**
   - Funktioniert auf Android 6.0+ (API 23+)
   - Funktioniert auf iOS 12.0+
   - Korrekte Darstellung auf verschiedenen Bildschirmgrößen

## Automatisierte Tests in CI/CD-Pipeline

Für eine effiziente Testautomatisierung wird empfohlen, eine CI/CD-Pipeline mit GitHub Actions einzurichten:

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Analyze project
        run: flutter analyze
      
      - name: Run unit tests
        run: flutter test
      
      - name: Build APK
        run: flutter build apk
      
      - name: Upload APK
        uses: actions/upload-artifact@v2
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

## Testdokumentation und Berichterstattung

Für eine effektive Testdokumentation und -berichterstattung werden folgende Maßnahmen empfohlen:

1. **Testberichte:**
   - Automatische Generierung von Testberichten nach jedem Testlauf
   - Visualisierung der Code-Coverage und Testergebnisse
   - Trendanalyse über mehrere Testläufe hinweg

2. **Fehlerüberwachung:**
   - Integration eines Crash-Reporting-Tools (z.B. Firebase Crashlytics)
   - Überwachung der Fehlerrate in verschiedenen App-Versionen
   - Automatische Benachrichtigungen bei kritischen Fehlern

3. **Benutzer-Feedback:**
   - Integration eines In-App-Feedback-Mechanismus
   - Analyse von App-Store-Bewertungen und -Kommentaren
   - Sammlung von Benutzerfeedback in strukturierter Form

---

Diese Teststrategie bietet einen umfassenden Ansatz zur Qualitätssicherung der WortSpion-App. Durch systematisches Testen auf verschiedenen Ebenen wird sichergestellt, dass die App zuverlässig, leistungsfähig und benutzerfreundlich ist. Besonderes Augenmerk wird auf die Datenbank-Tests gelegt, um eine reibungslose Migration von SQLite zu Supabase in der zukünftigen Version zu gewährleisten.
