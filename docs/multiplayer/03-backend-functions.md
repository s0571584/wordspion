# Phase 3: Backend Functions

This document covers the implementation of Supabase Edge Functions for game logic that requires server-side processing.

## Prerequisites

- [ ] Database setup completed (Phase 1)
- [ ] Authentication implemented (Phase 2)
- [ ] Supabase CLI installed locally
- [ ] Deno installed for local testing

## 1. Edge Functions Setup

### 1.1 Initialize Edge Functions

```bash
# In your project root
supabase functions new create-game-room
supabase functions new join-game-room
supabase functions new start-game
supabase functions new assign-roles
supabase functions new submit-vote
supabase functions new submit-word-guess
supabase functions new end-round
supabase functions new player-heartbeat
```

### 1.2 Shared Types

```typescript
// supabase/functions/_shared/types.ts
export interface GameRoom {
  id: string;
  room_code: string;
  host_id: string;
  player_count: number;
  impostor_count: number;
  round_count: number;
  timer_duration: number;
  impostors_know_each_other: boolean;
  selected_categories: string[];
  game_state: 'waiting' | 'starting' | 'playing' | 'finished' | 'cancelled';
  current_round: number;
}

export interface RoomPlayer {
  id: string;
  room_id: string;
  user_id: string;
  player_name: string;
  player_order: number;
  is_ready: boolean;
  is_connected: boolean;
  score: number;
}

export interface GameEvent {
  room_id: string;
  event_type: string;
  event_data: Record<string, any>;
  created_by: string;
}
```

### 1.3 Shared Utilities

```typescript
// supabase/functions/_shared/utils.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export function getSupabaseClient(authHeader: string) {
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  
  return createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });
}

export async function getUserId(supabase: any): Promise<string> {
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) throw new Error('Unauthorized');
  return user.id;
}

export function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };
}

export async function broadcastEvent(
  supabase: any,
  event: GameEvent
): Promise<void> {
  await supabase
    .from('game_events')
    .insert([event]);
}
```

## 2. Create Game Room Function

```typescript
// supabase/functions/create-game-room/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, getUserId, corsHeaders } from '../_shared/utils.ts';

interface CreateRoomRequest {
  player_count: number;
  impostor_count: number;
  round_count: number;
  timer_duration: number;
  impostors_know_each_other: boolean;
  selected_categories: string[];
  host_name: string;
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const userId = await getUserId(supabase);
    
    const body: CreateRoomRequest = await req.json();
    
    // Validate request
    if (body.impostor_count > body.player_count - 2) {
      throw new Error('Invalid impostor count');
    }
    
    // Generate room code using database function
    const { data: roomCode, error: codeError } = await supabase
      .rpc('generate_room_code');
    
    if (codeError) throw codeError;
    
    // Create room
    const { data: room, error: roomError } = await supabase
      .from('game_rooms')
      .insert({
        room_code: roomCode,
        host_id: userId,
        player_count: body.player_count,
        impostor_count: body.impostor_count,
        round_count: body.round_count,
        timer_duration: body.timer_duration,
        impostors_know_each_other: body.impostors_know_each_other,
        selected_categories: body.selected_categories,
      })
      .select()
      .single();
    
    if (roomError) throw roomError;
    
    // Auto-join host as first player
    const { error: joinError } = await supabase
      .from('room_players')
      .insert({
        room_id: room.id,
        user_id: userId,
        player_name: body.host_name,
        player_order: 1,
        is_ready: true, // Host is always ready
      });
    
    if (joinError) throw joinError;
    
    // Broadcast room created event
    await supabase
      .from('game_events')
      .insert({
        room_id: room.id,
        event_type: 'room_created',
        event_data: { room_code: roomCode },
        created_by: userId,
      });
    
    return new Response(
      JSON.stringify({ room_id: room.id, room_code: roomCode }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});
```

## 3. Join Game Room Function

