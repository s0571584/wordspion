# WortSpion - App-Architektur

Dieses Dokument beschreibt die Architektur der WortSpion-App, einschließlich der Schichtenarchitektur, Datenflüsse und Komponenten.

## Architekturübersicht

WortSpion folgt dem BLoC (Business Logic Component) Pattern, das eine klare Trennung zwischen Präsentation, Business Logic und Datenquellen ermöglicht.

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│  Präsentations-   │     │   Business Logic  │     │    Datenquellen   │
│     Schicht       │◄────►        Schicht    │◄────►        Schicht    │
└───────────────────┘     └───────────────────┘     └───────────────────┘
       Widgets              BLoCs/Cubits             Repositories/Services
```

## Wichtiger Hinweis zur BLoC-Nutzung und `BuildContext`

Ein häufiges Problem bei der Arbeit mit BLoCs ist die `ProviderNotFoundException`. Diese tritt auf, wenn versucht wird, einen BLoC über `BlocProvider.of<MyBloc>(context)` oder `context.read<MyBloc>()` bzw. `context.watch<MyBloc>()` abzurufen, der Kontext (`context`) jedoch keinen Zugriff auf den angeforderten BLoC-Typ hat.

**Hauptursache:** Der verwendete `BuildContext` befindet sich im Widget-Baum *oberhalb* des `BlocProvider` (oder `MultiBlocProvider`), der den BLoC bereitstellt, oder er gehört zu einem völlig anderen Zweig des Widget-Baums.

**Lösung:**

1.  **Korrekten `BuildContext` sicherstellen:**
    *   Am häufigsten wird der korrekte Kontext durch einen `Builder`-Widget oder direkt innerhalb der `builder`-Methode eines `BlocBuilder`, `BlocListener` oder `BlocConsumer` erhalten. Dieser Kontext ist garantiert ein Nachkomme des Providers.

    ```dart
    // FALSCH (wenn MyWidget über dem BlocProvider liegt oder der BlocProvider in einem anderen Zweig ist):
    // context.read<MyBloc>();

    // RICHTIG (innerhalb eines Widgets, das unterhalb des BlocProvider liegt):
    BlocBuilder<MyBloc, MyState>(
      builder: (context, state) {
        // Dieser 'context' HAT Zugriff auf MyBloc
        final myBloc = BlocProvider.of<MyBloc>(context);
        // oder
        // final myBloc = context.read<MyBloc>();
        return ElevatedButton(
          onPressed: () => myBloc.add(MyEvent()),
          child: Text('Event senden'),
        );
      },
    )
    ```

2.  **Kontext weitergeben:**
    *   Wenn eine Methode außerhalb des `builder`-Callbacks den BLoC benötigt (z.B. eine separate Methode, die das UI-Layout erstellt), muss der korrekte `BuildContext` an diese Methode übergeben werden.

    ```dart
    class MyWidget extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return BlocProvider(
          create: (_) => MyBloc(),
          child: BlocBuilder<MyBloc, MyState>(
            builder: (builderContext, state) { // builderContext hat Zugriff
              return Column(
                children: [
                  Text('State: $state'),
                  _buildMyButton(builderContext), // Korrekten Kontext weitergeben
                ],
              );
            },
          ),
        );
      }

      Widget _buildMyButton(BuildContext context) { // Kontext empfangen
        return ElevatedButton(
          onPressed: () {
            // Dieser 'context' (ursprünglich builderContext) hat Zugriff
            BlocProvider.of<MyBloc>(context).add(MyEvent());
          },
          child: Text('Aktion'),
        );
      }
    }
    ```

**Faustregel:** Immer den `BuildContext` verwenden, der am tiefsten im Widget-Baum unterhalb des relevanten `BlocProvider` liegt. Wenn `context.findAncestorWidgetOfExactType<BlocProvider<MyBloc>>()` `null` zurückgeben würde, kann der BLoC nicht gefunden werden.

## Schichtenarchitektur

### 1. Präsentationsschicht (UI)

Die Präsentationsschicht besteht aus Flutter-Widgets, die den Zustand darstellen und Benutzerinteraktionen verarbeiten.

```
lib/
├── presentation/
│   ├── screens/          # Vollständige Bildschirme
│   ├── widgets/          # Wiederverwendbare UI-Komponenten
│   └── themes/           # Farbschemata und Stilrichtlinien
```

### 2. Business Logic Schicht

Die Business Logic Schicht verwendet das BLoC-Pattern zur Verwaltung des Zustands und der Spiellogik.

```
lib/
├── blocs/
│   ├── game/             # Spielverwaltung
│   ├── player/           # Spielerverwaltung
│   ├── round/            # Rundenverwaltung  
│   ├── voting/           # Abstimmungssystem
│   └── settings/         # App-Einstellungen
```

### 3. Datenquellen-Schicht

Die Datenquellen-Schicht verwaltet alle Datenoperationen und trennt die Business Logic von der tatsächlichen Datenverarbeitung.

```
lib/
├── data/
│   ├── repositories/     # Daten-Repositories
│   ├── models/           # Datenmodelle
│   ├── sources/          # Datenquellen (lokal/remote)
│   └── providers/        # Daten-Provider
└── core/
    ├── services/         # Allgemeine Dienste
    ├── utils/            # Hilfsfunktionen
    └── constants/        # App-Konstanten
