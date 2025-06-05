# Phase 1: Database Setup

This document contains all SQL queries needed to set up the Supabase database for WortSpion multiplayer functionality.

## Prerequisites

- [ ] Supabase project created
- [ ] Database connection established
- [ ] SQL editor accessible (Supabase Dashboard → SQL Editor)

## 1. Enable Required Extensions

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable cryptographic functions (for room codes)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

## 2. User Profiles Table

```sql
-- User profiles linked to Supabase Auth
CREATE TABLE user_profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  games_played INTEGER DEFAULT 0,
  games_won INTEGER DEFAULT 0,
  total_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_user_profiles_username ON user_profiles(username);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view all profiles" 
  ON user_profiles FOR SELECT 
  USING (true);

CREATE POLICY "Users can update own profile" 
  ON user_profiles FOR UPDATE 
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
  ON user_profiles FOR INSERT 
  WITH CHECK (auth.uid() = id);
```

## 3. Game Rooms Table

```sql
-- Game rooms for multiplayer sessions
CREATE TABLE game_rooms (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_code TEXT UNIQUE NOT NULL,
  host_id UUID REFERENCES user_profiles(id) NOT NULL,
  
  -- Game settings
  player_count INTEGER NOT NULL CHECK (player_count >= 3 AND player_count <= 10),
  impostor_count INTEGER NOT NULL CHECK (impostor_count >= 1),
  round_count INTEGER NOT NULL CHECK (round_count >= 1),
  timer_duration INTEGER NOT NULL CHECK (timer_duration >= 30), -- seconds
  impostors_know_each_other BOOLEAN DEFAULT FALSE,
  selected_categories TEXT[] DEFAULT ARRAY['entertainment', 'sports', 'animals', 'food'],
  
  -- Game state
  game_state TEXT DEFAULT 'waiting' CHECK (game_state IN ('waiting', 'starting', 'playing', 'finished', 'cancelled')),
  current_round INTEGER DEFAULT 0,
  
  -- Metadata
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours',
  
  -- Constraints
  CONSTRAINT valid_impostor_count CHECK (impostor_count <= player_count - 2)
);

-- Indexes
CREATE INDEX idx_game_rooms_room_code ON game_rooms(room_code) WHERE is_active = TRUE;
CREATE INDEX idx_game_rooms_host_id ON game_rooms(host_id);
CREATE INDEX idx_game_rooms_expires_at ON game_rooms(expires_at) WHERE is_active = TRUE;

-- RLS
ALTER TABLE game_rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active rooms" 
  ON game_rooms FOR SELECT 
  USING (is_active = TRUE);

CREATE POLICY "Host can update own room" 
  ON game_rooms FOR UPDATE 
  USING (host_id = auth.uid());

CREATE POLICY "Authenticated users can create rooms" 
  ON game_rooms FOR INSERT 
  WITH CHECK (auth.uid() = host_id);
```

## 4. Room Players Table

```sql
-- Players in game rooms
CREATE TABLE room_players (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID REFERENCES game_rooms(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES user_profiles(id) NOT NULL,
  player_name TEXT NOT NULL,
  player_order INTEGER NOT NULL, -- Order in which players joined
  
  -- Status
  is_ready BOOLEAN DEFAULT FALSE,
  is_connected BOOLEAN DEFAULT TRUE,
  last_heartbeat TIMESTAMPTZ DEFAULT NOW(),
  
  -- Game data
  score INTEGER DEFAULT 0,
  
  -- Metadata
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  
  -- Constraints
  UNIQUE(room_id, user_id),
  UNIQUE(room_id, player_order)
);

-- Indexes
CREATE INDEX idx_room_players_room_id ON room_players(room_id);
CREATE INDEX idx_room_players_user_id ON room_players(user_id);

-- RLS
ALTER TABLE room_players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can view room participants" 
  ON room_players FOR SELECT 
  USING (
    room_id IN (
      SELECT room_id FROM room_players WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join rooms" 
  ON room_players FOR INSERT 
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own status" 
  ON room_players FOR UPDATE 
  USING (user_id = auth.uid());
```

## 5. Categories Table (Multiplayer Version)

