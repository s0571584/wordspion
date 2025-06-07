-- Enable Required Extensions
-- Run this first in your Supabase SQL Editor

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable cryptographic functions (for room codes)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";