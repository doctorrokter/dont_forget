CREATE INDEX IF NOT EXISTS type_important_idx ON tasks(type, important);
CREATE INDEX IF NOT EXISTS type_important_closed_idx ON tasks(type, important, closed);
CREATE INDEX IF NOT EXISTS type_closed_idx ON tasks(type, closed);
CREATE INDEX IF NOT EXISTS type_received_idx ON tasks(type, received);