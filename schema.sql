CREATE TABLE stats (id serial primary key, created_at timestamptz default (now()), data json);
create index ON stats (created_at);

