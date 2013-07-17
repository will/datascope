# Datascope
Visability into your Postgres 9.2 database via [pg_stat_statements](http://www.postgresql.org/docs/9.2/static/pgstatstatements.html) and [cubism](http://square.github.com/cubism/) and using the [json datatype](http://wiki.postgresql.org/wiki/What's_new_in_PostgreSQL_9.2#JSON_datatype).

![http://f.cl.ly/items/440Z1L1n2v3q3c1Q3J0s/datascope.png](http://f.cl.ly/items/440Z1L1n2v3q3c1Q3J0s/datascope.png)

Check out a [live example](https://datascope.herokuapp.com)

# Heroku Deploy

Datascope needs two Postgres 9.2 databases. The first is a DATABASE_URL with the datascope schema, the second is a TARGET_DB with the pg_stat_statements extension.

```bash
$ heroku create

$ heroku addons:add heroku-postgresql:dev --version=9.2
Attached as HEROKU_POSTGRESQL_COPPER_URL
$ heroku config:add DATABASE_URL=$(heroku config:get HEROKU_POSTGRESQL_COPPER_URL)
$ heroku pg:psql COPPER
=> \i schema.sql
CREATE TABLE

$ heroku addons:add heroku-postgresql:dev --version=9.2
Attached as HEROKU_POSTGRESQL_GREEN_URL

$ heroku config:add TARGET_DB=$(heroku config:get HEROKU_POSTGRESQL_GREEN_URL)
$ heroku pg:psql GREEN
=> create extension pg_stat_statements;
CREATE EXTENSION

$ git push heroku master
$ heroku scale worker=1
```

# Basic Auth

If you don't want your deployment of datascope to be publicly visible, simply add environment variables for `BASIC_AUTH_USER` and `BASIC_AUTH_PASSWORD`.

```
heroku config:add BASIC_AUTH_USER=admin BASIC_AUTH_PASSWORD=password
```
