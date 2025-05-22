# WortSpion - UI/UX-Spezifikationen

Dieses Dokument beschreibt die UI/UX-Spezifikationen für die WortSpion-App, einschließlich Design-System, UI-Komponenten, Bildschirmdesigns und Benutzerinteraktionen.

## Design-Philosophie

Die WortSpion-App folgt einer spielerischen, aber intuitiven Design-Philosophie, die den sozialen und mysteriösen Charakter des Spiels unterstreicht. Das Design ist darauf ausgelegt, eine angenehme Benutzererfahrung zu bieten, während es gleichzeitig die Spannung und den Spaß des Spiels verstärkt.

### Kernprinzipien
- **Klarheit:** Klare Unterscheidung zwischen verschiedenen Spielphasen und Rollen
- **Zugänglichkeit:** Leicht verständliche UI für alle Altersgruppen
- **Spannung:** Design-Elemente, die das Geheimnis und die Spannung des Spiels unterstützen
- **Geselligkeit:** Förderung der sozialen Interaktion zwischen den Spielern

## Design-System

### Farbpalette

```dart
// colors.dart
class AppColors {
  // Primäre Farben
  static const Color primary = Color(0xFF3F51B5);        // Indigo
  static const Color primaryLight = Color(0xFF757DE8);   // Helles Indigo
  static const Color primaryDark = Color(0xFF002984);    // Dunkles Indigo
  
  // Akzentfarben
  static const Color accent = Color(0xFFFF4081);         // Pink
  static const Color accentLight = Color(0xFFFF79B0);    // Helles Pink
  static const Color accentDark = Color(0xFFC60055);     // Dunkles Pink
  
  // Semantische Farben
  static const Color team = Color(0xFF4CAF50);           // Grün für Team
  static const Color impostor = Color(0xFFF44336);       // Rot für Spione
  
  // Neutralfarben
  static const Color background = Color(0xFFF5F5F5);     // Hintergrund
  static const Color surface = Color(0xFFFFFFFF);        // Oberflächen
  static const Color onSurface = Color(0xFF212121);      // Text auf Oberflächen
  static const Color onBackground = Color(0xFF212121);   // Text auf Hintergrund
  
  // Hilfsfunktionen
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
```

#### Farben nach Kontext
- **Team-Elemente:** Überwiegend Grün (AppColors.team)
- **Spion-Elemente:** Überwiegend Rot (AppColors.impostor)
- **Neutrale Elemente:** Primär- und Akzentfarben

### Typografie

```dart
// typography.dart
class AppTypography {
  static const String fontFamily = 'Montserrat';
  
  // Textstile für verschiedene Zwecke
  static TextStyle get headline1 => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 28.0,
    color: AppColors.onBackground,
  );
  
  static TextStyle get headline2 => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 24.0,
    color: AppColors.onBackground,
  );
  
  static TextStyle get headline3 => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: AppColors.onBackground,
  );
  
  static TextStyle get body1 => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 16.0,
    color: AppColors.onBackground,
  );
  
  static TextStyle get body2 => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    fontSize: 14.0,
    color: AppColors.onBackground,
  );
  
  static TextStyle get button => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16.0,
    letterSpacing: 1.2,
    color: Colors.white,
  );
  
  // Spezialisierte Stile
  static TextStyle get wordDisplay => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    fontSize: 32.0,
    letterSpacing: 1.5,
    color: AppColors.primary,
  );
  
  static TextStyle get timerDisplay => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
    color: AppColors.accent,
  );
  
  static TextStyle get playerName => TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: AppColors.onSurface,
  );
}
```

### Abstände und Größen

```dart
// spacing.dart
class AppSpacing {
  // Standardabstände
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 12.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // Bildschirmränder
  static const EdgeInsets screenPadding = EdgeInsets.all(m);
  static const EdgeInsets cardPadding = EdgeInsets.all(m);
  
  // Komponentenabstände
  static const double buttonHeight = 56.0;
  static const double cardBorderRadius = 12.0;
  static const double inputHeight = 56.0;
}
```

