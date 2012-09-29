require 'sinatra'
require 'sequel'
require 'json'
require 'uri'
DB = Sequel.connect ENV['TARGET_DB']

class Datascope < Sinatra::Application
  get '/' do
    haml :index
  end

  get '/history.json' do
    time = Time.now - 2*60*60
    (0..120).map do |t|
      {
        time: time + t*60,
        connections: (12*t/160).to_i,
        cache_hit: 0.98
      }
    end.to_json
  end

  get '/stats.json' do
    {
      time: Time.now,
      connections: count,
      cache_hit: cache_hit
    }.to_json
  end


  def count
    DB[:pg_stat_activity].count
  end

  def cache_hit
    f = DB[:pg_statio_user_tables].select("(sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) as ratio".lit).first[:ratio].to_f
    p f
    f
  end

end
