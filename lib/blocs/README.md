# Business Logic Layer (BLoCs)

Dieser Ordner enthält alle BLoC (Business Logic Component) Klassen der WortSpion-App.

## Struktur

- `game/`: BLoCs zur Verwaltung des Spielzustands
- `player/`: BLoCs zur Verwaltung der Spielerdaten
- `round/`: BLoCs zur Verwaltung der Rundeninformationen
- `voting/`: BLoCs zur Verwaltung des Abstimmungssystems
- `settings/`: BLoCs zur Verwaltung der App-Einstellungen

Jedes Feature hat typischerweise drei Dateien:
- `[feature]_bloc.dart`: Die BLoC-Klasse mit der Hauptlogik
- `[feature]_event.dart`: Events, die an den BLoC gesendet werden
- `[feature]_state.dart`: Verschiedene Zustände, die der BLoC emittieren kann

Die BLoCs verarbeiten Events, führen die Business-Logik aus und emittieren neue States, die dann in der UI angezeigt werden.
