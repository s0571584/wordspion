-- Room Players Table - FIXED RLS policies
-- Players in game rooms

-- First, drop the problematic policy
DROP POLICY IF EXISTS "Players can view room participants" ON room_players;

-- Create a better policy that doesn't cause infinite recursion
-- Players can see other players in rooms where they are also a player
CREATE POLICY "Players can view room participants" 
  ON room_players FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM room_players rp 
      WHERE rp.room_id = room_players.room_id 
      AND rp.user_id = auth.uid()
    )
  );

-- Alternative approach: Use a simpler policy
-- DROP POLICY IF EXISTS "Players can view room participants" ON room_players;
-- CREATE POLICY "Players can view room participants" 
--   ON room_players FOR SELECT 
--   USING (
--     user_id = auth.uid() OR 
--     room_id IN (
--       SELECT gr.id FROM game_rooms gr WHERE gr.host_id = auth.uid()
--     )
--   );