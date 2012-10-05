CREATE TABLE stats (id serial primary key, created_at timestamptz default (now()), data json);

