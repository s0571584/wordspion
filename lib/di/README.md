# Dependency Injection

Dieser Ordner enthält das Setup für Dependency Injection mit dem get_it-Package.

## Zweck

Die Dependency Injection ermöglicht eine lose Kopplung zwischen den verschiedenen Komponenten der App, was die Testbarkeit und Wartbarkeit verbessert.

## Hauptdatei

- `injection_container.dart`: Richtet alle Abhängigkeiten für die App ein

## Verwendung

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
  
  // Services
  locator.registerLazySingleton<TimerService>(
    () => TimerServiceImpl(),
  );
}
```
