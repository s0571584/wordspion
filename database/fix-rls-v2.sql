-- Fix RLS to allow room members to see each other
-- Run this script in your Supabase SQL editor

-- Drop the current policy
DROP POLICY IF EXISTS "Players can view room participants" ON room_players;

-- Create a function to check if user is in a room (avoids recursion)
CREATE OR REPLACE FUNCTION user_is_in_room(target_room_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM room_players 
    WHERE room_id = target_room_id 
    AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- New policy using the function
CREATE POLICY "Players can view room participants" 
  ON room_players FOR SELECT 
  USING (
    -- Users can see their own record
    user_id = auth.uid() 
    OR 
    -- Room hosts can see all players in their rooms
    EXISTS (
      SELECT 1 FROM game_rooms gr 
      WHERE gr.id = room_players.room_id 
      AND gr.host_id = auth.uid()
    )
    OR
    -- Users can see other players in rooms they're part of
    user_is_in_room(room_players.room_id)
  );

-- Alternative simpler approach (if the above doesn't work):
-- DROP POLICY IF EXISTS "Players can view room participants" ON room_players;
-- 
-- CREATE POLICY "Players can view room participants" 
--   ON room_players FOR SELECT 
--   USING (TRUE);  -- Allow all authenticated users to see room participants
-- 
-- -- Then restrict at the application level if needed