```typescript
// supabase/functions/join-game-room/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, getUserId, corsHeaders, broadcastEvent } from '../_shared/utils.ts';

interface JoinRoomRequest {
  room_code: string;
  player_name: string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const userId = await getUserId(supabase);
    
    const body: JoinRoomRequest = await req.json();
    
    // Find active room
    const { data: room, error: roomError } = await supabase
      .from('game_rooms')
      .select('*')
      .eq('room_code', body.room_code.toUpperCase())
      .eq('is_active', true)
      .single();
    
    if (roomError || !room) {
      throw new Error('Room not found');
    }
    
    // Check if game already started
    if (room.game_state !== 'waiting') {
      throw new Error('Game already started');
    }
    
    // Check if already in room
    const { data: existingPlayer } = await supabase
      .from('room_players')
      .select('id')
      .eq('room_id', room.id)
      .eq('user_id', userId)
      .single();
    
    if (existingPlayer) {
      throw new Error('Already in room');
    }
    
    // Get current player count
    const { count } = await supabase
      .from('room_players')
      .select('*', { count: 'exact', head: true })
      .eq('room_id', room.id)
      .eq('is_connected', true);
    
    if (count >= room.player_count) {
      throw new Error('Room is full');
    }
    
    // Join room
    const { data: player, error: joinError } = await supabase
      .from('room_players')
      .insert({
        room_id: room.id,
        user_id: userId,
        player_name: body.player_name,
        player_order: count + 1,
      })
      .select()
      .single();
    
    if (joinError) throw joinError;
    
    // Broadcast player joined event
    await broadcastEvent(supabase, {
      room_id: room.id,
      event_type: 'player_joined',
      event_data: {
        player_id: player.id,
        player_name: body.player_name,
        player_order: player.player_order,
      },
      created_by: userId,
    });
    
    return new Response(
      JSON.stringify({ room_id: room.id, player_id: player.id }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});
```

## 4. Start Game Function

```typescript
// supabase/functions/start-game/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, getUserId, corsHeaders, broadcastEvent } from '../_shared/utils.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const userId = await getUserId(supabase);
    
    const { room_id } = await req.json();
    
    // Verify user is host
    const { data: room, error: roomError } = await supabase
      .from('game_rooms')
      .select('*')
      .eq('id', room_id)
      .eq('host_id', userId)
      .single();
    
    if (roomError || !room) {
      throw new Error('Unauthorized or room not found');
    }
    
    // Check all players are ready
    const { data: players, error: playersError } = await supabase
      .from('room_players')
      .select('*')
      .eq('room_id', room_id)
      .eq('is_connected', true);
    
    if (playersError) throw playersError;
    
    const unreadyPlayers = players.filter(p => !p.is_ready);
    if (unreadyPlayers.length > 0) {
      throw new Error('Not all players are ready');
    }
    
    // Update game state
    const { error: updateError } = await supabase
      .from('game_rooms')
      .update({ 
        game_state: 'starting',
        started_at: new Date().toISOString(),
      })
      .eq('id', room_id);
    
    if (updateError) throw updateError;
    
    // Create first round
    await createRound(supabase, room_id, 1, room.selected_categories);
    
    // Broadcast game started
    await broadcastEvent(supabase, {
      room_id,
      event_type: 'game_started',
      event_data: { round_number: 1 },
      created_by: userId,
    });
    
    return new Response(
      JSON.stringify({ success: true }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});

async function createRound(
  supabase: any,
  roomId: string,
  roundNumber: number,
  categories: string[]
): Promise<void> {
  // Select random category
  const category = categories[Math.floor(Math.random() * categories.length)];
  
  // Get random words from category
  const { data: words, error: wordsError } = await supabase
    .from('words')
    .select('*')
    .eq('category_id', category)
    .order('RANDOM()')
    .limit(10);
  
  if (wordsError || words.length < 2) {
    throw new Error('Not enough words in category');
  }
  
  const mainWord = words[0];
  
  // Find decoy word with medium similarity
  const { data: decoyWord } = await supabase
    .from('words')
    .select(`
      *,
      word_relations!word_relations_word_id_2_fkey(similarity)
    `)
    .eq('word_relations.word_id_1', mainWord.id)
    .gte('word_relations.similarity', 0.3)
    .lte('word_relations.similarity', 0.7)
    .order('RANDOM()')
    .limit(1)
    .single();
  
  // Fallback to random word from same category
  const actualDecoyWord = decoyWord || words[1];
  
  // Create round
  const { error: roundError } = await supabase
    .from('rounds')
    .insert({
      room_id: roomId,
      round_number: roundNumber,
      main_word_id: mainWord.id,
      decoy_word_id: actualDecoyWord.id,
      category_id: category,
    });
  
  if (roundError) throw roundError;
}
```

## 5. Assign Roles Function

