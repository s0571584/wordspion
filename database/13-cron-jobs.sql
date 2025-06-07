-- Scheduled Jobs (Cron)
-- Add these to Supabase Dashboard → Database → Extensions → pg_cron

-- Run every hour to clean up expired rooms
SELECT cron.schedule(
  'cleanup-expired-rooms',
  '0 * * * *',
  'SELECT cleanup_expired_rooms();'
);

-- Run every 5 minutes to check disconnected players
SELECT cron.schedule(
  'check-player-heartbeats',
  '*/5 * * * *',
  $$
  UPDATE room_players 
  SET is_connected = FALSE 
  WHERE last_heartbeat < NOW() - INTERVAL '2 minutes' 
  AND is_connected = TRUE;
  $$
);