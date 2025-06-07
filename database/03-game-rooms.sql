-- Game Rooms Table
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