```typescript
// supabase/functions/assign-roles/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, getUserId, corsHeaders, broadcastEvent } from '../_shared/utils.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const { round_id } = await req.json();
    
    // Get round and room info
    const { data: round, error: roundError } = await supabase
      .from('rounds')
      .select(`
        *,
        game_rooms!inner(
          impostor_count,
          impostors_know_each_other
        )
      `)
      .eq('id', round_id)
      .single();
    
    if (roundError) throw roundError;
    
    // Get all active players
    const { data: players, error: playersError } = await supabase
      .from('room_players')
      .select('*')
      .eq('room_id', round.room_id)
      .eq('is_connected', true)
      .order('player_order');
    
    if (playersError) throw playersError;
    
    // Shuffle players for random role assignment
    const shuffled = [...players].sort(() => Math.random() - 0.5);
    
    // Assign roles
    const impostorCount = round.game_rooms.impostor_count;
    const roles = shuffled.map((player, index) => ({
      round_id: round_id,
      player_id: player.id,
      is_impostor: index < impostorCount,
      assigned_word_id: index < impostorCount ? round.decoy_word_id : round.main_word_id,
    }));
    
    // Insert roles
    const { error: rolesError } = await supabase
      .from('player_roles')
      .insert(roles);
    
    if (rolesError) throw rolesError;
    
    // Broadcast roles assigned
    await broadcastEvent(supabase, {
      room_id: round.room_id,
      event_type: 'roles_assigned',
      event_data: {
        round_id,
        impostors_know_each_other: round.game_rooms.impostors_know_each_other,
      },
      created_by: 'system',
    });
    
    // Update round state
    await supabase
      .from('rounds')
      .update({ round_state: 'role_reveal' })
      .eq('id', round_id);
    
    return new Response(
      JSON.stringify({ success: true }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});
```

## 6. Submit Vote Function

```typescript
// supabase/functions/submit-vote/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, getUserId, corsHeaders, broadcastEvent } from '../_shared/utils.ts';

interface SubmitVoteRequest {
  round_id: string;
  target_player_id: string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const userId = await getUserId(supabase);
    
    const body: SubmitVoteRequest = await req.json();
    
    // Get voter's player ID
    const { data: voter, error: voterError } = await supabase
      .from('room_players')
      .select('id, room_id')
      .eq('user_id', userId)
      .eq('room_id', (
        await supabase
          .from('rounds')
          .select('room_id')
          .eq('id', body.round_id)
          .single()
      ).data.room_id)
      .single();
    
    if (voterError) throw new Error('Not in this game');
    
    // Submit vote
    const { error: voteError } = await supabase
      .from('votes')
      .insert({
        round_id: body.round_id,
        voter_id: voter.id,
        target_id: body.target_player_id,
      });
    
    if (voteError) {
      if (voteError.code === '23505') {
        throw new Error('Already voted');
      }
      throw voteError;
    }
    
    // Check if all players have voted
    const { count: voteCount } = await supabase
      .from('votes')
      .select('*', { count: 'exact', head: true })
      .eq('round_id', body.round_id);
    
    const { count: playerCount } = await supabase
      .from('room_players')
      .select('*', { count: 'exact', head: true })
      .eq('room_id', voter.room_id)
      .eq('is_connected', true);
    
    // Broadcast vote submitted
    await broadcastEvent(supabase, {
      room_id: voter.room_id,
      event_type: 'vote_submitted',
      event_data: {
        votes_count: voteCount,
        players_count: playerCount,
        all_voted: voteCount === playerCount,
      },
      created_by: userId,
    });
    
    // If all voted, trigger resolution
    if (voteCount === playerCount) {
      await resolveVoting(supabase, body.round_id);
    }
    
    return new Response(
      JSON.stringify({ success: true }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});

async function resolveVoting(supabase: any, roundId: string): Promise<void> {
  // Get voting results
  const { data: votes } = await supabase
    .from('votes')
    .select('target_id')
    .eq('round_id', roundId);
  
  // Count votes per player
  const voteCounts = votes.reduce((acc: any, vote: any) => {
    acc[vote.target_id] = (acc[vote.target_id] || 0) + 1;
    return acc;
  }, {});
  
  // Find most voted player(s)
  const maxVotes = Math.max(...Object.values(voteCounts));
  const mostVoted = Object.keys(voteCounts).filter(
    playerId => voteCounts[playerId] === maxVotes
  );
  
  // Update round state
  await supabase
    .from('rounds')
    .update({ round_state: 'resolution' })
    .eq('id', roundId);
  
  // Broadcast voting results
  const { data: round } = await supabase
    .from('rounds')
    .select('room_id')
    .eq('id', roundId)
    .single();
  
  await broadcastEvent(supabase, {
    room_id: round.room_id,
    event_type: 'voting_resolved',
    event_data: {
      vote_counts: voteCounts,
      most_voted: mostVoted,
    },
    created_by: 'system',
  });
}
```

## 7. Submit Word Guess Function

