-- Helper Functions

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