### Schatten und Elevation

```dart
// shadows.dart
class AppShadows {
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 3.0,
      offset: Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16.0,
      spreadRadius: 2.0,
      offset: Offset(0, 8),
    ),
  ];
}
```

## UI-Komponenten

### Allgemeine Komponenten

#### AppButton
```dart
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isExpanded;
  final EdgeInsets padding;
  
  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isExpanded = true,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return isOutlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
              ),
            ),
            child: Text(text, style: AppTypography.button),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: padding,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
              ),
            ),
            child: Text(text, style: AppTypography.button),
          );
  }
}
```

#### PlayerCard
```dart
class PlayerCard extends StatelessWidget {
  final String name;
  final int score;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isImpostor;
  final bool showRole;
  
  const PlayerCard({
    Key? key,
    required this.name,
    this.score = 0,
    this.onTap,
    this.isSelected = false,
    this.isImpostor = false,
    this.showRole = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4.0 : 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        side: isSelected
            ? BorderSide(
                color: showRole && isImpostor
                    ? AppColors.impostor
                    : AppColors.team,
                width: 2.0,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: showRole && isImpostor
                    ? AppColors.impostor
                    : AppColors.primary,
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTypography.playerName),
                    if (showRole)
                      Text(
                        isImpostor ? 'Spion' : 'Teammitglied',
                        style: TextStyle(
                          color: isImpostor
                              ? AppColors.impostor
                              : AppColors.team,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '$score Pkt.',
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### CountdownTimer
```dart
class CountdownTimer extends StatelessWidget {
  final int seconds;
  final bool isRunning;
  final VoidCallback? onFinished;
  
