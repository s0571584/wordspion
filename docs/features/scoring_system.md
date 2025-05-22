# Multi-Round Scoring System Documentation Index

The following documentation describes the implementation of the multi-round scoring system for WortSpion.

## Documentation Files

- [Overview](./scoring/README.md) - Core concepts and rules
- [Database Implementation](./scoring/database.md) - Repository and model changes
- [UI Components](./scoring/ui_components.md) - New screens and UI elements
- [Implementation Workflow](./scoring/workflow.md) - Step-by-step implementation guide
- [Score Calculator](./scoring/score_calculator.md) - Score calculation logic details

## Implementation Summary

The multi-round scoring system tracks player scores across multiple rounds with the following key features:

1. **Point System**:
   - Team members: +2 points for identifying all spies
   - Team members: -1 point if falsely accused
   - Spies: +3 points for remaining undetected
   - Spies: +2 additional points for guessing the main word

2. **New UI Screens**:
   - Round Results Screen: Shows outcome and scores after each round
   - Final Results Screen: Displays the winner and final rankings

3. **Workflow**:
   - Calculate scores after voting (or skipping)
   - Show round results
   - Continue to next round or show final results
   - Determine winner based on total points

## Getting Started

To implement the scoring system:

1. Start with the ScoreCalculator service
2. Update the database models and repositories
3. Modify the Round and Game BLoCs
4. Create the UI components
5. Update the navigation flow

Refer to individual documentation files for detailed implementation instructions.
