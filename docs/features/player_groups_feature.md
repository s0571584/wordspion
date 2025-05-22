# Feature Plan: Player Groups

**Version:** 1.0
**Date:** 2024-07-29

## 1. Goal

To allow users to save and manage predefined groups of player names, enabling them to quickly start new games with recurring sets of players without re-typing names each time.

## 2. Database Schema Enhancements

Two new tables will be added to the SQLite database (`lib/data/sources/local/database_helper.dart` will need to be updated with these schema definitions and in its `onCreate` method).

### 2.1. `player_groups` Table

Stores the player groups.

```sql
CREATE TABLE player_groups (
  id TEXT PRIMARY KEY,
  group_name TEXT NOT NULL UNIQUE, -- Group names should be unique for easier identification
  created_at INTEGER NOT NULL
);
```

### 2.2. `player_group_members` Table

Stores the player names associated with each group.

```sql
CREATE TABLE player_group_members (
  id TEXT PRIMARY KEY,
  group_id TEXT NOT NULL,
  player_name TEXT NOT NULL,
  -- player_order INTEGER, -- Optional: if we want to maintain a specific order. For now, not critical.
  FOREIGN KEY (group_id) REFERENCES player_groups(id) ON DELETE CASCADE -- Ensure members are deleted if group is deleted
);

-- Optional: Index for faster retrieval of members for a group
CREATE INDEX idx_player_group_members_group_id ON player_group_members(group_id);
```

## 3. Data Models (Dart)

Corresponding Dart models will be created in `lib/data/models/`.

### 3.1. `player_group.dart`

```dart
import 'package:equatable/equatable.dart';

class PlayerGroup extends Equatable {
  final String id;
  final String groupName;
  final DateTime createdAt;
  final List<String> playerNames; // Embedded for convenience

  const PlayerGroup({
    required this.id,
    required this.groupName,
    required this.createdAt,
    required this.playerNames,
  });

  @override
  List<Object?> get props => [id, groupName, createdAt, playerNames];

  // Placeholder for factory PlayerGroup.fromMap(Map<String, dynamic> map, List<String> names)
  // Placeholder for Map<String, dynamic> toMap() for player_groups table (excluding playerNames)
  // Placeholder for copyWith
}
```

### 3.2. `player_group_member.dart` (Primarily for repository internal use if `PlayerGroup` embeds names)

If `PlayerGroup` directly contains `List<String> playerNames` fetched by a JOIN or separate query, a dedicated `PlayerGroupMember` model for BLoC/UI state might not be strictly necessary, but the repository will handle the `player_group_members` table.

## 4. Repository Layer

A new repository, `PlayerGroupRepository`, or extensions to `GameRepository`. For clarity, a new repository is often cleaner.

File: `lib/data/repositories/player_group_repository.dart` (Interface)
File: `lib/data/repositories/player_group_repository_impl.dart` (Implementation)

### 4.1. `PlayerGroupRepository` Interface

```dart
import 'package:wortspion/data/models/player_group.dart';

abstract class PlayerGroupRepository {
  Future<List<PlayerGroup>> getAllPlayerGroups();
  Future<PlayerGroup> createPlayerGroup({required String groupName, required List<String> playerNames});
  Future<PlayerGroup> updatePlayerGroup({required String groupId, required String newGroupName, required List<String> newPlayerNames});
  Future<void> deletePlayerGroup({required String groupId});
  // getPlayerNamesForGroup might not be needed if PlayerGroup model includes them
}
```

### 4.2. Implementation Details (`PlayerGroupRepositoryImpl`)

*   Uses `DatabaseHelper` for DB operations.
*   `createPlayerGroup`: Inserts into `player_groups`, then iterates `playerNames` to insert into `player_group_members`. Uses a transaction.
*   `getAllPlayerGroups`: Fetches all groups from `player_groups`. For each group, fetches its members from `player_group_members` and populates the `playerNames` list in the `PlayerGroup` object.
*   `updatePlayerGroup`: Updates `group_name` in `player_groups`. Deletes existing members for the `group_id` from `player_group_members` and inserts the `newPlayerNames`. Uses a transaction.
*   `deletePlayerGroup`: Deletes from `player_groups` (CASCADE should handle `player_group_members`).

## 5. BLoC Layer

A new BLoC for managing player group state.

