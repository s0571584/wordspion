# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WortSpion is a Flutter-based social deduction game where players try to identify spies among them. Players know a common word while spies receive a similar "deception word." The app uses a single-device mode ideal for group gatherings, with future plans for multiplayer functionality using Supabase.

## Development Commands

### Build & Code Generation
- **Generate routes**: `./build.sh` (Linux/macOS) or `build_routes.bat` (Windows)
  - Runs `flutter pub get` and `flutter packages pub run build_runner build --delete-conflicting-outputs`
  - Required when adding new routes with @RoutePage() annotations
- **Standard Flutter commands**:
  - `flutter pub get` - Install dependencies
  - `flutter run` - Run the app
  - `flutter analyze` - Static analysis
  - `flutter test` - Run tests
  - `flutter build apk` - Build Android APK

### Testing
- Uses `bloc_test` for BLoC testing and `mockito` for mocking
- Widget tests available in `test/` directory

## Architecture & Project Structure

### State Management - BLoC Pattern
The app uses flutter_bloc with clear separation of concerns:
- **BLoCs**: `/lib/blocs/` - Business logic components organized by feature
  - `GameBloc` - Game state and flow management
  - `PlayerBloc` - Player management 
  - `RoundBloc` - Round logic and scoring
  - `VotingBloc` - Voting mechanics
  - `SettingsBloc` - Game configuration
  - `TimerBloc` - Timer functionality
  - `PlayerGroupBloc` - Player group management
- Each BLoC has dedicated event, state, and bloc files

### Data Layer
- **Models**: `/lib/data/models/` - Data entities (Game, Player, Round, etc.)
- **Repositories**: `/lib/data/repositories/` - Data access abstraction
- **Local Storage**: SQLite via `sqflite` with `DatabaseHelper` singleton
- **Word Data**: Static word collections in `/lib/data/sources/local/`

### Dependency Injection
- Uses `get_it` for service location in `/lib/di/injection_container.dart`
- Repositories registered as lazy singletons
- BLoCs registered as factories for fresh instances
- Initialize via `di.init()` in main.dart

### Routing
- **Auto Route**: Uses `auto_route` package for type-safe navigation
- Routes defined in `/lib/core/router/app_router.dart`
- Generated code in `app_router.gr.dart` (requires build_runner)
- All screens require `@RoutePage()` annotation

### UI Structure
- **Screens**: `/lib/presentation/screens/` - Full-screen widgets
- **Widgets**: `/lib/presentation/widgets/` - Reusable UI components
- **Themes**: `/lib/presentation/themes/` - Centralized styling (colors, typography, spacing)
- Uses Material Design with custom `AppTheme.lightTheme`

### Key Services
- **ScoreCalculator**: Game scoring logic in `/lib/core/services/`
- **TimerService**: Round timer management
- **Word Selection Utils**: Category and word management utilities

## Development Notes

### Database Schema
- Relational SQLite design prepared for future PostgreSQL/Supabase migration
- Tables: categories, words, word_relations, games, players, rounds, votes, player_groups
- Version management via `DatabaseConstants.databaseVersion`

### Platform Support
- Cross-platform: Android, iOS, Windows, Linux, macOS
- Desktop platforms use `sqflite_common_ffi`
- Portrait orientation locked via SystemChrome

### Asset Management
- Images: `/assets/images/` with role-specific subdirectories
- Fonts: Montserrat family in `/assets/fonts/`
- Icons: Generated via `flutter_launcher_icons`

### Code Generation Requirements
When adding new routes, models, or changing auto_route annotations:
1. Run the build script to regenerate code
2. Ensure @RoutePage() annotations are properly added to screen classes
3. Import new routes in app_router.dart

### Game Flow Architecture
The app follows a linear flow: Home → Game Setup → Category Selection → Player Registration → Role Reveal → Game Play → Voting → Results. Each screen is managed by its corresponding BLoC, with game state persisted in SQLite.