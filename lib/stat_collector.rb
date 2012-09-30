require 'sequel'
require 'json'
DB = Sequel.connect ENV['DATABASE_URL']
TARGET_DB = Sequel.connect ENV['TARGET_DB']

module StatCollector
  extend self

  def stats
    {
      connections: connections,
      stat_statements: stat_statements,
      cache_hit: cache_hit,
      locks: locks
    }
  end

  def capture_stats!
    s = stats
    DB[:stats] << {data: s.to_json}
    "connections=#{s[:connections]} stat_statements=#{s[:stat_statements].count} cache_hit=#{cache_hit}"
  end

  def reset_target_stats!
    target_db.execute "select pg_stat_statements_reset()"
  end

  def target_db
    TARGET_DB
  end

  def connections
    target_db[:pg_stat_activity].count
  end

  def stat_statements
    TARGET_DB[:pg_stat_statements]
      .select(:query, :calls, :total_time)
      .exclude(query: '<insufficient privilege>')
      .all
  end

  def cache_hit
    target_db[:pg_statio_user_tables]
      .select("(sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) as ratio".lit)
      .first[:ratio]
      .to_f
  end

  def locks
    target_db[:pg_locks].exclude(:granted).count
  end
end