File: `lib/blocs/player_group/player_group_bloc.dart`
File: `lib/blocs/player_group/player_group_event.dart`
File: `lib/blocs/player_group/player_group_state.dart`

### 5.1. `PlayerGroupEvent`

```dart
abstract class PlayerGroupEvent extends Equatable {
  const PlayerGroupEvent();
  @override
  List<Object> get props => [];
}

class LoadPlayerGroups extends PlayerGroupEvent {}
class AddPlayerGroup extends PlayerGroupEvent {
  final String groupName;
  final List<String> playerNames;
  const AddPlayerGroup({required this.groupName, required this.playerNames});
  // Props
}
class UpdatePlayerGroup extends PlayerGroupEvent {
  final String groupId;
  final String newGroupName;
  final List<String> newPlayerNames;
  const UpdatePlayerGroup({required this.groupId, required this.newGroupName, required this.newPlayerNames});
  // Props
}
class DeletePlayerGroup extends PlayerGroupEvent {
  final String groupId;
  const DeletePlayerGroup({required this.groupId});
  // Props
}
```

### 5.2. `PlayerGroupState`

```dart
abstract class PlayerGroupState extends Equatable {
  const PlayerGroupState();
  @override
  List<Object> get props => [];
}

class PlayerGroupsInitial extends PlayerGroupState {}
class PlayerGroupsLoading extends PlayerGroupState {}
class PlayerGroupsLoaded extends PlayerGroupState {
  final List<PlayerGroup> groups;
  const PlayerGroupsLoaded(this.groups);
  // Props
}
class PlayerGroupOperationSuccess extends PlayerGroupState {
  // final String message; // Optional: for snackbars
  // const PlayerGroupOperationSuccess(this.message);
}
class PlayerGroupError extends PlayerGroupState {
  final String message;
  const PlayerGroupError(this.message);
  // Props
}
```

### 5.3. `PlayerGroupBloc`

*   Takes `PlayerGroupRepository` as a dependency.
*   Handles events by calling repository methods and emitting appropriate states.
*   After add/update/delete operations resulting in `PlayerGroupOperationSuccess`, it should re-dispatch `LoadPlayerGroups` to refresh the list.

## 6. UI/UX Changes

### 6.1. `HomeScreen` (`lib/presentation/screens/home_screen.dart`)

*   Add a new button: "Mit Gruppe spielen" (Play with Group) or "Gespeicherte Gruppen".
*   This button navigates to the new `PlayerGroupsScreen`.
    ```dart
    // Example modification in _buildGameButtons or similar
    OutlinedButton( // Or ElevatedButton
      onPressed: () {
        context.router.push(const PlayerGroupsRoute()); // New route
      },
      child: const Text('Mit Gruppe spielen'),
    ),
    ```

### 6.2. `PlayerGroupsScreen` (New Screen)

*   Route: `/player-groups`
*   AppBar Title: "Spieler Gruppen"
*   Displays a list of saved player groups (`PlayerGroupBloc` -> `PlayerGroupsLoaded`).
    *   Each item shows: `group.groupName` and number of players (e.g., "Team Awesome (4 Spieler)").
    *   Each item has:
        *   A "Spiel starten" (Start Game) button.
        *   An "Edit" icon/button -> navigates to `CreateEditPlayerGroupScreen` with group ID.
        *   A "Delete" icon/button -> shows confirmation dialog, then dispatches `DeletePlayerGroup`.
*   A FloatingActionButton (FAB) or button to "Neue Gruppe erstellen" (Create New Group) -> navigates to `CreateEditPlayerGroupScreen` (without a group ID, for creation mode).
*   Handles `PlayerGroupsLoading`, `PlayerGroupsLoaded` (empty state if no groups), and `PlayerGroupError` states.

### 6.3. `CreateEditPlayerGroupScreen` (New Screen)