```sql
-- Word categories
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT, -- Emoji or icon name
  is_default BOOLEAN DEFAULT FALSE,
  word_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (id, name, description, icon, is_default) VALUES
  ('entertainment', 'Unterhaltung', 'Filme, Serien, Musik und mehr', '🎬', TRUE),
  ('sports', 'Sport', 'Sportarten, Teams und Athleten', '⚽', TRUE),
  ('animals', 'Tiere', 'Verschiedene Tierarten', '🦁', TRUE),
  ('food', 'Essen & Trinken', 'Gerichte, Zutaten und Getränke', '🍕', TRUE),
  ('places', 'Orte', 'Städte, Länder und Sehenswürdigkeiten', '🌍', TRUE),
  ('professions', 'Berufe', 'Berufe und Tätigkeiten', '💼', TRUE),
  ('technology', 'Technik', 'Geräte, Software und Internet', '💻', FALSE),
  ('everyday', 'Alltag', 'Alltagsgegenstände und -aktivitäten', '🏠', FALSE);

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view categories" 
  ON categories FOR SELECT 
  USING (true);
```

## 6. Words Table

```sql
-- Game words
CREATE TABLE words (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  category_id TEXT REFERENCES categories(id) NOT NULL,
  text TEXT NOT NULL,
  difficulty INTEGER DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  language TEXT DEFAULT 'de',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure unique words per category
  UNIQUE(category_id, text, language)
);

-- Indexes
CREATE INDEX idx_words_category_id ON words(category_id);
CREATE INDEX idx_words_difficulty ON words(difficulty);

-- RLS
ALTER TABLE words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view words" 
  ON words FOR SELECT 
  USING (true);

-- Insert sample words (expand this list)
INSERT INTO words (category_id, text, difficulty) VALUES
  -- Entertainment
  ('entertainment', 'Star Wars', 1),
  ('entertainment', 'Netflix', 1),
  ('entertainment', 'Beethoven', 2),
  ('entertainment', 'Game of Thrones', 1),
  ('entertainment', 'Die Beatles', 1),
  
  -- Sports
  ('sports', 'Fußball', 1),
  ('sports', 'Basketball', 1),
  ('sports', 'Olympische Spiele', 2),
  ('sports', 'Wimbledon', 3),
  
  -- Add more words as needed...
  ;

-- Update word counts in categories
UPDATE categories c SET word_count = (
  SELECT COUNT(*) FROM words w WHERE w.category_id = c.id
);
```

## 7. Word Relations Table

```sql
-- Relationships between words for decoy selection
CREATE TABLE word_relations (
  word_id_1 UUID REFERENCES words(id) ON DELETE CASCADE,
  word_id_2 UUID REFERENCES words(id) ON DELETE CASCADE,
  similarity DECIMAL(3,2) CHECK (similarity BETWEEN 0.0 AND 1.0),
  relation_type TEXT DEFAULT 'semantic', -- semantic, category, difficulty
  
  PRIMARY KEY (word_id_1, word_id_2),
  CHECK (word_id_1 < word_id_2) -- Prevent duplicates
);

-- Indexes
CREATE INDEX idx_word_relations_similarity ON word_relations(similarity);

-- RLS
ALTER TABLE word_relations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view relations" 
  ON word_relations FOR SELECT 
  USING (true);
```

## 8. Game Rounds Table

```sql
-- Individual rounds within games
CREATE TABLE rounds (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID REFERENCES game_rooms(id) ON DELETE CASCADE NOT NULL,
  round_number INTEGER NOT NULL,
  
  -- Words
  main_word_id UUID REFERENCES words(id) NOT NULL,
  decoy_word_id UUID REFERENCES words(id) NOT NULL,
  category_id TEXT REFERENCES categories(id) NOT NULL,
  
  -- State
  round_state TEXT DEFAULT 'role_assignment' 
    CHECK (round_state IN ('role_assignment', 'role_reveal', 'discussion', 'voting', 'resolution', 'completed')),
  
  -- Timing
  started_at TIMESTAMPTZ DEFAULT NOW(),
  discussion_started_at TIMESTAMPTZ,
  voting_started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  
  -- Results
  impostors_won BOOLEAN,
  word_guessed BOOLEAN DEFAULT FALSE,
  
  -- Constraints
  UNIQUE(room_id, round_number)
);

-- Indexes
CREATE INDEX idx_rounds_room_id ON rounds(room_id);

-- RLS
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can view rounds in their games" 
  ON rounds FOR SELECT 
  USING (
    room_id IN (
      SELECT room_id FROM room_players WHERE user_id = auth.uid()
    )
  );
```

