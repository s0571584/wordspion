# WortSpion

WortSpion ist ein soziales Deduktionsspiel, bei dem Spieler ein gemeinsames Wort kennen, während Spione (Impostoren) versuchen, unentdeckt zu bleiben und das Hauptwort zu erraten.

## Überblick

In WortSpion erstellt ein Spielleiter eine Spielrunde, in der es ein geheimes Wort zu erraten gibt. Alle regulären Spieler kennen dieses Wort, während die Spione ein ähnliches "Täuschungswort" erhalten. Nach einer Diskussionsrunde stimmen die Spieler darüber ab, wer ein Spion sein könnte. Die Spione gewinnen, wenn sie unentdeckt bleiben oder das Hauptwort erraten können.

## Hauptfunktionen

- **Einzelgerät-Modus**: Spiel auf einem gemeinsam genutzten Gerät, ideal für gesellige Runden
- **Anpassbare Spieleinstellungen**: Konfigurierbare Anzahl von Spielern, Spionen, Runden und Timer-Dauer
- **Vielfältige Kategorien**: Verschiedene Themenbereiche wie Unterhaltung, Sport, Tiere und mehr
- **Punktesystem**: Verfolgen Sie Punkte über mehrere Runden
- **Spieler-Gruppen**: Speichern und verwalten Sie vordefinierte Gruppen von Spielern für schnelleres Spielen
- **Offline-Spielbarkeit**: Kein Internet erforderlich für die Basisversion
- **Zukünftige Mehrspieler-Version**: Vorbereitet für zukünftige Implementierung mit Supabase

## Technologie

- **Frontend**: Flutter/Dart
- **Architektur**: BLoC Pattern für State Management
- **Lokale Datenbank**: SQLite (relationale DB für einfachen Übergang zu PostgreSQL/Supabase)
- **Zukunft**: Supabase für Mehrspieler-Funktionalität

## Projektstruktur

Das Projekt enthält folgende Dokumentationsordner:

- `docs/architecture/`: Informationen zur App-Architektur
- `docs/database/`: Datenbankschema und Datenverwaltung
- `docs/features/`: Detaillierte Beschreibungen der Spielfunktionen
- `docs/roadmap/`: Entwicklungsplan und Meilensteine
- `docs/testing/`: Teststrategie und -pläne
- `docs/ui/`: UI/UX-Spezifikationen

## Spieler-Gruppen Funktion

Die Spieler-Gruppen Funktion ermöglicht es, vordefinierte Gruppen von Spielernamen zu speichern und zu verwalten:

- **Gruppenverwaltung**: Erstellen, bearbeiten und löschen von Spielergruppen
- **Schnellstart**: Starten Sie ein neues Spiel direkt mit einer gespeicherten Gruppe
- **Persistenz**: Gruppen werden in der lokalen SQLite-Datenbank gespeichert
- **Einstellungsübernahme**: Anwendung der zuletzt verwendeten Spieleinstellungen beim Starten mit einer Gruppe
- **Nahtlose Integration**: Zugriff auf Gruppen direkt im Hauptmenü der App

Die Einstellungen für Spiele werden automatisch über die App-Sessions hinweg gespeichert, sodass Sie beim nächsten Spiel mit den gleichen Einstellungen wie zuvor beginnen können.

## Entwicklungsphase

Das Projekt befindet sich aktuell in der Planungsphase. Die erste Version wird ein Einzelgerät-Spiel sein, während eine zukünftige Version die Mehrspieler-Funktionalität mit Supabase implementieren wird.

## Lizenz

Proprietär - Alle Rechte vorbehalten
