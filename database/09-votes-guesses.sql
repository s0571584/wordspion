-- Votes and Word Guesses Tables

-- Votes Table
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

-- Word Guesses Table
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