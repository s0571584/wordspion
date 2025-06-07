-- Game Rounds Table
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