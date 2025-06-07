-- Player Roles Table
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