```

## Dependency Injection

Die App verwendet das `get_it`-Paket für Dependency Injection, um lose Kopplung und Testbarkeit zu gewährleisten.

```dart
// Beispiel für Dependency Injection Setup
final GetIt locator = GetIt.instance;

void setupLocator() {
  // Repositories
  locator.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(
      localStorage: locator(),
    ),
  );
  
  // BLoCs
  locator.registerFactory<GameBloc>(
    () => GameBloc(
      gameRepository: locator(),
      wordRepository: locator(),
    ),
  );
}
```

## Navigation

Die App verwendet Flutter Navigator 2.0 mit dem `auto_route`-Paket für deklarative Routing-Definitionen.

```dart
// Beispiel für Routerkonfiguration
@MaterialAutoRouter(
  replaceInRouteName: 'Screen,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashScreen, initial: true),
    AutoRoute(page: HomeScreen),
    AutoRoute(page: GameSetupScreen),
    AutoRoute(page: PlayerRegistrationScreen),
    AutoRoute(page: RoleRevealScreen),
    AutoRoute(page: VotingScreen),
    AutoRoute(page: ResultsScreen),
  ],
)
class $AppRouter {}
```

## Datenfluss und State Management

Der Datenfluss in der App folgt einem unidirektionalen Muster:

1. Benutzer interagiert mit der UI
2. UI sendet Events an BLoCs
3. BLoCs verarbeiten Events und rufen Repositories auf
4. Repositories liefern Daten zurück an BLoCs
5. BLoCs emittieren neuen State
6. UI wird basierend auf neuem State aktualisiert

### Besonderheiten bei Spieleinstellungen

Die Spieleinstellungen werden über mehrere Komponenten hinweg verwaltet:

1. **Persistente Speicherung**: 
   - Einstellungen werden in `SharedPreferences` unter konsistenten Schlüsseln gespeichert
   - Hauptschlüssel: `game_impostor_count`, `game_round_count`, `game_timer_duration`, `game_player_count`

2. **Datenfluss der Einstellungen**:
   ```
   GameSetupScreen → SharedPreferences → GameBloc → Game-Erstellung → RoleRevealScreen → RoundBloc → Rollenzuweisung
   ```

3. **Validierung**: 
   - Grundlegende Validierung stellt sicher, dass impostorCount ≤ playerCount - 2
   - Spezielle Regeln für bestimmte Konfigurationen (z.B. 3 Spione bei 5 Spielern)
   - Beim Ändern der Spieleranzahl wird die Spionanzahl ggf. angepasst

### Debugging und Logging

Die App verwendet strategisches Logging für wichtige Zustandsänderungen und Datenflüsse:

```dart
// Beispiel für Logging zur Nachverfolgung der Einstellungen
print("GameBloc: Loaded settings from SharedPreferences:");
print("- impostorCount = $impostorCount");
```

Für Fehlerdiagnose sind kritische Datenpunkte an wichtigen Stellen im Code markiert:

- Spielerstellungs-Workflow (GameBloc)
- Rollenzuweisungsprozess (RoundBloc)
- Spieleinstellungs-Persistenz (GameSetupScreen)

Ein definiertes Logging-Format erleichtert die Fehlersuche durch Kennzeichnung der Quelle der Nachricht, z.B. `GameBloc:`, `RoundBloc:`, etc.

## Fehlerbehandlung

Die App implementiert eine zentrale Fehlerbehandlungsstrategie mit:

- Domain-spezifischen Exceptions
- Zentralem Fehlerlogger
- Benutzerfreundlichen Fehleranzeigen

## Erweiterung für Mehrspieler (V2)

Die Architektur ist darauf ausgelegt, in der zukünftigen Version nahtlos auf eine Mehrspieler-Implementierung mit Supabase zu erweitern:

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│  Präsentations-   │     │   Business Logic  │     │    Datenquellen   │
│     Schicht       │◄────►        Schicht    │◄────►        Schicht    │
└───────────────────┘     └───────────────────┘     └───────────────────┘
                                                           │
                                                           ▼
                                                    ┌───────────────────┐
                                                    │    Supabase API   │
                                                    └───────────────────┘
```

Diese Erweiterung wird durch zusätzliche Komponenten erreicht:
- Auth Repository für Benutzerverwaltung
- Online Game Repository für Spielsynchronisation
- Realtime Updates über Supabase Realtime

## Schlüsselkomponenten

### Game Manager
Zentraler Koordinator des Spielablaufs

### Player Manager
Verwaltung der Spielerregistrierung und -rollen

### Word Provider
Bereitstellung von Haupt- und Täuschungswörtern

### Vote Controller
Verwaltung des Abstimmungsprozesses

### Score Keeper
Berechnung und Speicherung von Punkten

## Performance-Optimierungen

- Lazy Loading für optimierte Ressourcennutzung
- Effizientes State Management
- Minimierung von Widget-Rebuilds
