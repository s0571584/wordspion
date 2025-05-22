# Implementation Workflow

This document outlines the implementation workflow for the multi-round scoring system.

## Implementation Process

### 1. ScoreCalculator Service

First, create a service to calculate player scores:

```dart
// lib/core/services/score_calculator.dart
class ScoreCalculator {
  static Map<String, RoundScoreResult> calculateRoundScores({
    required List<PlayerRoleInfo> playerRoles,
    required Player? votedOutPlayer,
    required bool wordGuessed,
    required String wordGuesserId,
  }) {
    // Implementation of scoring logic
    // Returns map of player IDs to score results
  }
}
```

### 2. Update Round Completion Flow

Modify `RoundBloc` to include score calculation when completing a round:

```dart
// In round_bloc.dart - _onCompleteRound method
Future<void> _onCompleteRound(CompleteRound event, Emitter<RoundState> emit) async {
  // Existing code...
  
  // Calculate scores
  final scoreResults = ScoreCalculator.calculateRoundScores(
    playerRoles: playerRoles,
    votedOutPlayer: event.votedOutPlayer,
    wordGuessed: event.wordGuessed,
    wordGuesserId: event.wordGuesserId ?? '',
  );
  
  // Update player scores in database
  for (final result in scoreResults.values) {
    await gameRepository.updatePlayerScore(result.playerId, result.pointsAwarded);
  }
  
  // Include score results in emitted state
  emit(RoundComplete(
    // Existing params...
    scoreResults: scoreResults,
  ));
}
```

### 3. Update GameBloc

Modify `GameBloc` to handle multi-round flow:

```dart
// In game_bloc.dart - Update _onCompleteRound handler
if (event.roundNumber >= game.roundCount) {
  // Final round - show final results
  await gameRepository.updateGameState(game.id, DatabaseConstants.gameStateFinished);
  emit(GameCompleted(/* with winner info */));
} else {
  // Intermediate round - prepare next round
  await gameRepository.updateCurrentRound(game.id, event.roundNumber + 1);
  emit(GameRoundCompleted(/* with score info */));
}
```

### 4. UI Implementation

Create screens in following order:

1. RoundResultsScreen - showing one round's results
2. FinalResultsScreen - showing game winner

### 5. Update Navigation

Modify VotingScreen to navigate to RoundResultsScreen instead of directly to next round:

```dart
// In voting_screen.dart
if (roundState is RoundComplete) {
  context.router.replace(RoundResultsRoute(
    gameId: widget.gameId,
    currentRound: game.currentRound,
    totalRounds: game.roundCount,
    roundScores: roundState.scoreResults,
    impostorsWon: roundState.impostorsWon,
    secretWord: roundState.secretWord,
  ));
}
```

## Game Flow Diagram

```
┌────────────┐       ┌────────────┐       ┌─────────────┐       ┌────────────┐
│  Game      │       │  Role      │       │  Game Play  │       │  Voting    │
│  Setup     ├───────►  Reveal    ├───────►  Screen     ├───────►  Screen    │
└────────────┘       └────────────┘       └─────────────┘       └──────┬─────┘
                                                                        │
     ┌────────────────────────────────────────────────────────────────┐ │
     │                                                                │ │
     ▼                                                                │ ▼
┌────────────┐       ┌────────────┐       ┌─────────────┐       ┌────────────┐
│  Final     │       │  Role      │◄──────┤  Round      │◄──────┤  Round     │
│  Results   │       │  Reveal    │       │  Setup      │       │  Results   │
└────────────┘       └────────────┘       └─────────────┘       └────────────┘
```

## Testing Checklist

- [ ] Score calculation logic works with all scenarios
- [ ] Player scores persist between rounds
- [ ] Navigation flow works correctly
- [ ] UI displays score changes clearly
- [ ] Final winner determination is correct
- [ ] Edge cases (ties, negative scores) handled properly

## Implementation Notes

1. When skipping voting (using the "Skip to Results" button), award points as if impostors won
2. Initialize all player scores to 0 when creating a new game
3. Score calculation should happen exactly once per round