## 9. Player Roles Table

```sql
-- Player roles for each round
CREATE TABLE player_roles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  round_id UUID REFERENCES rounds(id) ON DELETE CASCADE NOT NULL,
  player_id UUID REFERENCES room_players(id) ON DELETE CASCADE NOT NULL,
  is_impostor BOOLEAN NOT NULL,
  assigned_word_id UUID REFERENCES words(id) NOT NULL,
  
  -- Tracking
  role_viewed_at TIMESTAMPTZ,
  
  -- Constraints
  UNIQUE(round_id, player_id)
);

-- Indexes
CREATE INDEX idx_player_roles_round_id ON player_roles(round_id);
CREATE INDEX idx_player_roles_player_id ON player_roles(player_id);

-- RLS
ALTER TABLE player_roles ENABLE ROW LEVEL SECURITY;

-- Players can only see their own roles
CREATE POLICY "Players can view own role" 
  ON player_roles FOR SELECT 
  USING (
    player_id IN (
      SELECT id FROM room_players WHERE user_id = auth.uid()
    )
  );

-- System can insert roles
CREATE POLICY "System can manage roles" 
  ON player_roles FOR ALL 
  USING (true)
  WITH CHECK (true);
```

## 10. Votes Table

```sql
-- Voting records
CREATE TABLE votes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  round_id UUID REFERENCES rounds(id) ON DELETE CASCADE NOT NULL,
  voter_id UUID REFERENCES room_players(id) ON DELETE CASCADE NOT NULL,
  target_id UUID REFERENCES room_players(id) ON DELETE CASCADE NOT NULL,
  
  -- Metadata
  voted_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(round_id, voter_id),
  CHECK (voter_id != target_id)
);

-- Indexes
CREATE INDEX idx_votes_round_id ON votes(round_id);

-- RLS
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- Players can see all votes after voting phase
CREATE POLICY "View votes after voting" 
  ON votes FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM rounds 
      WHERE id = round_id 
      AND round_state IN ('resolution', 'completed')
    )
  );

-- Players can only insert their own votes
CREATE POLICY "Insert own votes" 
  ON votes FOR INSERT 
  WITH CHECK (
    voter_id IN (
      SELECT id FROM room_players WHERE user_id = auth.uid()
    )
  );
```

## 11. Word Guesses Table

```sql
-- Impostor word guesses
CREATE TABLE word_guesses (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  round_id UUID REFERENCES rounds(id) ON DELETE CASCADE NOT NULL,
  player_id UUID REFERENCES room_players(id) ON DELETE CASCADE NOT NULL,
  guessed_word TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  guessed_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  UNIQUE(round_id, player_id)
);

-- RLS
ALTER TABLE word_guesses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "View guesses after round" 
  ON word_guesses FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM rounds 
      WHERE id = round_id 
      AND round_state = 'completed'
    )
  );

CREATE POLICY "Impostors can guess" 
  ON word_guesses FOR INSERT 
  WITH CHECK (
    player_id IN (
      SELECT id FROM room_players WHERE user_id = auth.uid()
    )
    AND EXISTS (
      SELECT 1 FROM player_roles 
      WHERE player_id = word_guesses.player_id 
      AND round_id = word_guesses.round_id 
      AND is_impostor = TRUE
    )
  );
```

## 12. Game Events Table (For Real-time)

```sql
-- Real-time game events
CREATE TABLE game_events (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  room_id UUID REFERENCES game_rooms(id) ON DELETE CASCADE NOT NULL,
  event_type TEXT NOT NULL,
  event_data JSONB DEFAULT '{}',
  created_by UUID REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for real-time queries
CREATE INDEX idx_game_events_room_created ON game_events(room_id, created_at DESC);

-- RLS
ALTER TABLE game_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Players can view room events" 
  ON game_events FOR SELECT 
  USING (
    room_id IN (
      SELECT room_id FROM room_players WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Players can create events" 
  ON game_events FOR INSERT 
  WITH CHECK (
    room_id IN (
      SELECT room_id FROM room_players WHERE user_id = auth.uid()
    )
    AND created_by = auth.uid()
  );
```

