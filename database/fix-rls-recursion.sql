-- Fix RLS infinite recursion issue
-- Run this script in your Supabase SQL editor

-- Drop the problematic policy
DROP POLICY IF EXISTS "Players can view room participants" ON room_players;

-- Simple and safe policy: Players can only see their own records and host can see all in their rooms
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
  );

-- Temporarily disable RLS for testing (OPTIONAL - remove this in production)
-- ALTER TABLE room_players DISABLE ROW LEVEL SECURITY;