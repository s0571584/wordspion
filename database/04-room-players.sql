-- Room Players Table
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