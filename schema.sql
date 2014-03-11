CREATE TABLE stats (id serial primary key, created_at timestamptz default (now()), data json);
create index ON stats (created_at);

-- Function that will delete old rows to keep the size of the set to 10_000 rows
-- CREATE OR REPLACE FUNCTION prune_stats_table()
-- RETURNS trigger AS
-- $BODY$
-- BEGIN
--   DELETE FROM stats WHERE id < (SELECT id FROM stats ORDER BY id DESC LIMIT 1 OFFSET 9999);
--   return null;
-- END
-- $BODY$
-- LANGUAGE plpgsql;
--
-- Trigger pruning before each update... slow but do the job
-- CREATE TRIGGER prune_stats_trigger
-- BEFORE INSERT OR UPDATE
-- ON stats
-- EXECUTE PROCEDURE prune_stats_table();
