-- Game Events Table
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