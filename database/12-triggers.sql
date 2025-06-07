-- Database Triggers

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