# Data Layer

Dieser Ordner enthält alle datenbezogenen Komponenten der WortSpion-App.

## Struktur

- `models/`: Datenmodelle der App
- `repositories/`: Repository-Klassen, die als Schnittstelle zwischen BLoCs und Datenquellen dienen
- `sources/`: Konkrete Implementierungen der Datenquellen (lokal, remote)

Die Datenebene ist für das Laden, Speichern und Verwalten aller App-Daten verantwortlich. Sie abstrahiert die Details der Datenspeicherung von der Geschäftslogik.