  const CountdownTimer({
    Key? key,
    required this.seconds,
    this.isRunning = true,
    this.onFinished,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRunning ? Icons.timer : Icons.timer_off,
            color: isRunning
                ? seconds > 10
                    ? AppColors.team
                    : AppColors.accent
                : AppColors.onSurface.withOpacity(0.5),
          ),
          SizedBox(width: AppSpacing.s),
          Text(
            '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
            style: AppTypography.timerDisplay.copyWith(
              color: isRunning
                  ? seconds > 10
                      ? AppColors.team
                      : AppColors.accent
                  : AppColors.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### RoleRevealCard
```dart
class RoleRevealCard extends StatelessWidget {
  final bool isImpostor;
  final String word;
  final VoidCallback onContinue;
  
  const RoleRevealCard({
    Key? key,
    required this.isImpostor,
    required this.word,
    required this.onContinue,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
        side: BorderSide(
          color: isImpostor ? AppColors.impostor : AppColors.team,
          width: 3.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isImpostor ? Icons.person_off : Icons.person,
              size: 64.0,
              color: isImpostor ? AppColors.impostor : AppColors.team,
            ),
            SizedBox(height: AppSpacing.m),
            Text(
              isImpostor ? 'DU BIST SPION' : 'DU BIST TEAMMITGLIED',
              style: AppTypography.headline3.copyWith(
                color: isImpostor ? AppColors.impostor : AppColors.team,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              isImpostor ? 'DEIN TÄUSCHUNGSWORT:' : 'DEIN WORT:',
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.s),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
              decoration: BoxDecoration(
                color: isImpostor
                    ? AppColors.impostor.withOpacity(0.1)
                    : AppColors.team.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
                border: Border.all(
                  color: isImpostor ? AppColors.impostor : AppColors.team,
                  width: 2.0,
                ),
              ),
              child: Text(
                word.toUpperCase(),
                style: AppTypography.wordDisplay.copyWith(
                  color: isImpostor ? AppColors.impostor : AppColors.team,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
            AppButton(
              text: 'Verstanden & Weitergeben',
              onPressed: onContinue,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.m,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Bildschirmdesigns

### 1. Startbildschirm
Der Startbildschirm ist das Eingangstor zur App und soll das Spielkonzept visuell vermitteln.

```
┌────────────────────────────────────────┐
│                                        │
│                                        │
│                                        │
│             [App-Logo]                 │
│                                        │
│            "WORTSPION"                 │
│                                        │
│                                        │
│      [Neues Spiel starten Button]      │
│                                        │
│            [Regeln Button]             │
│                                        │
│                                        │
└────────────────────────────────────────┘
```

**Spezifikationen:**
- Hintergrund mit Farbverlauf aus Primärfarben
- Zentral platziertes Logo mit App-Titel
- Große, deutlich sichtbare Buttons
- Optional: Animierter Titeltexteffekt

### 2. Spieleinstellungsbildschirm
Hier können die Spieler alle Aspekte des Spiels konfigurieren.

```
┌────────────────────────────────────────┐
│  ← Zurück         Spieleinstellungen   │
├────────────────────────────────────────┤
│                                        │
│  Spieleranzahl: [Slider: 3-10]         │
│                                        │
│  Spion-Anzahl: [Dropdown: 1-3]         │
│                                        │
│  Rundenanzahl: [Stepper: 1-10]         │
│                                        │
│  Timer-Dauer: [Slider: 30s-5min]       │
│                                        │
│  Kategorien:                           │
│  [✓] Unterhaltung                      │
│  [✓] Sport                             │
│  [ ] Tiere                             │
│  [ ] Essen                             │
│  [ ] Orte                              │
│                                        │
│  Spione kennen sich: [Toggle]          │
│                                        │
│  [Spiel starten Button]                │
│                                        │
└────────────────────────────────────────┘
```

**Spezifikationen:**
- Klare Gruppierung verwandter Einstellungen
- Intuitive Eingabeelemente (Slider, Dropdown, Checkbox)
- Visuelle Rückmeldung bei Änderung von Einstellungen
- Validierung für logische Einschränkungen (z.B. max. Spione)

### 3. Spielerregistrierungsbildschirm
Hier geben die Spieler nacheinander ihre Namen ein.

```
┌────────────────────────────────────────┐
│  ← Zurück         Spieler hinzufügen   │
├────────────────────────────────────────┤
│                                        │
│  Spieler 3 / 6                         │
│                                        │
│  Name eingeben:                        │
│  ┌────────────────────────────────┐    │
│  │ ________                       │    │
│  └────────────────────────────────┘    │
│                                        │
│  Bisherige Spieler:                    │
│  • Anna                                │
│  • Bernd                               │
│                                        │
│                                        │
│  [Spieler hinzufügen Button]           │
│                                        │
│  [Alle Spieler vollständig Button]     │
│                                        │
└────────────────────────────────────────┘
```

**Spezifikationen:**
- Klarer Fortschrittsindikator (X / Y Spieler)
- Tastaturoptimierte Eingabe des Spielernamens
- Liste der bereits eingegebenen Spieler
- Option zum Abschließen, wenn alle Spieler eingegeben wurden

### 4. Rollenanzeigebildschirm
Dieser Bildschirm zeigt jedem Spieler seine Rolle und das entsprechende Wort.

```
┌────────────────────────────────────────┐
│                                        │
│            [Spielername]               │
│                                        │
│            [Rollenanzeige]             │
│                                        │
│                                        │
│                                        │
│                                        │
│                                        │
│             [Wortanzeige]              │
│                                        │
│                                        │
│                                        │
│      [Verstanden & Weitergeben]        │
│                                        │
└────────────────────────────────────────┘
```

**Spezifikationen:**
- Deutliche farbliche Unterscheidung zwischen Team und Spion
- Große, gut lesbare Wortanzeige
- Kein Zurück-Button, um Betrug zu vermeiden
- "Auge-zu"-Button zur Sicherheit, falls jemand anderes zusieht
- Sicherheitstimer, bevor der Weitergeben-Button aktiviert wird

### 5. Diskussionsbildschirm
Hier findet die Diskussion über das Wort statt.

```
┌────────────────────────────────────────┐
│              DISKUSSION                │
├────────────────────────────────────────┤
│                                        │
│  [Timer: 02:30]                        │
│                                        │
│  Spieler:                              │
│  [Spieler 1 Karte]                     │
│  [Spieler 2 Karte]                     │
│  [Spieler 3 Karte]                     │
│  [Spieler 4 Karte]                     │
│  [Spieler 5 Karte]                     │
│  [Spieler 6 Karte]                     │
│                                        │
│                                        │
│  [Diskussion beenden]                  │
│                                        │
└────────────────────────────────────────┘
```

**Spezifikationen:**
- Prominenter Timer für die Diskussionszeit
- Übersicht aller Spieler für einfache Referenz
- Option zum vorzeitigen Beenden der Diskussion

### 6. Abstimmungsbildschirm
Hier stimmen die Spieler über verdächtige Spione ab.

```
┌────────────────────────────────────────┐
│             ABSTIMMUNG                 │
├────────────────────────────────────────┤
│                                        │
│  [Timer: 01:30]                        │
│                                        │
│  Wer ist der Spion?                    │
│                                        │
│  [Spieler 1 Karte]                     │
│  [Spieler 2 Karte] ← ausgewählt        │
│  [Spieler 3 Karte]                     │
│  [Spieler 4 Karte]                     │
│  [Spieler 5 Karte]                     │
│  [Spieler 6 Karte]                     │
│                                        │
│                                        │
│          [Stimme abgeben]              │
│                                        │
└────────────────────────────────────────┘
```

**Spezifikationen:**
- Klar strukturierte Liste aller Spieler
- Visuelles Feedback bei Auswahl eines Spielers
- Prominenter Timer für die verbleibende Abstimmungszeit
- Bestätigungsschritt vor der endgültigen Abstimmung

### 7. Ergebnisbildschirm
Dieser Bildschirm zeigt die Ergebnisse der Runde und den Punktestand.

```
┌────────────────────────────────────────┐
│             RUNDENERGEBNIS             │
├────────────────────────────────────────┤
│                                        │
│  [Team gewonnen / Spione gewonnen]     │
│                                        │
│  Spione waren:                         │
│  • [Spieler X]                         │
│  • [Spieler Y]                         │
│                                        │
│  Das Wort war: [Hauptwort]             │
│                                        │
│  Punktestand:                          │
│  • Anna: 5 Punkte (+2)                 │
│  • Bernd: 2 Punkte (-1)                │
│  • ...                                 │
│                                        │
│         [Nächste Runde]                │
│                                        │
└────────────────────────────────────────┘
```

**Spezifikationen:**
- Klare visuelle Darstellung, welche Seite gewonnen hat
- Auflistung aller Spione und des Hauptworts
- Detaillierter Punktestand mit Änderungen
- Bei letzter Runde: Spielende-Schirm mit Gesamtsieger

## Responsive Design

Die App ist für verschiedene Bildschirmgrößen optimiert:

1. **Smartphones (360dp - 480dp):**
   - Gestapeltes Layout mit voller Bildschirmbreite
   - Angepasste Schriftgrößen für kleinere Displays
   - Reduzierte Abstände bei engen Bildschirmen

2. **Große Smartphones / Kleine Tablets (480dp - 720dp):**
   - Optimierte Komponentengrößen
   - Zwei-Spalten-Layout bei horizontaler Ausrichtung
   - Verbesserte Platznutzung

3. **Tablets (720dp+):**
   - Multi-Spalten-Layout für effiziente Raumnutzung
   - Größere Touch-Targets und Schriftgrößen
   - Optimierte Spielerlistenansicht bei vielen Spielern

## Animationen und Übergänge

Die App verwendet gezielte Animationen zur Verbesserung der Benutzererfahrung:

1. **Seitenübergänge:**
   - Fade-Übergang beim Wechsel zwischen Hauptbildschirmen
   - Slide-Übergang bei sequentiellen Bildschirmen

2. **Feedback-Animationen:**
   - Pulsieren des ausgewählten Spielers bei Abstimmung
   - Farbwechsel-Animation bei Rollenaufdeckung
   - Timer-Animation mit Farbübergang bei letzten 10 Sekunden

3. **Mikro-Interaktionen:**
   - Subtile Skalierungsanimation bei Button-Taps
   - Ripple-Effekt bei Listenauswahl
   - Eingabefeld-Animation beim Fokussieren

## Barrierefreiheit

Die App implementiert folgende Barrierefreiheitsmerkmale:

1. **Farbkontrast:**
   - Alle Text-/Hintergrund-Kombinationen erfüllen WCAG AA-Standard
   - Alternatives Farbschema für Farbenblindheit

2. **Screenreader-Unterstützung:**
   - Semantische Widgets mit accessibility-Labels
   - Geeignete Fokusreihenfolge
   - Statusänderungen werden per TalkBack/VoiceOver angekündigt

3. **Bedienbarkeit:**
   - Ausreichend große Touch-Targets (min. 48x48 dp)
   - Möglichkeit, Timer zu verlängern
   - Optionale größere Schrift

## App-Assets

### Icons und Logo
- App-Icon in verschiedenen Auflösungen (adaptive Icons für Android)
- Spiellogo für Startbildschirm und Marketing
- Funktionale Icons für Navigation und Aktionen

### Schriftarten
- Montserrat als Hauptschriftart (Regular, Medium, Bold, Extra Bold)
- Einbettung der benötigten Schriftschnitte zur Größenoptimierung

## Implementierungsrichtlinien

1. **Wiederverwendbarkeit:**
   - Alle UI-Komponenten als eigene Widgets mit anpassbaren Parametern
   - Gemeinsame Stil-Variablen für konsistentes Design

2. **Leistungsoptimierung:**
   - Verwendung von `const` Widgets wo immer möglich
   - Minimierung von Widget-Rebuilds
   - Effizientes Ressourcenmanagement

3. **Code-Organisation:**
   - Separate Dateien für jede Hauptkomponente
   - Gemeinsame Design-Tokens in zentralen Dateien
   - Klare Trennung zwischen Präsentation und Logik

4. **Testbarkeit:**
   - Semantische Widgets für Widget-Tests
   - Testbare UI-Logik durch Trennung von Zustand und Darstellung

## Übergang zur Mehrspieler-Version (V2)

Für die zukünftige Mehrspieler-Version werden folgende UI/UX-Anpassungen vorgenommen:

1. **Zusätzliche Bildschirme:**
   - Login/Registrierungsbildschirm
   - Spielraum-Erstellungsbildschirm
   - Spielraum-Beitrittsbildschirm
   - Wartezimmer für Spielraum

2. **Online-Status-Indikatoren:**
   - Netzwerkstatusanzeige
   - Spielerpräsenzindikatoren
   - Verbindungsqualitätsanzeige

3. **Mehrspieler-spezifische UI-Elemente:**
   - Chatfunktion für die Lobby
   - Einladungslinks für Spielräume
   - Spielerprofile mit Statistiken

4. **Übergangsansatz:**
   - Beibehaltung des grundlegenden Design-Systems
   - Erweiterung ohne Änderung der bestehenden Kernkomponenten
   - Schrittweise Integration der Mehrspieler-Funktionen

---

Diese UI/UX-Spezifikationen bilden einen umfassenden Leitfaden für die visuelle und interaktive Gestaltung der WortSpion-App. Die beschriebenen Komponenten, Layouts und Designrichtlinien gewährleisten ein konsistentes, intuitives und ansprechendes Benutzererlebnis.