```typescript
// supabase/functions/submit-word-guess/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, getUserId, corsHeaders, broadcastEvent } from '../_shared/utils.ts';

interface SubmitGuessRequest {
  round_id: string;
  guessed_word: string;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const userId = await getUserId(supabase);
    
    const body: SubmitGuessRequest = await req.json();
    
    // Get player and verify they are impostor
    const { data: playerRole, error: roleError } = await supabase
      .from('player_roles')
      .select(`
        *,
        room_players!inner(user_id, room_id),
        rounds!inner(main_word_id)
      `)
      .eq('round_id', body.round_id)
      .eq('room_players.user_id', userId)
      .eq('is_impostor', true)
      .single();
    
    if (roleError) throw new Error('Not an impostor in this round');
    
    // Get main word
    const { data: mainWord } = await supabase
      .from('words')
      .select('text')
      .eq('id', playerRole.rounds.main_word_id)
      .single();
    
    // Check if guess is correct
    const isCorrect = mainWord.text.toLowerCase() === body.guessed_word.toLowerCase();
    
    // Submit guess
    const { error: guessError } = await supabase
      .from('word_guesses')
      .insert({
        round_id: body.round_id,
        player_id: playerRole.player_id,
        guessed_word: body.guessed_word,
        is_correct: isCorrect,
      });
    
    if (guessError) throw guessError;
    
    // Update round if word was guessed
    if (isCorrect) {
      await supabase
        .from('rounds')
        .update({ word_guessed: true })
        .eq('id', body.round_id);
    }
    
    // Broadcast guess result
    await broadcastEvent(supabase, {
      room_id: playerRole.room_players.room_id,
      event_type: 'word_guess_submitted',
      event_data: {
        player_id: playerRole.player_id,
        is_correct: isCorrect,
      },
      created_by: userId,
    });
    
    return new Response(
      JSON.stringify({ is_correct: isCorrect }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});
```

## 8. Player Heartbeat Function

```typescript
// supabase/functions/player-heartbeat/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, getUserId, corsHeaders } from '../_shared/utils.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const userId = await getUserId(supabase);
    
    const { room_id } = await req.json();
    
    // Update heartbeat
    const { error } = await supabase
      .from('room_players')
      .update({ 
        last_heartbeat: new Date().toISOString(),
        is_connected: true,
      })
      .eq('user_id', userId)
      .eq('room_id', room_id);
    
    if (error) throw error;
    
    return new Response(
      JSON.stringify({ success: true }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});
```

## 9. End Round Function

```typescript
// supabase/functions/end-round/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { getSupabaseClient, corsHeaders, broadcastEvent } from '../_shared/utils.ts';

interface EndRoundRequest {
  round_id: string;
  impostors_won: boolean;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders() });
  }

  try {
    const supabase = getSupabaseClient(req.headers.get('Authorization')!);
    const body: EndRoundRequest = await req.json();
    
    // Get round info
    const { data: round, error: roundError } = await supabase
      .from('rounds')
      .select('*, game_rooms!inner(*)')
      .eq('id', body.round_id)
      .single();
    
    if (roundError) throw roundError;
    
    // Calculate scores
    const scores = await calculateScores(
      supabase,
      body.round_id,
      body.impostors_won,
      round.word_guessed
    );
    
    // Update player scores
    for (const [playerId, scoreChange] of Object.entries(scores)) {
      await supabase.rpc('increment_player_score', {
        p_player_id: playerId,
        p_score_change: scoreChange,
      });
    }
    
    // Mark round as completed
    await supabase
      .from('rounds')
      .update({ 
        round_state: 'completed',
        impostors_won: body.impostors_won,
        completed_at: new Date().toISOString(),
      })
      .eq('id', body.round_id);
    
    // Check if game is finished
    const isLastRound = round.round_number === round.game_rooms.round_count;
    
    if (isLastRound) {
      // End game
      await supabase
        .from('game_rooms')
        .update({ 
          game_state: 'finished',
          finished_at: new Date().toISOString(),
        })
        .eq('id', round.room_id);
      
      // Update player statistics
      await updatePlayerStats(supabase, round.room_id);
    } else {
      // Create next round
      await createNextRound(
        supabase,
        round.room_id,
        round.round_number + 1,
        round.game_rooms.selected_categories
      );
    }
    
    // Broadcast round ended
    await broadcastEvent(supabase, {
      room_id: round.room_id,
      event_type: 'round_ended',
      event_data: {
        round_number: round.round_number,
        impostors_won: body.impostors_won,
        word_guessed: round.word_guessed,
        scores,
        is_game_finished: isLastRound,
      },
      created_by: 'system',
    });
    
    return new Response(
      JSON.stringify({ success: true }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders(), 'Content-Type': 'application/json' },
        status: 400,
      }
    );
  }
});

async function calculateScores(
  supabase: any,
  roundId: string,
  impostorsWon: boolean,
  wordGuessed: boolean
): Promise<Record<string, number>> {
  const scores: Record<string, number> = {};
  
  // Get all player roles
  const { data: roles } = await supabase
    .from('player_roles')
    .select('*')
    .eq('round_id', roundId);
  
  for (const role of roles) {
    if (role.is_impostor) {
      // Impostor scoring
      if (impostorsWon) {
        scores[role.player_id] = 3; // Base points for winning
        if (wordGuessed) {
          scores[role.player_id] += 2; // Bonus for guessing word
        }
      } else {
        scores[role.player_id] = 0;
      }
    } else {
      // Team member scoring
      if (!impostorsWon) {
        scores[role.player_id] = 2; // Points for catching impostors
      } else {
        scores[role.player_id] = -1; // Penalty for failing
      }
    }
  }
  
  return scores;
}

async function updatePlayerStats(supabase: any, roomId: string): Promise<void> {
  // Get final scores
  const { data: players } = await supabase
    .from('room_players')
    .select('user_id, score')
    .eq('room_id', roomId)
    .order('score', { ascending: false });
  
  const winnerId = players[0].user_id;
  
  // Update games played for all
  for (const player of players) {
    await supabase.rpc('increment_user_games_played', {
      p_user_id: player.user_id,
    });
    
    // Update games won for winner
    if (player.user_id === winnerId) {
      await supabase.rpc('increment_user_games_won', {
        p_user_id: player.user_id,
      });
    }
    
    // Update total score
    await supabase.rpc('increment_user_total_score', {
      p_user_id: player.user_id,
      p_score: player.score,
    });
  }
}
```

