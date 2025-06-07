-- Categories and Words Tables
-- Word categories and game words

-- Categories Table
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT, -- Emoji or icon name
  is_default BOOLEAN DEFAULT FALSE,
  word_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (id, name, description, icon, is_default) VALUES
  ('entertainment', 'Unterhaltung', 'Filme, Serien, Musik und mehr', '🎬', TRUE),
  ('sports', 'Sport', 'Sportarten, Teams und Athleten', '⚽', TRUE),
  ('animals', 'Tiere', 'Verschiedene Tierarten', '🦁', TRUE),
  ('food', 'Essen & Trinken', 'Gerichte, Zutaten und Getränke', '🍕', TRUE),
  ('places', 'Orte', 'Städte, Länder und Sehenswürdigkeiten', '🌍', TRUE),
  ('professions', 'Berufe', 'Berufe und Tätigkeiten', '💼', TRUE),
  ('technology', 'Technik', 'Geräte, Software und Internet', '💻', FALSE),
  ('everyday', 'Alltag', 'Alltagsgegenstände und -aktivitäten', '🏠', FALSE);

-- RLS for categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view categories" 
  ON categories FOR SELECT 
  USING (true);

-- Words Table
CREATE TABLE words (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  category_id TEXT REFERENCES categories(id) NOT NULL,
  text TEXT NOT NULL,
  difficulty INTEGER DEFAULT 1 CHECK (difficulty BETWEEN 1 AND 5),
  language TEXT DEFAULT 'de',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Ensure unique words per category
  UNIQUE(category_id, text, language)
);

-- Indexes for words
CREATE INDEX idx_words_category_id ON words(category_id);
CREATE INDEX idx_words_difficulty ON words(difficulty);

-- RLS for words
ALTER TABLE words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view words" 
  ON words FOR SELECT 
  USING (true);

-- Insert sample words (expand this list)
INSERT INTO words (category_id, text, difficulty) VALUES
  -- Entertainment
  ('entertainment', 'Star Wars', 1),
  ('entertainment', 'Netflix', 1),
  ('entertainment', 'Beethoven', 2),
  ('entertainment', 'Game of Thrones', 1),
  ('entertainment', 'Die Beatles', 1),
  
  -- Sports
  ('sports', 'Fußball', 1),
  ('sports', 'Basketball', 1),
  ('sports', 'Olympische Spiele', 2),
  ('sports', 'Wimbledon', 3),
  
  -- Animals
  ('animals', 'Löwe', 1),
  ('animals', 'Pinguin', 1),
  ('animals', 'Schmetterling', 2),
  
  -- Food
  ('food', 'Pizza', 1),
  ('food', 'Sushi', 1),
  ('food', 'Kaffee', 1);

-- Update word counts in categories
UPDATE categories c SET word_count = (
  SELECT COUNT(*) FROM words w WHERE w.category_id = c.id
);