*   Route: `/create-edit-player-group` (takes optional `groupId` parameter).
*   AppBar Title: "Gruppe erstellen" or "Gruppe bearbeiten".
*   Form fields:
    *   Text field for `groupName`.
    *   A dynamic list of text fields for `playerNames` (similar to `PlayerRegistrationScreen`'s player name input: add/remove player name fields). Minimum 3-4 players per group.
*   "Speichern" (Save) button:
    *   Validates inputs.
    *   If creating: dispatches `AddPlayerGroup`.
    *   If editing: dispatches `UpdatePlayerGroup`.
*   On success (`PlayerGroupOperationSuccess`), navigates back to `PlayerGroupsScreen`.
*   Handles loading state from `PlayerGroupBloc` if pre-filling for edit.

## 7. Game Start Flow with Groups ("Spiel starten" Button)

This describes the "Quick Start" approach:

1.  User taps "Spiel starten" for a group on `PlayerGroupsScreen`.
2.  The `PlayerGroup` object (containing `playerNames`) is available in the UI.
3.  A new event is dispatched to `GameBloc` (or `PlayerBloc`, needs decision):
    `CreateGameFromGroup(PlayerGroup group, GameSettings settings)`
    *   `GameSettings` could be default, or we could navigate to a quick `GameSetupScreen` pre-filled and just needing confirmation/minor tweaks. For true "quick start", default settings are faster.
4.  `GameBloc` (`_onCreateGameFromGroup` handler):
    a.  Creates a new `Game` entity with default settings (or provided settings) and player count from `group.playerNames.length`.
    b.  For each `playerName` in `group.playerNames`:
        i.  Calls `gameRepository.addPlayer(gameId: newGame.id, name: playerName)`.
    c.  Emits `GameCreated` (or a new state like `GameFromGroupReady`).
    d.  The UI listening to `GameBloc` (e.g., a global listener or one on `PlayerGroupsScreen`) then navigates to the next step, likely `RoleRevealRoute` (as players are now registered and game is set up).

## 8. Dependency Injection

*   Register `PlayerGroupRepository` and `PlayerGroupBloc` in `lib/di/injection_container.dart`.

## 9. Routing

*   Add new routes for `PlayerGroupsScreen` and `CreateEditPlayerGroupScreen` in `lib/core/router/app_router.dart`.

## 10. Implementation Phases (Roadmap for this Feature)

1.  **Phase 1: Data Layer & Core Models**
    *   [X] Define/Update `database_helper.dart` with new table schemas. Increment DB version.
    *   [X] Implement `player_group.dart` model.
    *   [X] Implement `PlayerGroupRepository` interface and `PlayerGroupRepositoryImpl` (initially with `createPlayerGroup` and `getAllPlayerGroups`). (Extended to include delete and update)

2.  **Phase 2: BLoC Layer**
    *   [X] Implement `PlayerGroupBloc`, `PlayerGroupEvent`, `PlayerGroupState`.
    *   [X] Wire `PlayerGroupBloc` to use `PlayerGroupRepository`. (Handlers for Load, Add, Delete, Update implemented)

3.  **Phase 3: UI - Group Listing & Creation**
    *   [X] Add new routes to `app_router.dart`.
    *   [X] Implement `PlayerGroupsScreen` (listing groups, FAB for new group).
    *   [X] Implement `CreateEditPlayerGroupScreen` (for creating new groups).
    *   [X] Integrate screens with `PlayerGroupBloc` (dispatch `LoadPlayerGroups`, `AddPlayerGroup`). (Delete also integrated)
    *   [X] Modify `HomeScreen` to add navigation to `PlayerGroupsScreen`.

4.  **Phase 4: UI & Logic - "Start Game with Group"**
    *   [X] Decide on `GameBloc` vs. `PlayerBloc` for handling `CreateGameFromGroup`. (GameBloc chosen)
    *   [X] Implement `CreateGameFromGroup` event and handler in the chosen BLoC.
    *   [X] Add "Spiel starten" button logic in `PlayerGroupsScreen` to dispatch this event.
    *   [X] Ensure navigation flow to `RoleRevealRoute` (or intermediate setup screen if chosen).

5.  **Phase 5: Enhancements & Polish**
    *   [ ] Implement "Edit Group" functionality in `PlayerGroupsScreen` and `CreateEditPlayerGroupScreen`. (Repo & Bloc done, UI next)
    *   [X] Implement "Delete Group" functionality in `PlayerGroupsScreen` (with confirmation).
    *   [ ] Add error handling and user feedback (snackbars for success/error). (Partially done)
    *   [ ] UI Polish, empty states, loading indicators. (Ongoing)
    *   [ ] Review and refactor. (Ongoing)

## 11. Future Considerations (Optional)

*   Sharing groups (if multiplayer is added).
*   Max number of groups per user.
*   Allowing selection of default game settings per group. 

## 12. Common Implementation Issues

When implementing this feature or similar features that use BLoC pattern with multiple screens, be aware of the following common issues:

### 12.1. Provider Registration
- **Issue:** Forgetting to register new BLoCs and repositories in the dependency injection container.
- **Solution:** Always register new BLoCs and repositories in `lib/di/injection_container.dart`:
  ```dart
  // Register repositories
  sl.registerLazySingleton<PlayerGroupRepository>(
    () => PlayerGroupRepositoryImpl(databaseHelper: sl()),
  );
  
  // Register BLoCs
  sl.registerFactory<PlayerGroupBloc>(
    () => PlayerGroupBloc(playerGroupRepository: sl()),
  );
  ```

### 12.2. Provider Context Issues
- **Issue:** Getting `ProviderNotFoundException` when trying to access a BlocProvider from the wrong context.
- **Typical Error:** `Error: Could not find the correct Provider<PlayerGroupBloc> above this Widget`
- **Solutions:**
  1. Always wrap screens that use BLoCs with their own BlocProvider, even when navigating from a screen that has the same BlocProvider:
     ```dart
     @override
     Widget build(BuildContext context) {
       return BlocProvider(
         create: (context) => sl<PlayerGroupBloc>(),
         child: Scaffold(
           // Screen content
         ),
       );
     }
     ```
  
  2. Use MultiBlocProvider when a screen needs access to multiple BLoCs:
     ```dart
     return MultiBlocProvider(
       providers: [
         BlocProvider(
           create: (context) => sl<PlayerGroupBloc>()..add(LoadPlayerGroups()),
         ),
         BlocProvider(
           create: (context) => sl<GameBloc>(),
         ),
       ],
       child: Scaffold(
         // Screen content
       ),
     );
     ```
  
  3. When accessing a BlocProvider in event handlers or callbacks, use a Builder or get access to the correct context:
     ```dart
     // Incorrect - using the wrong context
     ElevatedButton(
       onPressed: _submitForm,  // This may use the wrong context inside
       child: Text('Submit'),
     ),
     
     // Correct - passing the correct context
     Builder(
       builder: (builderContext) => ElevatedButton(
         onPressed: () => _submitForm(builderContext),
         child: Text('Submit'),
       ),
     ),
     ```

### 12.3. BlocListener Access
- **Issue:** BlocListener not finding the BlocProvider because it's in a different part of the widget tree.
- **Solution:** Make sure BlocListener is a child of BlocProvider with the same type:
  ```dart
  BlocProvider<SomeBloc>(
    create: (context) => sl<SomeBloc>(),
    child: BlocListener<SomeBloc, SomeState>(
      listener: (context, state) {
        // Handle state changes
      },
      child: // Your UI widgets
    ),
  ),
  ```

### 12.4. Screen State Refresh After Navigation
- **Issue:** When returning to a screen after creating new data on another screen, the changes aren't immediately visible because each screen has its own BLoC instance.
- **Example:** Creating a new player group in CreateEditPlayerGroupScreen and returning to PlayerGroupsScreen without seeing the new group listed.
- **Solutions:**
  1. Convert stateless screens to stateful and maintain a single BloC instance:
     ```dart
     class _PlayerGroupsScreenState extends State<PlayerGroupsScreen> {
       late PlayerGroupBloc _playerGroupBloc;
     
       @override
       void initState() {
         super.initState();
         _playerGroupBloc = sl<PlayerGroupBloc>();
         _playerGroupBloc.add(LoadPlayerGroups());
       }
     
       @override
       Widget build(BuildContext context) {
         return BlocProvider.value(
           value: _playerGroupBloc, // Reuse the same BLoC instance
           child: Scaffold(/* ... */),
         );
       }
     }
     ```
  
  2. Use focus detection to refresh data when returning to a screen:
     ```dart
     Focus(
       focusNode: _focusNode,
       onFocusChange: (hasFocus) {
         if (hasFocus) {
           // Reload data when screen gets focus
           _playerGroupBloc.add(LoadPlayerGroups());
         }
       },
       child: Scaffold(/* ... */),
     )
     ```
  
  3. Explicitly reload data after returning from navigation:
     ```dart
     floatingActionButton: FloatingActionButton(
       onPressed: () async {
         await context.router.push(SomeRoute());
         // Refresh data after returning
         if (mounted) {
           context.read<SomeBloc>().add(LoadDataEvent());
         }
       },
       child: const Icon(Icons.add),
     ),
     ```

Following these guidelines will help ensure proper state management across different screens in the application. 