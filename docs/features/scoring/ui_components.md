# UI Components for Scoring System

## New Screen Components

### 1. RoundResultsScreen

Displays results after each round including score changes.

**Key Components:**
- Round outcome display (who won)
- Secret word reveal
- Individual player scores with point changes
- Navigation button to next round

**Implementation Location:**
- Create `lib/presentation/screens/round_results_screen.dart`

**Sample Implementation:**

```dart
@RoutePage()
class RoundResultsScreen extends StatelessWidget {
  final String gameId;
  final int currentRound;
  final int totalRounds;
  final Map<String, RoundScoreResult> roundScores;
  final bool impostorsWon;
  final String secretWord;
  
  // Constructor
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Runde $currentRound von $totalRounds'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Round outcome card
          _buildOutcomeCard(),
          
          // Player scores list with point changes
          _buildScoresList(),
          
          // Next round/Results button
          _buildNavigationButton(),
        ],
      ),
    );
  }
  
  // Helper methods
}
```

### 2. FinalResultsScreen

Shows final game results with winner and rankings.

**Key Components:**
- Winner announcement with highlight
- Ranked player list with scores
- Game restart options

**Implementation Location:**
- Create `lib/presentation/screens/final_results_screen.dart`

## Required UI Elements

### Score Change Indicator

Visual component showing point change:

```dart
Widget buildScoreChange(int points) {
  final color = points > 0 
      ? Colors.green.shade100 
      : (points < 0 ? Colors.red.shade100 : Colors.grey.shade100);
  
  final textColor = points > 0 
      ? Colors.green.shade800 
      : (points < 0 ? Colors.red.shade800 : Colors.grey.shade800);
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      points >= 0 ? '+$points' : '$points',
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
```

### Winner Card

Special card for highlighting the winner:

```dart
Widget buildWinnerCard(Player winner) {
  return Card(
    elevation: 8,
    color: Colors.amber.shade50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.amber.shade300, width: 2),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('🏆 Gewinner 🏆', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(winner.name, style: Theme.of(context).textTheme.headlineMedium),
          Text('${winner.score} Punkte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
```

## Navigation Configuration

Add routes in `app_router.dart`:

```dart
@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    // Existing routes...
    
    AutoRoute(
      page: RoundResultsRoute.page,
      path: '/round-results',
    ),
    
    AutoRoute(
      page: FinalResultsRoute.page,
      path: '/final-results',
    ),
  ];
}
```
