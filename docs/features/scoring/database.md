# Database Implementation for Scoring System

## Required Repository Methods

### GameRepository

Add these methods to `GameRepositoryImpl`:

```dart
// Update player score
Future<void> updatePlayerScore(String playerId, int pointsToAdd) async {
  final player = await getPlayerById(playerId);
  if (player == null) return;
  
  final newScore = player.score + pointsToAdd;
  await databaseHelper.update(
    DatabaseConstants.tablePlayers,
    {'score': newScore},
    where: 'id = ?',
    whereArgs: [playerId],
  );
}

// Reset all player scores for a game
Future<void> resetPlayerScores(String gameId) async {
  await databaseHelper.update(
    DatabaseConstants.tablePlayers,
    {'score': 0},
    where: 'game_id = ?',
    whereArgs: [gameId],
  );
}
```

## New Models

### RoundScoreResult

Create `round_score_result.dart` to track score changes per round:

```dart
class RoundScoreResult {
  final String playerId;
  final int pointsAwarded;
  final String reason;
  final DateTime createdAt;

  RoundScoreResult({
    required this.playerId,
    required this.pointsAwarded,
    required this.reason,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'pointsAwarded': pointsAwarded,
    'reason': reason,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
  
  factory RoundScoreResult.fromJson(Map<String, dynamic> json) => RoundScoreResult(
    playerId: json['playerId'],
    pointsAwarded: json['pointsAwarded'],
    reason: json['reason'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}
```

## Updating GameState

Update `GameState` classes to include score information:

```dart
// In game_state.dart
class GameRoundCompleted extends GameState {
  final Game game;
  final int roundNumber;
  final int totalRounds;
  final List<Player> players;
  final Map<String, RoundScoreResult> scoreResults;

  const GameRoundCompleted({
    required this.game,
    required this.roundNumber,
    required this.totalRounds,
    required this.players,
    required this.scoreResults,
  });

  @override
  List<Object> get props => [game, roundNumber, totalRounds, players, scoreResults];
}
```

## Implementation Notes

1. Use transactions for atomicity when updating multiple scores
2. Handle score display edge cases (negative scores, ties, etc.)
3. Initialize all player scores to 0 when creating a new game
