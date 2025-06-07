-- Temporary fix: Disable RLS for room_players to test functionality
-- Run this in your Supabase SQL editor

-- Temporarily disable RLS on room_players table
ALTER TABLE room_players DISABLE ROW LEVEL SECURITY;

-- Keep RLS enabled on other sensitive tables
-- ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE game_rooms ENABLE ROW LEVEL SECURITY;

-- This allows all authenticated users to see room participants
-- Use this for testing, then re-enable with proper policies later