## 10. Database RPC Functions

Add these RPC functions to your Supabase SQL editor:

```sql
-- Increment player score
CREATE OR REPLACE FUNCTION increment_player_score(
  p_player_id UUID,
  p_score_change INTEGER
)
RETURNS void AS $$
BEGIN
  UPDATE room_players 
  SET score = score + p_score_change
  WHERE id = p_player_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment user games played
CREATE OR REPLACE FUNCTION increment_user_games_played(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE user_profiles 
  SET games_played = games_played + 1
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment user games won
CREATE OR REPLACE FUNCTION increment_user_games_won(p_user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE user_profiles 
  SET games_won = games_won + 1
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment user total score
CREATE OR REPLACE FUNCTION increment_user_total_score(
  p_user_id UUID,
  p_score INTEGER
)
RETURNS void AS $$
BEGIN
  UPDATE user_profiles 
  SET total_score = total_score + p_score
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## 11. Deployment

### Deploy Functions

```bash
# Deploy all functions
supabase functions deploy create-game-room
supabase functions deploy join-game-room
supabase functions deploy start-game
supabase functions deploy assign-roles
supabase functions deploy submit-vote
supabase functions deploy submit-word-guess
supabase functions deploy end-round
supabase functions deploy player-heartbeat

# Set secrets if needed
supabase secrets set MY_SECRET_KEY=secret_value
```

### Testing Functions

```bash
# Test locally
supabase functions serve create-game-room

# Test deployed function
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/create-game-room \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "player_count": 5,
    "impostor_count": 1,
    "round_count": 3,
    "timer_duration": 180,
    "impostors_know_each_other": false,
    "selected_categories": ["entertainment", "sports"],
    "host_name": "TestHost"
  }'
```

## Verification Checklist

- [ ] All Edge Functions created
- [ ] Shared utilities working
- [ ] CORS headers configured
- [ ] Authentication working in functions
- [ ] Create room function tested
- [ ] Join room function tested
- [ ] Start game function tested
- [ ] Role assignment working
- [ ] Voting system functional
- [ ] Word guessing working
- [ ] Round ending logic correct
- [ ] Player heartbeat updating
- [ ] All RPC functions created
- [ ] Functions deployed to Supabase
- [ ] Integration tests passing

## Common Issues & Solutions

### Issue: CORS errors
**Solution**: Ensure all functions return proper CORS headers, especially for OPTIONS requests

### Issue: Authentication failing in functions
**Solution**: Check that Authorization header is passed correctly and Supabase client is initialized with it

### Issue: RPC functions not found
**Solution**: Ensure all RPC functions are created with SECURITY DEFINER

## Next Steps

1. Test all functions thoroughly
2. Monitor function performance
3. Set up error logging
4. Proceed to [Realtime Architecture](./04-realtime-architecture.md)