## 13. Helper Functions

```sql
-- Function to generate unique room codes
CREATE OR REPLACE FUNCTION generate_room_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists BOOLEAN;
BEGIN
  LOOP
    -- Generate 6-character code
    code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT), 1, 6));
    
    -- Check if code exists
    SELECT EXISTS(
      SELECT 1 FROM game_rooms 
      WHERE room_code = code 
      AND is_active = TRUE
    ) INTO exists;
    
    EXIT WHEN NOT exists;
  END LOOP;
  
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up expired rooms
CREATE OR REPLACE FUNCTION cleanup_expired_rooms()
RETURNS void AS $$
BEGIN
  UPDATE game_rooms 
  SET is_active = FALSE 
  WHERE expires_at < NOW() 
  AND is_active = TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to check if all players have viewed roles
CREATE OR REPLACE FUNCTION all_roles_viewed(p_round_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM player_roles 
    WHERE round_id = p_round_id 
    AND role_viewed_at IS NULL
  );
END;
$$ LANGUAGE plpgsql;
```

## 14. Database Triggers

```sql
-- Trigger to update player count when players join/leave
CREATE OR REPLACE FUNCTION update_room_player_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE game_rooms 
    SET player_count = (
      SELECT COUNT(*) FROM room_players 
      WHERE room_id = NEW.room_id 
      AND is_connected = TRUE
    )
    WHERE id = NEW.room_id;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.is_connected != NEW.is_connected THEN
      UPDATE game_rooms 
      SET player_count = (
        SELECT COUNT(*) FROM room_players 
        WHERE room_id = NEW.room_id 
        AND is_connected = TRUE
      )
      WHERE id = NEW.room_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_player_count_trigger
AFTER INSERT OR UPDATE ON room_players
FOR EACH ROW
EXECUTE FUNCTION update_room_player_count();

-- Trigger to update user profile stats
CREATE OR REPLACE FUNCTION update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- Update games played
  UPDATE user_profiles 
  SET games_played = games_played + 1 
  WHERE id IN (
    SELECT user_id FROM room_players WHERE room_id = NEW.id
  );
  
  -- Update games won (to be called when game ends)
  -- This is a placeholder - actual implementation depends on winning logic
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 15. Scheduled Jobs (Cron)

Add these to Supabase Dashboard → Database → Extensions → pg_cron:

```sql
-- Run every hour to clean up expired rooms
SELECT cron.schedule(
  'cleanup-expired-rooms',
  '0 * * * *',
  'SELECT cleanup_expired_rooms();'
);

-- Run every 5 minutes to check disconnected players
SELECT cron.schedule(
  'check-player-heartbeats',
  '*/5 * * * *',
  $$
  UPDATE room_players 
  SET is_connected = FALSE 
  WHERE last_heartbeat < NOW() - INTERVAL '2 minutes' 
  AND is_connected = TRUE;
  $$
);
```

## Testing Queries

```sql
-- Test user creation
INSERT INTO user_profiles (id, username, display_name) 
VALUES (auth.uid(), 'testuser1', 'Test User 1');

-- Test room creation
INSERT INTO game_rooms (room_code, host_id, player_count, impostor_count, round_count, timer_duration)
VALUES (generate_room_code(), auth.uid(), 5, 1, 3, 180);

-- Check room creation
SELECT * FROM game_rooms WHERE host_id = auth.uid();

-- Test joining room
INSERT INTO room_players (room_id, user_id, player_name, player_order)
VALUES (
  (SELECT id FROM game_rooms WHERE host_id = auth.uid() LIMIT 1),
  auth.uid(),
  'Player 1',
  1
);
```

## Verification Checklist

- [ ] All tables created successfully
- [ ] All indexes created
- [ ] RLS enabled on all tables
- [ ] All policies created
- [ ] Helper functions working
- [ ] Triggers functioning
- [ ] Test queries executed successfully
- [ ] No errors in Supabase logs

## Next Steps

Once all database objects are created:
1. Test RLS policies with different user roles
2. Populate words and word_relations tables with full dataset
3. Configure Supabase Realtime for necessary tables
4. Proceed to [Authentication Setup](./02-authentication.md)
