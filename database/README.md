# Database Setup for WortSpion Multiplayer

This directory contains all SQL scripts needed to set up the Supabase database for WortSpion multiplayer functionality.

## Setup Instructions

1. **Create Supabase Project**
   - Go to https://supabase.com
   - Create a new project
   - Note your project URL and anon key

2. **Run SQL Scripts in Order**
   Run these scripts in your Supabase SQL Editor in the following order:

   ```
   01-extensions.sql       # Enable required PostgreSQL extensions
   02-user-profiles.sql    # User profiles table and policies
   03-game-rooms.sql       # Game rooms for multiplayer sessions
   04-room-players.sql     # Players in game rooms
   05-categories-words.sql # Categories and words tables
   06-word-relations.sql   # Word relationships for decoy selection
   07-game-rounds.sql      # Individual game rounds
   08-player-roles.sql     # Player role assignments per round
   09-votes-guesses.sql    # Voting and word guessing tables
   10-game-events.sql      # Real-time game events
   11-functions.sql        # Helper functions
   12-triggers.sql         # Database triggers
   13-cron-jobs.sql        # Scheduled cleanup jobs
   ```

3. **Enable Row Level Security**
   All tables have RLS enabled with appropriate policies for security.

4. **Configure Realtime** (Optional)
   In Supabase Dashboard → Settings → API → Realtime, enable these tables:
   - `game_rooms`
   - `room_players` 
   - `rounds`
   - `votes`
   - `game_events`

5. **Test the Setup**
   ```sql
   -- Test user creation
   INSERT INTO user_profiles (id, username, display_name) 
   VALUES (auth.uid(), 'testuser1', 'Test User 1');

   -- Test room creation
   INSERT INTO game_rooms (room_code, host_id, player_count, impostor_count, round_count, timer_duration)
   VALUES (generate_room_code(), auth.uid(), 5, 1, 3, 180);
   ```

## Database Schema Overview

- **user_profiles**: User accounts linked to Supabase Auth
- **game_rooms**: Multiplayer game sessions with settings
- **room_players**: Players participating in rooms
- **categories/words**: Game content (words organized by category)
- **word_relations**: Relationships for generating decoy words
- **rounds**: Individual game rounds within sessions
- **player_roles**: Role assignments (regular player vs impostor)
- **votes**: Player voting records
- **word_guesses**: Impostor word guesses
- **game_events**: Real-time events for synchronization

## Next Steps

After database setup:
1. Configure your Flutter app with Supabase credentials
2. Implement authentication flow
3. Add real-time subscriptions
4. Test multiplayer game flow

## Security Features

- Row Level Security (RLS) on all tables
- User-specific data access policies
- Automatic cleanup of expired rooms
- Player heartbeat monitoring
- Input validation through database constraints