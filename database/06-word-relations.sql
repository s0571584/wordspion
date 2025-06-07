-- Word Relations Table
-- Relationships between words for decoy selection

CREATE TABLE word_relations (
  word_id_1 UUID REFERENCES words(id) ON DELETE CASCADE,
  word_id_2 UUID REFERENCES words(id) ON DELETE CASCADE,
  similarity DECIMAL(3,2) CHECK (similarity BETWEEN 0.0 AND 1.0),
  relation_type TEXT DEFAULT 'semantic', -- semantic, category, difficulty
  
  PRIMARY KEY (word_id_1, word_id_2),
  CHECK (word_id_1 < word_id_2) -- Prevent duplicates
);

-- Indexes
CREATE INDEX idx_word_relations_similarity ON word_relations(similarity);

-- RLS
ALTER TABLE word_relations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view relations" 
  ON word_relations FOR SELECT 
  USING (true);