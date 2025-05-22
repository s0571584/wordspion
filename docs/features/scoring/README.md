# WortSpion Multi-Round Scoring System

## Overview

The scoring system tracks player points across multiple rounds, determining a winner at the game's end.

## Core Functionality

- Track scores per player across rounds
- Award points based on game outcomes
- Display running scores between rounds
- Show final results with winner

## Point System Rules

| Player Type | Condition | Points |
|-------------|-----------|--------|
| Team Member | Team identifies all spies | +2 |
| Team Member | Falsely accused as spy | -1 |
| Spy | At least one spy undetected | +3 |
| Spy | Correctly guesses main word | +2 (additional) |

## Implementation Components

1. **Database Layer**: 
   - Player score tracking
   - Round results storage

2. **Logic Layer**:
   - Score calculation service
   - Round completion handling

3. **UI Components**:
   - Round results screen
   - Final results screen

4. **Navigation Flow**:
   - Multi-round progression
   - Game completion handling

## Additional Documentation

- [Database Implementation](./database.md)
- [UI Components](./ui_components.md)
- [Implementation Workflow](./workflow.md)
